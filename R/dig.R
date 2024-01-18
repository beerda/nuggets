#' Search for rules
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
#'      - condition - a named integer vector of column indices that represent
#'        the predicates of the condition. Names of the vector correspond to
#'        column names;
#'      - foci_supports - a named numeric vector of supports of foci columns
#'        (see `focus` argument to specify, which columns are foci) - names of the
#'        vector are foci column names;
#'      - support - a numeric scalar value of the current condition's support;
#'      - indices - a logical vector indicating the rows satisfying the condition;
#'      - weights - (similar to indices) weights of rows to which they satisfy
#'        the current condition.
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
#' @param t_norm a t-norm used to compute conjunction of weights. It must be one of
#'      `"goedel"` (minimum t-norm), `"goguen"` (product t-norm), or `"lukas"`
#'      (Lukasiewicz t-norm).
#' @param ... Further arguments, currently unused.
#' @returns A list of results provided by the callback function `f`.
#' @author Michal Burda
#' @export
dig <- function(x,
                f,
                ...) {
    UseMethod("dig")
}


#' @rdname dig
#' @export
dig.default <- function(x, f, ...) {
    cli_abort("Can't process {.var x} of type {class(x)}.")
}


.dig <- function(logicals,
                 doubles,
                 predicates,
                 logicals_foci,
                 doubles_foci,
                 foci,
                 f,
                 disjoint_predicates,
                 disjoint_foci,
                 min_length,
                 max_length,
                 min_support,
                 t_norm,
                 ...) {
    .must_be_list_of_logicals(logicals)
    .must_be_list_of_doubles(doubles)
    .must_be_list_of_logicals(logicals_foci)
    .must_be_list_of_doubles(doubles_foci)

    .must_be_list_of_equal_length_vectors(logicals)
    .must_be_list_of_equal_length_vectors(doubles)
    .must_be_list_of_equal_length_vectors(logicals_foci)
    .must_be_list_of_equal_length_vectors(doubles_foci)

    lengths <- NULL
    err <- NULL
    if (length(logicals) > 0) {
        l <- length(logicals[[1]])
        err <- c(err, "x" = paste0("{.var logicals} has vectors of length ", l, "."))
        lengths <- c(lengths, l)
    }
    if (length(doubles) > 0) {
        l <- length(doubles[[1]])
        err <- c(err, "x" = paste0("{.var doubles} has vectors of length ", l, "."))
        lengths <- c(lengths, l)
    }
    if (length(logicals_foci) > 0) {
        l <- length(logicals_foci[[1]])
        err <- c(err, "x" = paste0("{.var logicals_foci} has vectors of length ", l, "."))
        lengths <- c(lengths, l)
    }
    if (length(doubles_foci) > 0) {
        l <- length(doubles_foci[[1]])
        err <- c(err, "x" = paste0("{.var doubles_foci} has vectors of length ", l, "."))
        lengths <- c(lengths, l)
    }
    if (!isTRUE(length(unique(lengths)) == 1)) {
        cli_abort(c("Data inputs must be lists of vectors of compatible lengths.", err))
    }

    .must_be_integer_vector(predicates)
    if (!isTRUE(length(predicates) == length(logicals) + length(doubles))) {
        cli_abort(c("The length of {.var predicates} must equal to the sum of lengths of {.var logicals} and {.var doubles}.",
                    "x" = "The length of {.var predicates} is {length(predicates)}.",
                    "x" = "The length of {.var logicals} is {length(logicals)}.",
                    "x" = "The length of {.var doubles} is {length(doubles)}."))
    }

    .must_be_integer_vector(foci)
    if (!isTRUE(length(foci) == length(logicals_foci) + length(doubles_foci))) {
        cli_abort(c("The length of {.var foci} must equal to the sum of lengths of {.var logicals_foci} and {.var doubles_foci}.",
                    "x" = "The length of {.var foci} is {length(foci)}.",
                    "x" = "The length of {.var logicals_foci} is {length(logicals_foci)}.",
                    "x" = "The length of {.var doubles_foci} is {length(doubles_foci)}."))
    }

    .must_be_function(f, call = caller_env(2))

    unrecognized_args <- setdiff(formalArgs(f),
                                 c("condition", "foci_supports", "indices", "sum", "support", "weights"))
    if (length(unrecognized_args) > 0) {
        details <- paste0("The argument {.var ", unrecognized_args, "} is not allowed.")
        cli_abort(c("The function {.var f} must have allowed formal arguments only.",
                    ..error_details(details)),
                  call = caller_env(2))
    }

    if (is.null(disjoint_predicates)) {
        disjoint_predicates <- integer(0L)
    }
    .must_be_integer_vector(disjoint_predicates)
    if (!isTRUE(length(disjoint_predicates) == 0 || length(disjoint_predicates) == length(predicates))) {
        cli_abort(c("The length of {.var disjoint_predicates} must be 0 or equal to the length of {.var predicates}.",
                    "x" = "The length of {.var disjoint_predicates} is {length(disjoint_predicates)}.",
                    "x" = "The length of {.var predicates} is {length(predicates)}."),
                  call = caller_env(2))
    }

    if (is.null(disjoint_foci)) {
        disjoint_foci <- integer(0L)
    }
    .must_be_integer_vector(disjoint_foci)
    if (!isTRUE(length(disjoint_foci) == 0 || length(disjoint_foci) == length(foci))) {
        cli_abort(c("The length of {.var disjoint_foci} must be 0 or equal to the length of {.var foci}.",
                    "x" = "The length of {.var disjoint_foci} is {length(disjoint_foci)}.",
                    "x" = "The length of {.var foci} is {length(foci)}."),
                  call = caller_env(2))
    }

    .must_be_integerish_scalar(min_length, call = caller_env(2))
    .must_be_finite(min_length, call = caller_env(2))
    .must_be_greater_eq(min_length, 0, call = caller_env(2))
    min_length <- as.integer(min_length)

    .must_be_integerish_scalar(max_length, call = caller_env(2))
    .must_be_greater_eq(max_length, 0, call = caller_env(2))
    if (max_length < min_length) {
        cli_abort(c("{.var max_length} must be greater or equal to {.var min_length}.",
                    "x" = "{.var min_length} equals {min_length}.",
                    "x" = "{.var max_length} equals {max_length}."),
                  call = caller_env(2))
    }
    if (!is.finite(max_length)) {
        max_length <- -1L;
    }
    max_length <- as.integer(max_length)

    .must_be_double_scalar(min_support, call = caller_env(2))
    .must_be_in_range(min_support, c(0, 1), call = caller_env(2))
    min_support <- as.double(min_support)

    .must_be_enum(t_norm, c("goguen", "goedel", "lukas"), call = caller_env(2))

    arguments <- formalArgs(f)
    if (is.null(arguments)) {
        arguments <- ""
    }

    config <- list(arguments = arguments,
                   predicates = predicates,
                   foci = foci,
                   disjoint_predicates = disjoint_predicates,
                   disjoint_foci = disjoint_foci,
                   minLength = min_length,
                   maxLength = max_length,
                   minSupport = as.double(min_support),
                   tNorm = t_norm);

    res <- dig_(logicals, doubles, logicals_foci, doubles_foci, config)

    dots <- list(...)
    if (length(dots) > 0) {
        res <- lapply(res, function(l) { do.call(f, c(l, dots)) })
    } else {
        res <- lapply(res, do.call, what = f)
    }

    res
}


