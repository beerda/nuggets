#' Format a vector of predicates into a string with a condition
#'
#' Function takes a character vector of predicates and returns a formatted
#' condition. The format of the condition is a string with predicates
#' separated by commas and enclosed in curly braces.
#'
#' @param condition a character vector of predicates to be formatted
#' @return a character scalar with a formatted condition
#' @author Michal Burda
#' @export
#' @examples
#' format_condition(NULL)              # returns {}
#' format_condition(c("a", "b", "c"))  # returns {a,b,c}
format_condition <- function(condition) {
    .must_be_character_vector(condition, null = TRUE)

    paste0("{", paste0(sort(condition), collapse = ","), "}")
}
