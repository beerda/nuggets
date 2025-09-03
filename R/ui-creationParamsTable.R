creationParamsTable <- function(rules) {
    aa <- attributes(rules)
    fun <- paste0("Generated using the function [",
                  aa$call_function,
                  "()](https://beerda.github.io/nuggets/reference/",
                  aa$call_function,
                  ".html) with the following parameters:")
    fun <- markdown(fun)

    args <- lapply(aa$call_args, function(x) {
        markdown(paste0("```r\n",
                        paste(deparse(x), collapse = ""),
                        "\n```"))
        #if (is.character(x)) {
            #x <- paste0('"', x, '"')
        #} else if (is.numeric(x)) {
            #x <- format(x, scientific = FALSE)
        #} else if (is.logical(x)) {
            #x <- if (x) "TRUE" else "FALSE"
        #} else if (is.null(x)) {
            #x <- "NULL"
        #} else if (is.symbol(x)) {
            #x <- as.character(x)
        #} else {
            #x <- paste0("`", class(x)[1], "`")
        #}
        #paste(x, collapse = ", ")
    })
    names(args) <- names(aa$call_args)


    htmlrows <- list()
    for (i in seq_along(args)) {
        htmlrows[[i]] <- tags$tr(tags$td(paste(names(args)[i], "=")),
                                 tags$td(args[[i]]))
    }

    tagList(fun,
            br(),
            do.call(tags$table,
                    c(list(class = "info-table left", width = "100%"),
                      htmlrows)))
}
