#' Test whether an object is a nugget
#'
#' Check if the given object is a nugget, i.e. an object created by
#' [nugget()]. If a `flavour` is specified, the function returns `TRUE` only
#' if the object is a nugget of the given flavour.
#'
#' Technically, nuggets are implemented as S3 objects. An object is considered
#' a nugget if it inherits from the S3 class `"nugget"`. It is a nugget of a
#' given flavour if it inherits from both the specified `flavour` class and
#' the `"nugget"` class.
#'
#' @param x An object to be tested.
#' @param flavour Optional character string specifying the required flavour of
#'   the nugget. If `NULL` (default), the function checks only whether `x` is
#'   a nugget of any flavour.
#'
#' @return A logical scalar: `TRUE` if `x` is a nugget (and of the specified
#'   flavour, if given), otherwise `FALSE`.
#'
#' @seealso [nugget()]
#' @author Michal Burda
#' @export
is_nugget <- function(x, flavour = NULL) {
    .must_be_character_scalar(flavour, null = TRUE)

    inherits(x, "nugget") &&
        (is.null(flavour) || inherits(x, flavour))
}
