#' Check if an object is logical or numeric with only 0s and 1s
#'
#' @param x An R object to check.
#' @return A logical value indicating whether `x` is logical or numeric
#'      containing only 0s and 1s.
#' @author Michal Burda
#' @export
#' @examples
#' is_logicalish(c(TRUE, FALSE, NA))        # returns TRUE
#' is_logicalish(c(0, 1, 1, 0, NA))         # returns TRUE
#' is_logicalish(c(0.0, 1.0, NA))           # returns TRUE
#' is_logicalish(c(0, 0.5, 1))              # returns FALSE
#' is_logicalish("TRUE")                    # returns FALSE
is_logicalish <- function(x) {
    is.logical(x) || (is.numeric(x) && all(x == 0 | x == 1, na.rm = TRUE))
}
