..must_be_type <- function(f, msg) {
    function(x,
             null = FALSE,
             name = deparse(substitute(x)),
             call = caller_env()) {
        if (!isTRUE(f(x) | (isTRUE(null) && is.null(x)))) {
            na <- if (all(is.na(x))) " NA" else ""
            msg <- if (null) paste(msg, "or NULL") else msg
            cli_abort(c("{.var {name}} must be a {msg}.",
                        "x" = "You've supplied a {.cls {class(x)}}{na}."),
                      call = call)
        }
    }
}


..error_details <- function(details) {
    res <- details
    names(res) <- rep("x", length(res))
    if (length(res) > 5) {
        length(res) <- 4
        n <- length(details) - length(res)
        res <- c(res,
                 paste0("... and ", n, " more problems."))
    }

    res
}


..must_be_list_of <- function(f, msg) {
    function(x,
             null = FALSE,
             name = deparse(substitute(x)),
             call = caller_env()) {
        .must_be_list(x, null = null, name, call)
        if (!is.null(x)) {
            test <- sapply(x, f)
            if (!isTRUE(all(test))) {
                types <- sapply(x, function(i) class(i)[1])
                details <- paste0("Element ", seq_along(types), " is a {.cls ", types, "}.")
                details <- details[!test]
                cli_abort(c("{.var {name}} must be a list of {msg}.",
                            ..error_details(details)),
                          call = call)
            }
        }
    }
}


..must_be_value <- function(f, msg) {
    function(x,
             name = deparse(substitute(x)),
             call = caller_env()) {
        test <- f(x)
        if (!isTRUE(all(test))) {
            details <- paste0("Element ", seq_along(x), " equals ", x, ".")
            details <- details[!test]
            cli_abort(c("{.var {name}} must be {msg}.",
                        ..error_details(details)),
                      call = call)
        }
    }
}


..must_be_comparable <- function(f, msg) {
    function(x,
             value,
             name = deparse(substitute(x)),
             call = caller_env()) {
        test <- f(x, value)
        if (!isTRUE(all(test))) {
            if (length(x) == 1) {
                details <- paste0("Value ", x, " was provided instead.")
            } else {
                details <- paste0("Element ", seq_along(x), " equals ", x, ".")
                details <- details[!test]
            }
            cli_abort(c("{.var {name}} must be {msg} {value}.",
                        ..error_details(details)),
                      call = call)
        }
    }
}


.must_be_flag <- ..must_be_type(function(x) is_scalar_logical(x) && !is.na(x), "flag (TRUE or FALSE)")

.must_be_null <- function(x,
                          when,
                          name = deparse(substitute(x)),
                          call = caller_env()) {
    if (!is.null(x)) {
        na <- if (all(is.na(x))) " NA" else ""
        cli_abort(c("{.var {name}} can't be non-NULL when {when}.",
                    "x" = "You've supplied a {.cls {class(x)}}{na}."),
                  call = call)
    }
}

.must_not_be_null <- function(x,
                              when = "",
                              name = deparse(substitute(x)),
                              call = caller_env()) {
    if (is.null(x)) {
        msg <- ifelse(when == "",
                      "{.var {name}} must not be NULL",
                      "{.var {name}} can't be NULL when {when}")
        cli_abort(c(msg,
                    "x" = "{.var {name}} is NULL."),
                  call = call)
    }
}

..must_be_type <- function(f, msg) {
    function(x,
             null = FALSE,
             name = deparse(substitute(x)),
             call = caller_env()) {
        if (!isTRUE(f(x) | (isTRUE(null) && is.null(x)))) {
            na <- if (all(is.na(x))) " NA" else ""
            msg <- if (null) paste(msg, "or NULL") else msg
            cli_abort(c("{.var {name}} must be a {msg}.",
                        "x" = "You've supplied a {.cls {class(x)}}{na}."),
                      call = call)
        }
    }
}

.must_be_atomic_scalar <- ..must_be_type(is_scalar_atomic, "atomic scalar")
.must_be_integerish_scalar <- ..must_be_type(is_scalar_integerish, "integerish scalar")
.must_be_double_scalar <- ..must_be_type(is_scalar_double, "double scalar")
.must_be_character_scalar <- ..must_be_type(is_scalar_character, "character scalar")
.must_be_logical_scalar <- ..must_be_type(is_scalar_logical, "logical scalar")

.must_be_atomic_vector <- ..must_be_type(is.atomic, "atomic vector")
.must_be_integer_vector <- ..must_be_type(is_integer, "integer vector")
.must_be_integerish_vector <- ..must_be_type(is_integerish, "integerish vector")
.must_be_numeric_vector <- ..must_be_type(is.numeric, "numeric vector")
.must_be_character_vector <- ..must_be_type(is.character, "character vector")
.must_be_factor <- ..must_be_type(is.factor, "factor")
.must_be_matrix <- ..must_be_type(is.matrix, "matrix")
.must_be_function <- ..must_be_type(is.function, "function")
.must_be_list <- ..must_be_type(is.list, "list")
.must_be_data_frame <- ..must_be_type(is.data.frame, "data frame")

.must_be_list_of_logicals <- ..must_be_list_of(is.logical, "logical vectors")
.must_be_list_of_doubles <- ..must_be_list_of(is.double, "double (numeric) vectors")
.must_be_list_of_characters <- ..must_be_list_of(is.character, "character vectors")
.must_be_list_of_functions <- ..must_be_list_of(is.function, "functions")

.must_be_finite <- ..must_be_value(is.finite, "finite")
.must_be_greater <- ..must_be_comparable(`>`, ">")
.must_be_greater_eq <- ..must_be_comparable(`>=`, ">=")
.must_be_lower <- ..must_be_comparable(`<`, "<")
.must_be_lower_eq <- ..must_be_comparable(`<=`, "<=")
.must_be_in_range <- ..must_be_comparable(function(x, range) x >= range[1] & x <= range[2],
                                          "between")

.must_have_length <- function(x,
                              value,
                              name = deparse(substitute(x)),
                              call = caller_env()) {
    if (!isTRUE(length(x) == value)) {
        cli_abort(c("{.var {name}} must have {value} elements.",
                    ..error_details("{.var {name}} has {length(x)} elements.")),
                  call = call)
    }
}

.must_have_equal_lengths <- function(x,
                                     y,
                                     name_x = deparse(substitute(x)),
                                     name_y = deparse(substitute(y)),
                                     call = caller_env()) {
    if (!isTRUE(length(x) == length(y))) {
        cli_abort(c("{.var {name_x}} and {.var {name_y}} must have the same number of elements.",
                    ..error_details(c("{.var {name_x}} has {length(x)} elements.",
                                      "{.var {name_y}} has {length(y)} elements."))),
                    call = call)
    }
}

.must_be_list_of_equal_length_vectors <- function(x,
                                                  name = deparse(substitute(x)),
                                                  call = caller_env()) {
    .must_be_list(x, name, call)
    lengths <- sapply(x, length)
    if (!isTRUE(length(unique(lengths)) <= 1)) {
        test <- duplicated(lengths)
        details <- paste0("Element ", seq_along(lengths), " has length ", lengths, ".")
        details <- details[!test]
        cli_abort(c("{.var {name}} must be a list of vectors of equal length.",
                    ..error_details(details)),
                  call = call)
    }
}
