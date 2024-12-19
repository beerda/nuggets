# Run expr and handle errors, warnings and messages.
# @return a list with two elements: result, comment. If expr results with error,
#       the result element is set to NULL. Comment contains all output, warnings
#       and messages
# @author Michal Burda
.quietly <- function(expr, name = NULL) {
    f <- function()  expr
    f2 <- quietly(safely(f))
    res <- f2()

    comment <- NULL
    if (nchar(res$output) > 0) {
        comment <- paste("output:", str_trim(res$output))
    }
    if (length(res$messages) > 0) {
        comment <- c(comment, paste("message:", str_trim(res$messages)))
    }
    if (length(res$warnings) > 0) {
        comment <- c(comment, paste("warning:", str_trim(res$warnings)))
    }
    if (!is.null(res$result$error)) {
        comment <- c(comment, paste("error:", str_trim(res$result$error$message)))
    }
    comment <- paste0(comment, collapse = "\n")

    list(result = res$result$result,
         comment = comment)
}
