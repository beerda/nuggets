..must_be_type <- function(f, msg) {
    function(x,
             name = deparse(substitute(x)),
             call = caller_env()) {
        if (!isTRUE(f(x))) {
            cli_abort(c("{.var {name}} must be a {msg}.",
                        "x" = "You've supplied a {.cls {class(x)}}."),
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
             name = deparse(substitute(x)),
             call = caller_env()) {
        .must_be_list(x, name, call)
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


.must_be_integerish_scalar <- ..must_be_type(is_scalar_integerish, "integerish scalar")
.must_be_double_scalar <- ..must_be_type(is_scalar_double, "double scalar")
.must_be_atomic_vector <- ..must_be_type(is.atomic, "atomic vector")
.must_be_integer_vector <- ..must_be_type(is_integer, "integer vector")
.must_be_integerish_vector <- ..must_be_type(is_integerish, "integerish vector")
.must_be_matrix <- ..must_be_type(is.matrix, "matrix")
.must_be_function <- ..must_be_type(is.function, "function")
.must_be_list <- ..must_be_type(is.list, "list")

.must_be_list_of_logicals <- ..must_be_list_of(is.logical, "logical vectors")
.must_be_list_of_doubles <- ..must_be_list_of(is.double, "double (numeric) vectors")
.must_be_list_of_characters <- ..must_be_list_of(is.character, "character vectors")

.must_be_finite <- ..must_be_value(is.finite, "finite")
.must_be_greater_eq <- ..must_be_comparable(`>=`, ">=")
.must_be_in_range <- ..must_be_comparable(function(x, range) x >= range[1] & x <= range[2],
                                          "between")

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
