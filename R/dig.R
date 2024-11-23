#' Search for patterns of custom type
#'
#' @description
#' `r lifecycle::badge("experimental")`
#'
#' This is a general function that enumerates all conditions created from
#' data in `x` and calls the callback function `f` on each.
#'
#' @param x a matrix or data frame. The matrix must be numeric (double) or logical.
#'      If `x` is a data frame then each column must be either numeric (double) or
#'      logical.
#' @param f the callback function executed for each generated condition. This
#'      function may have some of the following arguments. Based on the present
#'      arguments, the algorithm would provide information about the generated
#'      condition:
#'      - `condition` - a named integer vector of column indices that represent
#'        the predicates of the condition. Names of the vector correspond to
#'        column names;
#'      - `support` - a numeric scalar value of the current condition's support;
#'      - `indices` - a logical vector indicating the rows satisfying the condition;
#'      - `weights` - (similar to indices) weights of rows to which they satisfy
#'        the current condition;
#'      - `pp` - a value of a contingency table, `condition & focus`.
#'        `pp` is a named numeric vector where each value is a support of conjunction
#'        of the condition with a foci column (see the `focus` argument to specify,
#'        which columns). Names of the vector are foci column names.
#'      - `pn` - a value of a contingency table, `condition & neg focus`.
#'        `pn` is a named numeric vector where each value is a support of conjunction
#'        of the condition with a negated foci column (see the `focus` argument to
#'        specify, which columns are foci) - names of the vector are foci column names.
#'      - `np` - a value of a contingency table, `neg condition & focus`.
#'        `np` is a named numeric vector where each value is a support of conjunction
#'        of the negated condition with a foci column (see the `focus` argument to
#'        specify, which columns are foci) - names of the vector are foci column names.
#'      - `nn` - a value of a contingency table, `neg condition & neg focus`.
#'        `nn` is a named numeric vector where each value is a support of conjunction
#'        of the negated condition with a negated foci column (see the `focus`
#'        argument to specify, which columns are foci) - names of the vector are foci
#'        column names.
#'      - `foci_supports` - (deprecated, use `pp` instead)
#'        a named numeric vector of supports of foci columns
#'        (see `focus` argument to specify, which columns are foci) - names of the
#'        vector are foci column names.
#' @param condition a tidyselect expression (see
#'      [tidyselect syntax](https://tidyselect.r-lib.org/articles/syntax.html))
#'      specifying the columns to use as condition predicates
#' @param focus a tidyselect expression (see
#'      [tidyselect syntax](https://tidyselect.r-lib.org/articles/syntax.html))
#'      specifying the columns to use as focus predicates
#' @param disjoint an atomic vector of size equal to the number of columns of `x`
#'      that specifies the groups of predicates: if some elements of the `disjoint`
#'      vector are equal, then the corresponding columns of `x` will NOT be
#'      present together in a single condition.
#' @param min_length the minimum size (the minimum number of predicates) of the
#'      condition to be generated (must be greater or equal to 0). If 0, the empty
#'      condition is generated in the first place.
#' @param max_length The maximum size (the maximum number of predicates) of the
#'      condition to be generated. If equal to Inf, the maximum length of conditions
#'      is limited only by the number of available predicates.
#' @param min_support the minimum support of a condition to trigger the callback
#'      function for it. The support of the condition is the relative frequency
#'      of the condition in the dataset `x`. For logical data, it equals to the
#'      relative frequency of rows such that all condition predicates are TRUE on it.
#'      For numerical (double) input, the support is computed as the mean (over all
#'      rows) of multiplications of predicate values.
#' @param min_focus_support the minimum support of a focus, for the focus to be passed
#'      to the callback function. The support of the focus is the relative frequency
#'      of rows such that all condition predicates AND the focus are TRUE on it.
#'      For numerical (double) input, the support is computed as the mean (over all
#'      rows) of multiplications of predicate values.
#' @param filter_empty_foci a logical scalar indicating whether to skip conditions,
#'      for which no focus remains available after filtering by `min_focus_support`.
#'      If `TRUE`, the condition is passed to the callback function only if at least
#'      one focus remains after filtering. If `FALSE`, the condition is passed to the
#'      callback function regardless of the number of remaining foci.
#' @param t_norm a t-norm used to compute conjunction of weights. It must be one of
#'      `"goedel"` (minimum t-norm), `"goguen"` (product t-norm), or `"lukas"`
#'      (Lukasiewicz t-norm).
#' @param threads the number of threads to use for parallel computation.
#' @param ... Further arguments, currently unused.
#' @returns A list of results provided by the callback function `f`.
#' @author Michal Burda
#' @export
dig <- function(x,
                f,
                condition = everything(),
                focus = NULL,
                disjoint = NULL,
                min_length = 0,
                max_length = Inf,
                min_support = 0.0,
                min_focus_support = min_support,
                filter_empty_foci = FALSE,
                t_norm = "goguen",
                threads = 1L,
                ...) {
    cols <- .convert_data_to_list(x)

    condition <- enquo(condition)
    focus <- enquo(focus)
    condition_cols <- .extract_cols(cols,
                                    !!condition,
                                    allow_numeric = TRUE,
                                    allow_empty = FALSE)
    foci_cols <- .extract_cols(cols,
                               !!focus,
                               allow_numeric = TRUE,
                               allow_empty = TRUE)

    .must_be_function(f, call = caller_env(2))
    unrecognized_args <- setdiff(formalArgs(f),
                                 c("condition", "foci_supports",
                                   "pp", "np", "pn", "nn",
                                   "indices", "sum", "support", "weights"))
    if (length(unrecognized_args) > 0) {
        details <- paste0("The argument {.var ", unrecognized_args, "} is not allowed.")
        cli_abort(c("The function {.var f} must have allowed formal arguments only.",
                    ..error_details(details)))
    }
    arguments <- formalArgs(f)
    if (is.null(arguments)) {
        arguments <- ""
    }

    .must_be_vector(disjoint, null = TRUE)
    if (!isTRUE(length(disjoint) == 0 || length(disjoint) == ncol(x))) {
        cli_abort(c("The length of {.var disjoint} must be 0 or equal to the number of rows in {.var x}.",
                    "x" = "The number of rows in {.var x} is {nrow(x)}.",
                    "x" = "The length of {.var disjoint} is {length(disjoint)}."))
    }

    disjoint_predicates <- integer(0L)
    disjoint_foci <- integer(0L)
    if (length(disjoint) > 0) {
        disjoint <- as.integer(as.factor(disjoint))
        disjoint_predicates <- disjoint[condition_cols$indices]
        disjoint_foci <- disjoint[foci_cols$indices]
    }

    .must_be_integerish_scalar(min_length)
    .must_be_finite(min_length)
    .must_be_greater_eq(min_length, 0)
    min_length <- as.integer(min_length)

    .must_be_integerish_scalar(max_length)
    .must_be_greater_eq(max_length, 0)
    if (max_length < min_length) {
        cli_abort(c("{.var max_length} must be greater or equal to {.var min_length}.",
                    "x" = "{.var min_length} equals {min_length}.",
                    "x" = "{.var max_length} equals {max_length}."))
    }
    if (!is.finite(max_length)) {
        max_length <- -1L;
    }
    max_length <- as.integer(max_length)

    .must_be_double_scalar(min_support)
    .must_be_in_range(min_support, c(0, 1))
    min_support <- as.double(min_support)

    .must_be_double_scalar(min_focus_support)
    .must_be_in_range(min_focus_support, c(0, 1))
    min_focus_support <- as.double(min_focus_support)

    .must_be_flag(filter_empty_foci)

    .must_be_enum(t_norm, c("goguen", "goedel", "lukas"))

    .must_be_integerish_scalar(threads)
    .must_be_greater_eq(threads, 1)
    threads <- as.integer(threads)

    config <- list(arguments = arguments,
                   predicates = condition_cols$indices,
                   foci = foci_cols$indices,
                   disjoint_predicates = disjoint_predicates,
                   disjoint_foci = disjoint_foci,
                   minLength = min_length,
                   maxLength = max_length,
                   minSupport = min_support,
                   minFocusSupport = min_focus_support,
                   filterEmptyFoci = filter_empty_foci,
                   tNorm = t_norm,
                   threads = threads)

    res <- dig_(condition_cols$logicals,
                condition_cols$doubles,
                foci_cols$logicals,
                foci_cols$doubles, config)

    lapply(res, do.call, what = f)
}