#' @rdname dig
#' @export
dig.matrix <- function(x,
                       f,
                       condition = everything(),
                       focus = NULL,
                       disjoint = NULL,
                       min_length = 0,
                       max_length = Inf,
                       min_support = 0.0,
                       t_norm = "goguen",
                       ...) {
    .must_be_matrix(x)

    cols <- lapply(seq_len(ncol(x)), function(i) x[, i])
    names(cols) <- colnames(x)
    if (is.null(names(cols))) {
        names(cols) <- seq_len(length(cols))
    }

    condition <- enquo(condition)
    predicates <- eval_select(condition, cols)
    data_cols <- cols[predicates]

    focus <- enquo(focus)
    foci <- eval_select(focus, cols)
    foci_cols <- cols[foci]

    if (!is.null(disjoint)) {
        disjoint <- as.integer(as.factor(disjoint))
    }

    if (is.logical(x)) {
        .dig(logicals = data_cols,
             doubles = list(),
             predicates = predicates,
             logicals_foci = foci_cols,
             doubles_foci = list(),
             foci = foci,
             f = f,
             disjoint_predicates = disjoint[predicates],
             disjoint_foci = disjoint[foci],
             min_length = min_length,
             max_length = max_length,
             min_support = min_support,
             t_norm = t_norm)

    } else if (is.double(x)) {
        .dig(logicals = list(),
             doubles = data_cols,
             predicates = predicates,
             logicals_foci = list(),
             doubles_foci = foci_cols,
             foci = foci,
             f = f,
             disjoint_predicates = disjoint[predicates],
             disjoint_foci = disjoint[foci],
             min_length = min_length,
             max_length = max_length,
             min_support = min_support,
             t_norm = t_norm)

    } else {
        cli_abort(c("{.var x} must be either logical or numeric (double) matrix.",
                    "x" = "You've supplied a matrix of type {.cls {typeof(x)}}."))
    }
}


