#' Shorten the predicates within a condition
#'
#' This function takes a character vector of conditions and shortens the
#' predicates within each condition using a specified method.
#'
#' Each value in `x` is a condition formatted as a string, e.g.,
#' `"{a=1,b=100,c=3}"` (see [format_condition()]). The function
#' shortens the predicates in each condition according to the specified
#' `method`. The available methods are:
#'
#' - `"letters"`: predicates are replaced with single letters from the
#'   English alphabet, starting with `A` for the first predicate;
#' - `"abbrev4"`: predicates are abbreviated to 4 characters using
#'   [abbreviate()] function;
#' - `"abbrev8"`: predicates are abbreviated to 8 characters using
#'   [abbreviate()] function;
#' - `"none"`: no shortening is applied, predicates remain unchanged.
#'
#' @param x a character vector of conditions, each formatted as a string
#'    (e.g., `"{a=1,b=100,c=3}"`).
#' @param method a character scalar specifying the method to use for
#'    shortening the predicates. It must be one of `"letters"`, `"abbrev4"`,
#'    or `"abbrev8"`. Default is `"letters"`.
#' @return A character vector of conditions with shortened predicates.
#' @seealso [format_condition()], [parse_condition()]
#' @author Michal Burda
#' @examples
#' shorten_condition(c("{a=1,b=100,c=3}", "{a=2}", "{b=100,c=3}"),
#'                   method = "letters")
#'
#' shorten_condition(c("{helloWorld=1}", "{helloWorld=2}", "{c=3, helloWorld=1}"),
#'                   method = "abbrev4")
#' @export
shorten_condition <- function(x,
                              method = "letters") {
    .must_be_character_vector(x, null = TRUE)
    .must_be_enum(method, c("letters", "abbrev4", "abbrev8", "none"))

    if (is.null(x)) {
        return(NULL)
    }
    if (length(x) == 0) {
        return(character(0))
    }
    if (method == "none") {
        return(x)
    }

    parsed <- parse_condition(x)
    predicates <- sort(unique(unlist(parsed)))

    if (method == "letters") {
        if (length(predicates) > length(LETTERS)) {
            cli_abort(c("The number of unique values in {.arg x} is greater than {length(LETTERS)}.",
                        "x" = "You can use {.fn shorten_condition} with {.val method = 'abbrev4'} or {.val method = 'abbrev8'} to shorten the condition."))
        }
        dict <- setNames(LETTERS[seq_along(predicates)], predicates)

    } else {
        minlen <- ifelse(method == "abbrev4", 4, 8)
        n <- var_names(predicates)
        n <- abbreviate(n, minlength = minlen)
        v <- values(predicates)
        v <- gsub(" ", "", v, fixed = TRUE)
        nx <- paste0(n, "=", v)
        dict <- setNames(nx, predicates)
    }

    res <- lapply(parsed, function(cond) { format_condition(dict[cond]) })

    unlist(res, use.names = FALSE)
}
