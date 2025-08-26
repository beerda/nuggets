rulesTableModule <- function(id, data, meta) {
    data <- data[, c("id", meta$data_name), drop = FALSE]
    colnames(data) <- c("id", meta$short_name)

    for (i in seq_len(nrow(meta))) {
        col <- meta$short_name[i]
        if (meta$type[i] == "condition") {
            data[[col]] <- highlightCondition(data[[col]])
        } else if (meta$type[i] == "numeric") {
            if (!is.na(meta$round[i])) {
                data[[col]] <- round(data[[col]], meta$round[i])
            }
        }
    }

    data$id <- NULL

    list(ui = function() {
            DT::dataTableOutput(NS(id, "table"))
        },

        server = function(selectionReactive) {
            moduleServer(id, function(input, output, session) {
                output$table <- renderDT({
                    sel <- selectionReactive()
                    d <- data[sel, , drop = FALSE]
                    datatable(d,
                              options = list(pageLength = 10,
                                             autoWidth = FALSE,
                                             searching = FALSE,
                                             scrollX = TRUE),
                              escape = FALSE,
                              rownames = FALSE,
                              selection = "none",
                              filter = "none")
                })
            })
        }
    )
}
