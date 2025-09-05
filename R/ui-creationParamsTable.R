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
