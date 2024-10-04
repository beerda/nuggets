#' Format condition - convert a character vector to character scalar
#'
#' Function takes a character vector of predicates and returns a formatted condition.
#'
#' @param condition a character vector
#' @return a character scalar
#' @author Michal Burda
#' @export
#' @examples
#' format_condition(NULL)              # returns {}
#' format_condition(c("a", "b", "c"))  # returns {a,b,c}
format_condition <- function(condition) {
    .must_be_character_vector(condition, null = TRUE)

    paste0("{", paste0(sort(condition), collapse = ","), "}")
}
