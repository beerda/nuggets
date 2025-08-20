#' Test if the object is a nugget
#'
#' This function returns TRUE if the object is a nugget. If flavour is
#' specified, the function returns TRUE only if the object is a nugget of
#' the specified flavour.
#'
#' @param x an object to be tested
#' @param flavour a character string specifying the flavour of the nugget.
#' @return A logical value indicating whether the object is a nugget.
#' @author Michal Burda
#' @export
is_nugget <- function(x, flavour = NULL) {
    .must_be_character_scalar(flavour, null = TRUE)

    inherits(x, "nugget") &&
        (is.null(flavour) || inherits(x, flavour))
}
