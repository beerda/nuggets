infoTable <- function(labels, values) {
    tab <- data.frame(x = labels,
                      y = values,
                      stringsAsFactors = FALSE)
    trs <- list()
    for (i in seq_len(nrow(tab))) {
        trs <- c(trs,
                 list(tags$tr(tags$td(tab[i, 1]),
                              tags$td(tab[i, 2]))))
    }
    do.call(tags$table, c(list(class = "info-table", width = "100%"), trs))
}

