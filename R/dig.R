#'
#' @return
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
                 disjoint,
                 min_length,
                 max_length,
                 min_support,
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
                                 c("condition", "foci_supports", "indices", "support", "weights"))
    if (length(unrecognized_args) > 0) {
        details <- paste0("The argument {.var ", unrecognized_args, "} is not allowed.")
        cli_abort(c("The function {.var f} must have allowed formal arguments only.",
                    ..error_details(details)),
                  call = caller_env(2))
    }

    .must_be_atomic_vector(disjoint)
    if (!isTRUE(length(disjoint) == 0 || length(disjoint) == length(logicals) + length(doubles))) {
        cli_abort(c("The length of {.var disjoint} must be 0 or equal to the sum of lengths of {.var logicals} and {.var doubles}.",
                    "x" = "The length of {.var disjoint} is {length(disjoint)}.",
                    "x" = "The length of {.var logicals} is {length(logicals)}.",
                    "x" = "The length of {.var doubles} is {length(doubles)}."),
                  call = caller_env(2))
    }
    disjoint <- as.integer(as.factor(disjoint))

    .must_be_integerish_scalar(min_length)
    .must_be_finite(min_length)
    .must_be_greater_eq(min_length, 0)
    min_length <- as.integer(min_length)

    .must_be_integerish_scalar(max_length)
    .must_be_greater_eq(max_length, 0)
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

    .must_be_double_scalar(min_support)
    .must_be_in_range(min_support, c(0, 1))
    min_support <- as.double(min_support)

    arguments <- formalArgs(f)
    if (is.null(arguments)) {
        arguments <- ""
    }

    fun <- function(l) {
        do.call(f, c(l, list(...)))
    }

    config <- list(arguments = arguments,
                   predicates = predicates,
                   foci = foci,
                   disjoint = disjoint,
                   minLength = min_length,
                   maxLength = max_length,
                   minSupport = as.double(min_support));

    dig_(logicals, doubles, logicals_foci, doubles_foci, config, fun)
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

    if (is.logical(x)) {
        .dig(logicals = data_cols,
             doubles = list(),
             predicates = predicates,
             logicals_foci = foci_cols,
             doubles_foci = list(),
             foci = foci,
             f = f,
             disjoint = disjoint,
             min_length = min_length,
             max_length = max_length,
             min_support = min_support)

    } else if (is.double(x)) {
        .dig(logicals = list(),
             doubles = data_cols,
             predicates = predicates,
             logicals_foci = list(),
             doubles_foci = foci_cols,
             foci = foci,
             f = f,
             disjoint = disjoint,
             min_length = min_length,
             max_length = max_length,
             min_support = min_support)

    } else {
        cli_abort(c("{.var x} must be either logical or numeric matrix.",
                    "x" = "You've supplied a matrix of type {.cls {typeof(x)}}."))
    }
}
