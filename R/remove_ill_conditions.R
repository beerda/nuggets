#' From a given list remove those elements that are not valid conditions.
#'
#' A valid condition is a character vector of predicates, where each predicate
#' corresponds to some column name of the related data frame.
#' (An empty character vector is considered as a valid condition too.)
#'
#' @param x a list of character vector
#' @param data a matrix or a data frame
#' @return a list of elements of `x` that are valid conditions.
#' @seealso [is_condition()]
#' @author Michal Burda
#' @export
remove_ill_conditions <- function(x, data) {
    .must_be_list_of_characters(x, null_elements = TRUE)
    .must_be_matrix_or_data_frame(data)

    x[is_condition(x, data)]
}
