#' Format a vector of predicates into a condition string
#'
#' Convert a character vector of predicate names into a standardized string
#' representation of a condition. Predicates are concatenated with commas and
#' enclosed in curly braces. This formatting ensures consistency when storing
#' or comparing conditions in other functions.
#'
#' @param condition A character vector of predicate names to be formatted. If
#'   `NULL` or of length zero, the result is `"{}"`, representing an empty
#'   condition that is always true.
#'
#' @return A character scalar containing the formatted condition string.
#'
#' @seealso [parse_condition()], [fire()]
#'
#' @author Michal Burda
#'
#' @examples
#' format_condition(NULL)
#' format_condition(character(0))
#' format_condition(c("a", "b", "c"))
#'
#' @export

format_condition <- function(condition) {
    .must_be_character_vector(condition, null = TRUE)

    paste0("{", paste0(sort(condition), collapse = ","), "}")
}
