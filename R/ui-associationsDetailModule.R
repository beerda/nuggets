associationsDetailModule <- function(id, data, meta) {
    for (i in seq_len(nrow(meta))) {
        col <- meta$short_name[i]
        if (meta$type[i] == "condition") {
            data[[paste0("highlighted-", col)]] <- highlightCondition(data[[col]])
        }
    }

    list(ui = function() {
            fluidRow(
                column(width = 4,
                    panel(heading = "Selected Rule",
                        uiOutput(NS(id, "selectedRule"))
                    ),
                    panel(heading = "Settings")
                ),
                column(width = 8,
                    panel(heading = "Ancestors",
                        tableOutput(NS(id, "ancestorTable")),
                        plotOutput(NS(id, "ancestorPlot"), height = "500px")
                    )
                )
            )
        },

        server = function(selectionReactive) {
            moduleServer(id, function(input, output, session) {
                output$selectedRule <- renderUI({
                    cat("zde1\n")
                    str(selectionReactive())

                    id <- selectionReactive()
                    if (is.null(id)) {
                        return(NULL)
                    }
                    res <- data[data$id == id, , drop = FALSE]

                    div(style = 'display: flex; flex-wrap: wrap; align-items: center; gap: 20px',
                        div(HTML(res[["highlighted-antecedent"]])),
                        div(icon("arrow-right-long"), tags$span(style = "width: 10px; display:inline-block;"), HTML(res[["highlighted-consequent"]]))
                    )
                })

                output$ancestorPlot <- renderPlot({
                    cat("zde1\n")
                    str(selectionReactive())
                    id <- selectionReactive()
                    if (is.null(id)) {
                        return(NULL)
                    }


                })
            })
        }
    )
}
