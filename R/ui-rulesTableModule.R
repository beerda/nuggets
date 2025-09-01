# @param actions a list of action buttons to be displayed on each row in the
#        table. It should be a list of lists, where each inner list has the
#        following elements:
#        - `title`: the title of the button (displayed on hover);
#        - `icon`: the icon of the button (a FontAwesome icon name);
#        - `action`: the action name (used to create the input ID).
rulesTableModule <- function(id, data, meta, actions) {
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

    list(ui = function() {
            DT::dataTableOutput(NS(id, "table"))
        },

        server = function(selectionReactive) {
            moduleServer(id, function(input, output, session) {
                ns <- session$ns

                output$table <- renderDT({
                    sel <- selectionReactive()
                    d <- data[sel, , drop = FALSE]

                    if (!is.null(actions)) {
                        actions <- vapply(X = d$id,
                                          FUN.VALUE = character(1),
                                          USE.NAMES = FALSE,
                                          FUN = function(id_) {
                            buttons <- sapply(actions, function(act) {
                                paste0('<button ',
                                       'class="btn btn-sm" ',
                                       'type="button" ',
                                       'data-toggle="tooltip" ',
                                       'data-placement="top" ',
                                       'style="margin: 0" ',
                                       'title="', act$title, '" ',
                                       'onClick="Shiny.setInputValue(\'', ns("id"), '\', ', id_, ', { priority: \'event\' });"',
                                       '>',
                                       '<i class="fa fa-', act$icon, '"></i>',
                                       '</button>')
                            })
                            paste0('<div class="btn-group" style="width: 25px;" role="group">',
                                   paste0(buttons, collapse = ''),
                                   '</div>')
                        })
                        d <- cbind(data.frame(" " = actions,
                                              check.names = FALSE,
                                              stringsAsFactors = FALSE),
                                   d)
                    }

                    d$id <- NULL

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

                reactive({ input$id })
            })
        }
    )
}
