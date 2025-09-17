#' Extract values from predicate names
#'
#' This function extracts the value part from a character vector of predicate
#' names. Each element of `x` is expected to follow the pattern
#' `<varname>=<value>`, where `<varname>` is a variable name and `<value>` is
#' the associated value.
#'
#' If an element does not contain an equal sign (`=`), the function returns an
#' empty string for that element.
#'
#' @details
#' This function is the counterpart to [var_names()], which extracts the
#' variable part of predicates. Together, [var_names()] and `values()` provide
#' a convenient way to split predicate strings into their variable and value
#' components.
#'
#' @param x A character vector of predicate names.
#'
#' @return A character vector containing the `<value>` parts of predicate
#'   names in `x`. Elements without an equal sign return an empty string.
#'   If `x` is `NULL`, the function returns `NULL`. If `x` is an empty
#'   vector (`character(0)`), the function returns an empty vector
#'   (`character(0)`).
#'
#' @seealso [var_names()]
#'
#' @author Michal Burda
#'
#' @examples
#' values(c("a=1", "a=2", "b=x", "b=y"))
#' # returns c("1", "2", "x", "y")
#'
#' values(c("a", "b=3"))
#' # returns c("", "3")
#'
#' @export
values <- function(x) {
    .must_be_character_vector(x, null = TRUE)

    if (is.null(x))
        return(NULL)

    has_eq <- grepl("=", x)
    res <- x
    res[!has_eq] <- ""
    res[has_eq] <- sub("^[^=]*=", "", x[has_eq])

    res
}
