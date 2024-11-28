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
#'      present together in a single condition. If `x` is prepared with
#'      [partition()], using the [varnames()] function on `x`'s column names
#'      is a convenient way to create the `disjoint` vector.
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
#' @param error_context a list of details to be used in error messages.
#'      This argument is useful when `dig()` is called from another
#'      function to provide error messages, which refer to arguments of the
#'      calling function. The list must contain the following elements:
#'      - `arg_x` - the name of the argument `x` as a character string
#'      - `arg_f` - the name of the argument `f` as a character string
#'      - `arg_condition` - the name of the argument `condition` as a character
#'         string
#'      - `arg_focus` - the name of the argument `focus` as a character string
#'      - `arg_disjoint` - the name of the argument `disjoint` as a character
#'         string
#'      - `arg_min_length` - the name of the argument `min_length` as a character
#'         string
#'      - `arg_max_length` - the name of the argument `max_length` as a character
#'         string
#'      - `arg_min_support` - the name of the argument `min_support` as a character
#'         string
#'      - `arg_min_focus_support` - the name of the argument `min_focus_support`
#'         as a character string
#'      - `arg_filter_empty_foci` - the name of the argument `filter_empty_foci`
#'         as a character string
#'      - `arg_t_norm` - the name of the argument `t_norm` as a character string
#'      - `arg_threads` - the name of the argument `threads` as a character string
#'      - `call` - an environment in which to evaluate the error messages.
#' @param ... Further arguments, currently unused.
#' @returns A list of results provided by the callback function `f`.
#' @seealso [partition()], [varnames()]
#' @author Michal Burda
#' @export
dig <- function(x,
                f,
                condition = everything(),
                focus = NULL,
                disjoint = varnames(colnames(x)),
                min_length = 0,
                max_length = Inf,
                min_support = 0.0,
                min_focus_support = min_support,
                filter_empty_foci = FALSE,
                t_norm = "goguen",
                threads = 1L,
                error_context = list(arg_x = "x",
                                     arg_f = "f",
                                     arg_condition = "condition",
                                     arg_focus = "focus",
                                     arg_disjoint = "disjoint",
                                     arg_min_length = "min_length",
                                     arg_max_length = "max_length",
                                     arg_min_support = "min_support",
                                     arg_min_focus_support = "min_focus_support",
                                     arg_filter_empty_foci = "filter_empty_foci",
                                     arg_t_norm = "t_norm",
                                     arg_threads = "threads",
                                     call = current_env()),
                ...) {
    cols <- .convert_data_to_list(x, error_context = error_context)

    condition <- enquo(condition)
    focus <- enquo(focus)
    condition_cols <- .extract_cols(cols,
                                    !!condition,
                                    allow_numeric = TRUE,
                                    allow_empty = TRUE,
                                    error_context = list(arg_selection = error_context$arg_condition,
                                                         call = error_context$call))
    foci_cols <- .extract_cols(cols,
                               !!focus,
                               allow_numeric = TRUE,
                               allow_empty = TRUE,
                               error_context = list(arg_selection = error_context$arg_focus,
                                                    call = error_context$call))

    .must_be_function(f,
                      arg = error_context$arg_f,
                      call = error_context$call)
    unrecognized_args <- setdiff(formalArgs(f),
                                 c("condition", "foci_supports",
                                   "pp", "np", "pn", "nn",
                                   "indices", "sum", "support", "weights"))
    if (length(unrecognized_args) > 0) {
        details <- paste0("The argument {.arg ", unrecognized_args, "} is not allowed.")
        cli_abort(c("The function {.arg error_context$arg_f} must have allowed formal arguments only.",
                    ..error_details(details)),
                  call = error_context$call)
    }
    arguments <- formalArgs(f)
    if (is.null(arguments)) {
        arguments <- ""
    }

    .must_be_vector(disjoint,
                    null = TRUE,
                    arg = error_context$arg_disjoint,
                    call = error_context$call)
    if (!isTRUE(length(disjoint) == 0 || length(disjoint) == ncol(x))) {
        cli_abort(c("The length of {.arg error_context$arg_disjoint} must be 0 or equal to the number of rows in {.arg error_context$arg_x}.",
                    "x" = "The number of rows in {.arg error_context$arg_x} is {nrow(x)}.",
                    "x" = "The length of {.arg error_context$arg_disjoint} is {length(disjoint)}."),
                  call = error_context$call)
    }

    disjoint_predicates <- integer(0L)
    disjoint_foci <- integer(0L)
    if (length(disjoint) > 0) {
        disjoint <- as.integer(as.factor(disjoint))
        disjoint_predicates <- disjoint[condition_cols$indices]
        disjoint_foci <- disjoint[foci_cols$indices]
    }

    .must_be_integerish_scalar(min_length,
                               arg = error_context$arg_min_length,
                               call = error_context$call)
    .must_be_finite(min_length,
                    arg = error_context$arg_min_length,
                    call = error_context$call)
    .must_be_greater_eq(min_length, 0,
                        arg = error_context$arg_min_length,
                        call = error_context$call)
    min_length <- as.integer(min_length)

    .must_be_integerish_scalar(max_length,
                               arg = error_context$arg_max_length,
                               call = error_context$call)
    .must_be_greater_eq(max_length, 0,
                        arg = error_context$arg_max_length,
                        call = error_context$call)
    if (max_length < min_length) {
        cli_abort(c("{.arg error_context$arg_max_length} must be greater or equal to {.arg error_context$arg_min_length}.",
                    "x" = "{.arg error_context$arg_min_length} equals {min_length}.",
                    "x" = "{.arg error_context$arg_max_length} equals {max_length}."),
                  call = error_context$call)
    }
    if (!is.finite(max_length)) {
        max_length <- -1L;
    }
    max_length <- as.integer(max_length)

    .must_be_double_scalar(min_support,
                           arg = error_context$arg_min_support,
                           call = error_context$call)
    .must_be_in_range(min_support, c(0, 1),
                      arg = error_context$arg_min_support,
                      call = error_context$call)
    min_support <- as.double(min_support)

    .must_be_double_scalar(min_focus_support,
                           arg = error_context$arg_min_focus_support,
                           call = error_context$call)
    .must_be_in_range(min_focus_support, c(0, 1),
                      arg = error_context$arg_min_focus_support,
                      call = error_context$call)
    min_focus_support <- as.double(min_focus_support)

    .must_be_flag(filter_empty_foci,
                  arg = error_context$arg_filter_empty_foci,
                  call = error_context$call)

    .must_be_enum(t_norm, c("goguen", "goedel", "lukas"),
                  arg = error_context$arg_t_norm,
                  call = error_context$call)

    .must_be_integerish_scalar(threads,
                               arg = error_context$arg_threads,
                               call = error_context$call)
    .must_be_greater_eq(threads, 1,
                        arg = error_context$arg_threads,
                        call = error_context$call)
    threads <- as.integer(threads)

    config <- list(nrow = nrow(x),
                   arguments = arguments,
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
