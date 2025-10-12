callDataTable <- function(rules, meta) {
    call_data <- attr(rules, "call_data")
    call_args <- attr(rules, "call_args")
    cn <- call_data$data_colnames

    d <- tibble("column name" = cn)

    for (cond in meta$data_name[meta$type == "condition"]) {
        d[[cond]] <- lapply(cn, function(col) {
            if (col %in% call_args[[cond]]) tags$span(style = "color: limegreen;", "\u2714") else ""
        })
    }

    if (!is.null(call_args$disjoint)) {
        d[["disjoint"]] <- call_args$disjoint
    }

    infoTable(d, header = TRUE, class = "center hlrows")
}
