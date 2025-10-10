rulebaseTable <- function(rules, meta) {
    conds <- meta[meta$type == "condition", , drop= FALSE]
    args <- lapply(seq_len(nrow(conds)), function(i) {
        data_name <- conds$data_name[i]
        long_name <- tolower(conds$long_name[i])
        uni <- rules[[data_name]]
        uni <- length(unique(uni))
        tags$tr(tags$td(paste0("Number of distinct ", long_name, "s:")),
                tags$td(uni))
    })

    args <- c(list(class = "info-table",
                   width = "100%",
                   tags$tr(tags$td("Number of rules:"), tags$td(nrow(rules))),
                   tags$tr(tags$td("Number of columns:"), tags$td(ncol(rules)))),
              args)

    do.call(tags$table, args)
}
