infoTable <- function(df, header = FALSE, class = NULL, width = "100%") {
    trs <- lapply(seq_len(nrow(df)), function(i) {
        tags$tr(lapply(df[i, ], function(x) tags$td(x)))
    })

    head <- NULL
    if (header) {
        head <- tags$thead(
            tags$tr(lapply(colnames(df), function(x) tags$th(x)))
        )
    }

    tags$table(class = paste(c("info-table", class), collapse = " "),
               width = width,
               head,
               do.call(tags$tbody, trs))
}

