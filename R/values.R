#' Extract values from predicates
#'
#' The function assumes that `x` is a vector of predicate names, i.e., a character
#' vector with elements compatible with pattern `<varname>=<value>`. The function
#' returns the `<value>` part of these elements. If the string does not
#' correspond to the pattern `<varname>=<value>`, i.e., if the equal sign (`=`)
#' is missing in the string, an empty string is returned.
#'
#' @param x A character vector of predicate names.
#' @return A `<value>` part of predicate names in `x`.
#' @seealso [var_names()]
#' @author Michal Burda
#' @examples
#' values(c("a=1", "a=2", "b=x", "b=y")) # returns c("1", "2", "x", "y")
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
