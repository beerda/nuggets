rulebaseTable <- function(rules) {
    tags$table(class = "info-table", width = "100%",
        tags$tr(tags$td("Number of rules:"), tags$td(nrow(rules))),
        tags$tr(tags$td("Number of columns:"), tags$td(ncol(rules)))
    )
}
