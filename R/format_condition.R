#'
#' @return
#' @author Michal Burda
#' @export
format_condition <- function(condition) {
    .must_be_character_vector(condition, null = TRUE)

    paste0("{", paste0(condition, collapse = ","), "}")
}
