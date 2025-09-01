formatRulesForTable <- function(rules, meta) {
    for (i in seq_len(nrow(meta))) {
        col <- meta$data_name[i]
        if (meta$type[i] == "condition") {
            rules[[col]] <- highlightCondition(rules[[col]])
        } else if (meta$type[i] == "numeric") {
            if (!is.na(meta$round[i])) {
                rules[[col]] <- round(rules[[col]], meta$round[i])
            }
        }
    }

    if (is.null(rules$id)) {
        rules <- rules[, meta$data_name, drop = FALSE]
        colnames(rules) <- meta$short_name
    } else {
        rules <- rules[, c("id", meta$data_name), drop = FALSE]
        colnames(rules) <- c("id", meta$short_name)

    }

    rules
}
