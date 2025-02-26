#' Check whether the given list of character vectors contains a list of valid
#' conditions.
#'
#' A valid condition is a character vector of predicates, where each predicate
#' corresponds to some column name of the related data frame. This function
#' checks whether the given list of character vectors `x`
#' contains only such predicates that can be found in column names of given
#' data frame `data`.
#'
#' Note that empty character vector is considered as a valid condition too.
#'
#' @param x a list of character vector
#' @param data a matrix or a data frame
#' @return a logical vector indicating whether each element of the list `x`
#'      contains a character vector such that all elements of that vector
#'      are column names of `data`
#' @seealso [remove_ill_conditions()]
#' @author Michal Burda
#' @examples
#' d <- data.frame(foo = 1:5, bar = 1:5, blah = 1:5)
#' is_condition(list("foo"), d)
#' is_condition(list(c("bar", "blah"), NULL, c("foo", "bzz")))
#' @export
is_condition <- function(x, data) {
    .must_be_list_of_characters(x, null_elements = TRUE)
    .must_be_matrix_or_data_frame(data)

    vapply(x,
           function(condition) all(condition %in% colnames(data)),
           logical(1))
}
