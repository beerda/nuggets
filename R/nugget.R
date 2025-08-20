#' Create a nugget object of given flavour
#'
#' @param x an object with rules, typically a tibble or a data frame.
#' @param flavour a character string specifying the flavour of the nugget or NULL.
#' @param call_function a function name that created the nugget.
#' @param call_args a list of function arguments that were used to create the nugget.
#' @return A nugget object of the specified flavour, i.e., a tibble object that is
#'     a subclass of `flavour` and `nugget` classes.
#' @seealso [is_nugget()]
#' @author Michal Burda
#' @export
nugget <- function(x,
                   flavour,
                   call_function,
                   call_args) {
    .must_be_character_scalar(flavour, null = TRUE)
    .must_be_character_scalar(call_function)
    .must_be_list(call_args)

    if (is.null(x) || is.data.frame(x)) {
        x <- as_tibble(x)
    }

    class(x) <- c("nugget", class(x))
    if (!is.null(flavour)) {
        class(x) <- c(flavour, class(x))
    }

    attr(x, "call_function") <- call_function
    attr(x, "call_args") <- call_args

    x
}