.extract_cols <- function(cols, selection) {
    selection <- enquo(selection)
    indices <- eval_select(selection, cols)
    cols <- cols[indices]
    logicals <- vapply(cols, is.logical, logical(1))
    doubles <- vapply(cols, is.double, logical(1))

    if (!all(logicals | doubles)) {
        errors <- c()
        for (i in which(!(logicals | doubles))) {
            errors <- c(errors,
                        "x" = paste0("Column {.var ",
                                     names(cols)[i],
                                     "} is of type {.cls ",
                                     typeof(cols[[i]]),
                                     "}."))
        }
        len <- length(errors)
        if (len > 5) {
            length(errors) <- 4
            len <- len - length(errors)
            errors <- c(errors, paste0("... and ", len, " more problems."))
        }
        cli_abort(c("All columns in {.var x} must be either logical or double.",
                    errors),
                  call = caller_env())
    }

    list(logicals = cols[logicals],
         doubles = cols[doubles],
         indices = c(indices[logicals], indices[doubles]))
}


#' @rdname dig
#' @export
dig.data.frame <- function(x,
                           f,
                           condition = everything(),
                           focus = NULL,
                           disjoint = NULL,
                           min_length = 0,
                           max_length = Inf,
                           min_support = 0.0,
                           t_norm = "goguen",
                           ...) {
    .must_be_data_frame(x)

    cols <- as.list(x)
    if (is.null(names(cols))) {
        names(cols) <- seq_len(length(cols))
    }

    condition <- enquo(condition)
    focus <- enquo(focus)
    condition_cols <- .extract_cols(cols, !!condition)
    foci_cols <- .extract_cols(cols, !!focus)

    if (!is.null(disjoint)) {
        disjoint <- as.integer(as.factor(disjoint))
    }

    .dig(logicals = condition_cols$logicals,
         doubles = condition_cols$doubles,
         predicates = condition_cols$indices,
         logicals_foci = foci_cols$logicals,
         doubles_foci = foci_cols$doubles,
         foci = foci_cols$indices,
         f = f,
         disjoint_predicates = disjoint[condition_cols$indices],
         disjoint_foci = disjoint[foci_cols$indices],
         min_length = min_length,
         max_length = max_length,
         min_support = min_support,
         t_norm = t_norm)
}
