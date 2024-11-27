#' Extract variable names from predicates
#'
#' The function assumes that `x` is a vector of predicate names, i.e., a character
#' vector with elements compatible with pattern `<varname>=<value>`. The function
#' returns the `<varname>` part of these elements. If the string does not
#' correspond to the pattern `<varname>=<value>`, i.e., if the equal sign (`=`)
#' is missing in the string, the whole string is returned.
#'
#' @param x A character vector of predicate names.
#' @return A `<varname>` part of predicate names in `x`.
#' @author Michal Burda
#' @examples
#' varnames(c("a=1", "a=2", "b=x", "b=y")) # returns c("a", "a", "b", "b")
#' @export
varnames <- function(x) {
    .must_be_character_vector(x, null = TRUE)

    if (is.null(x))
        return(NULL)

    sub("=.*", "", x)
}
