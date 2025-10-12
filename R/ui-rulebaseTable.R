rulebaseTable <- function(rules, meta) {
    conds <- meta[meta$type == "condition", , drop= FALSE]
    distinct_condition_names <- paste0("Number of distinct ", tolower(conds$long_name), "s:")
    distinct_condition_counts <- vapply(conds$data_name, function(col) {
        length(unique(rules[[col]]))
    }, integer(1))

    df <- data.frame(c("Number of rules:", "Number of columns:", distinct_condition_names),
                     c(nrow(rules), ncol(rules), distinct_condition_counts),
                     stringsAsFactors = FALSE)
    infoTable(df, class = "hlrows")
}
