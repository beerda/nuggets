..must_be_type <- function(f, msg) {
    function(x,
             null = FALSE,
             arg = caller_arg(x),
             call = caller_env()) {
        if (!isTRUE(f(x) | (isTRUE(null) && is.null(x)))) {
            na <- if (length(x) == 1 && is.na(x)) " NA" else ""
            msg <- if (null) paste(msg, "or NULL") else msg
            cli_abort(c("{.arg {arg}} must be {msg}.",
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
             arg = caller_arg(x),
             call = caller_env()) {
        .must_be_list(x, null = null, arg = arg, call = call)
        if (!is.null(x)) {
            test <- sapply(x, f)
            if (!isTRUE(all(test))) {
                types <- sapply(x, function(i) class(i)[1])
                details <- paste0("Element ", seq_along(types), " is a {.cls ", types, "}.")
                details <- details[!test]
                cli_abort(c("{.arg {arg}} must be a list of {msg}.",
                            ..error_details(details)),
                          call = call)
            }
        }
    }
}


..must_be_value <- function(f, msg) {
    function(x,
             arg = caller_arg(x),
             call = caller_env()) {
        test <- f(x)
        if (!isTRUE(all(test))) {
            details <- paste0("Element ", seq_along(x), " equals ", x, ".")
            details <- details[!test]
            cli_abort(c("{.arg {arg}} must be {msg}.",
                        ..error_details(details)),
                      call = call)
        }
    }
}


..must_be_comparable <- function(f, msg) {
    function(x,
             value,
             arg = caller_arg(x),
             call = caller_env()) {
        test <- f(x, value)
        if (!isTRUE(all(test))) {
            if (length(x) == 1) {
                details <- paste0("Value ", x, " was provided instead.")
            } else {
                details <- paste0("Element ", seq_along(x), " equals ", x, ".")
                details <- details[!test]
            }
            cli_abort(c("{.arg {arg}} must be {msg} {value}.",
                        ..error_details(details)),
                      call = call)
        }
    }
}


.must_be_flag <- ..must_be_type(function(x) is_scalar_logical(x) && !is.na(x), "a flag (TRUE or FALSE)")

.must_be_null <- function(x,
                          when,
                          arg = caller_arg(x),
                          call = caller_env()) {
    if (!is.null(x)) {
        na <- if (length(x) == 1 && is.na(x)) " NA" else ""
        cli_abort(c("{.arg {arg}} can't be non-NULL when {when}.",
                    "x" = "You've supplied a {.cls {class(x)}}{na}."),
                  call = call)
    }
}

.must_not_be_null <- function(x,
                              when = "",
                              arg = caller_arg(x),
                              call = caller_env()) {
    if (is.null(x)) {
        msg <- ifelse(when == "",
                      "{.arg {arg}} must not be NULL",
                      "{.arg {arg}} can't be NULL when {when}")
        cli_abort(c(msg,
                    "x" = "{.arg {arg}} is NULL."),
                  call = call)
    }
}

.must_be_atomic_scalar <- ..must_be_type(is_scalar_atomic, "an atomic scalar")
.must_be_integerish_scalar <- ..must_be_type(is_scalar_integerish, "an integerish scalar")
.must_be_double_scalar <- ..must_be_type(is_scalar_double, "a double scalar")
.must_be_character_scalar <- ..must_be_type(is_scalar_character, "a character scalar")
.must_be_logical_scalar <- ..must_be_type(is_scalar_logical, "a logical scalar")

.is_just_vector <- function(x) {
    is.vector(x) && !is.matrix(x) && !is.list(x) && !is.array(x)
}

.must_be_vector <- ..must_be_type(.is_just_vector, "a plain vector (not a matrix, list, or array)")
.must_be_integer_vector <- ..must_be_type(is_integer, "an integer vector")
.must_be_integerish_vector <- ..must_be_type(is_integerish, "an integerish vector")
.must_be_numeric_vector <- ..must_be_type(is.numeric, "a numeric vector")
.must_be_character_vector <- ..must_be_type(is.character, "a character vector")
.must_be_factor <- ..must_be_type(is.factor, "a factor")
.must_be_matrix <- ..must_be_type(is.matrix, "a matrix")
.must_be_list <- ..must_be_type(is.list, "a list")
.must_be_data_frame <- ..must_be_type(is.data.frame, "a data frame")


..must_be_function <- ..must_be_type(is.function, "a function")

.must_be_function <- function(x,
                              null = FALSE,
                              required = NULL,
                              optional = NA,
                              arg = caller_arg(x),
                              call = caller_env()) {
    ..must_be_function(x, null = null, arg = arg, call = call)

    if (!is.null(x)) {
        found <- formalArgs(x)
        found_msg <- paste0("`", paste0(found, collapse = '`, `'), "`")
        missing_required <- setdiff(required, found)
        if (length(missing_required) > 0) {
            msg <- paste0("`", paste0(required, collapse = '`, `'), "`")
            details <- paste0("The required argument {.arg ", missing_required, "} is missing.")
            cli_abort(c("Function {.arg {arg}} must have the following arguments: {msg}.",
                        "i" = "{.arg {arg}} has the following arguments: {found_msg}.",
                        ..error_details(details)),
                      call = call)
        }
        if (!any(is.na(optional))) {
            allowed <- c(required, optional)
            forbidden <- setdiff(found, allowed)
            if (length(forbidden) > 0) {
                msg <- paste0("`", paste0(allowed, collapse = '`, `'), "`")
                details <- paste0("Argument {.arg ", forbidden, "} isn't allowed.")
                cli_abort(c("Function {.arg {arg}} is allowed to have the following arguments only: {msg}.",
                        "i" = "{.arg {arg}} has the following arguments: {found_msg}.",
                            ..error_details(details)),
                          call = call)
            }
        }
    }
}



.must_have_some_rows <- function(x,
                                 arg = caller_arg(x),
                                 call = caller_env()) {
    if (nrow(x) <= 0) {
        cli_abort(c("{.arg {arg}} must have at least one row.",
                    "x" = "You've supplied a {.cls {class(x)}} with 0 rows."),
                  call = call)
    }
}

.must_have_some_cols <- function(x,
                                 arg = caller_arg(x),
                                 call = caller_env()) {
    if (ncol(x) <= 0) {
        cli_abort(c("{.arg {arg}} must have at least one column.",
                    "x" = "You've supplied a {.cls {class(x)}} with 0 columns."),
                  call = call)
    }
}

.must_be_list_of_logicals <- ..must_be_list_of(is.logical, "logical vectors")
.must_be_list_of_integerishes <- ..must_be_list_of(is_integerish, "integerish vectors")
.must_be_list_of_doubles <- ..must_be_list_of(is.double, "double (numeric) vectors")
.must_be_list_of_numeric <- ..must_be_list_of(is.numeric, "numeric vectors")
.must_be_list_of_characters <- ..must_be_list_of(is.character, "character vectors")
.must_be_list_of_functions <- ..must_be_list_of(is.function, "functions")

.must_be_finite <- ..must_be_value(is.finite, "finite")
.must_be_greater <- ..must_be_comparable(`>`, ">")
.must_be_greater_eq <- ..must_be_comparable(`>=`, ">=")
.must_be_lower <- ..must_be_comparable(`<`, "<")
.must_be_lower_eq <- ..must_be_comparable(`<=`, "<=")
.must_be_in_range <- ..must_be_comparable(function(x, range) x >= range[1] & x <= range[2],
                                          "between")

.must_be_enum <- function(x,
                          values,
                          null = FALSE,
                          multi = FALSE,
                          arg = caller_arg(x),
                          call = caller_env()) {
    test <- FALSE
    if (is.null(x)) {
        test <- isTRUE(null)
    } else {
        if (isTRUE(multi)) {
            test <- all(x %in% values)
        } else {
            test <- x %in% values
        }
    }
    if (!isTRUE(test)) {
        msg <- if (null) " or NULL" else ""
        single <- if (isTRUE(multi)) "any" else "one"
        vals <- paste0('"', values, '"', collapse = ", ")
        cli_abort(c("{.arg {arg}} must be equal to {single} of: {vals}{msg}.",
                    "x" = "You've supplied {x}."),
                  call = call)
    }
}

.must_have_length <- function(x,
                              value,
                              arg = caller_arg(x),
                              call = caller_env()) {
    if (!isTRUE(length(x) == value)) {
        cli_abort(c("{.arg {arg}} must have {value} elements.",
                    ..error_details("{.arg {arg}} has {length(x)} elements.")),
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
                                                  arg = caller_arg(x),
                                                  call = caller_env()) {
    .must_be_list(x, arg = arg, call = call)
    lengths <- sapply(x, length)
    if (!isTRUE(length(unique(lengths)) <= 1)) {
        test <- duplicated(lengths)
        details <- paste0("Element ", seq_along(lengths), " has length ", lengths, ".")
        details <- details[!test]
        cli_abort(c("{.arg {arg}} must be a list of vectors of equal length.",
                    ..error_details(details)),
                  call = call)
    }
}
