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

    # do not present arguments containing variable names as usual values
    for (x in c("x")) {
        if (!is.null(args[[x]])) {
            args[[x]] <- markdown(paste0("```r\n",
                                         paste(aa$call_args[[x]], collapse = ""),
                                         "\n```"))
        }
    }

    htmlrows <- lapply(seq_along(args), function(i) {
        tags$tr(tags$td(paste(names(args)[i], "=")),
                tags$td(args[[i]]))
    })

    tagList(fun,
            br(),
            do.call(tags$table,
                    c(list(class = "info-table left", width = "100%"),
                      htmlrows)))
}
