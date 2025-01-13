#' Convert character vector of conditions into a list of vectors of predicates
#'
#' Function takes a character vector of conditions and returns a list of vectors
#' of predicates. Each element of the list corresponds to one condition. The
#' condition is a string with predicates separated by commas and enclosed in
#' curly braces, as returned by [format_condition()]. The function splits the
#' condition string into a vector of predicates.
#'
#' If multiple vectors of conditions are passed, each of them is processed
#' separately and the result is merged into a single list element-wisely. If
#' the lengths of the vectors are different, the shorter vectors are recycled.
#'
#' @param ... character vectors of conditions to be parsed.
#' @param .sort a flag indicating whether to sort the predicates in the result.
#' @return a list of vectors of predicates with each element corresponding to one
#'      condition.
#' @author Michal Burda
#' @examples
#' parse_condition(c("{a}", "{x=1, z=2, y=3}", "{}"))
#' parse_condition(c("{b}", "{x=1, z=2, y=3}", "{q}", "{}"),
#'                 c("{a}", "{v=10, w=11}",    "{}",  "{r,s,t}"))
#'
#' @export
parse_condition <- function(...,
                            .sort = TRUE) {
    .must_be_flag(.sort)

    dots <- list(...)

    if (length(dots) <= 0) {
        return(character(0))
    }

    test <- sapply(dots, is.character)
    if (!isTRUE(all(test))) {
        types <- sapply(dots, function(i) class(i)[1])
        details <- paste0("Argument ", seq_along(types), " is a {.cls ", types, "}.")
        details <- details[!test]
        cli_abort(c("Arguments {.arg ...} must be character vectors.",
                    ..error_details(details)),
                  call = current_env())
    }

    if (length(dots) > 1) {
        res <- lapply(dots, .parse_condition)
        res <- do.call(mapply, c(list(c), res, list(SIMPLIFY = FALSE)))
    } else {
        res <- .parse_condition(dots[[1]])
    }

    res <- lapply(res, unique)

    if (.sort) {
        res <- lapply(res, sort, na.last = TRUE)
    }

    res
}


.parse_condition <- function(x) {
    res <- x
    res <- sub("^\\s*\\{", "", res)
    res <- sub("\\}\\s*$", "", res)

    strsplit(res, "\\s*,\\s*")
}
