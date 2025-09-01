# @param actions a list with the following elements:
#        - `title`: the title of the button (displayed on hover);
#        - `icon`: the icon of the button (a FontAwesome icon name).
rulesTableModule <- function(id, rules, meta, action) {
    rules <- rules[, c("id", meta$data_name), drop = FALSE]
    colnames(rules) <- c("id", meta$short_name)

    for (i in seq_len(nrow(meta))) {
        col <- meta$short_name[i]
        if (meta$type[i] == "condition") {
            rules[[col]] <- highlightCondition(rules[[col]])
        } else if (meta$type[i] == "numeric") {
            if (!is.na(meta$round[i])) {
                rules[[col]] <- round(rules[[col]], meta$round[i])
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
                    d <- rules[sel, , drop = FALSE]

                    if (!is.null(action)) {
                        buttons <- vapply(X = d$id,
                                          FUN.VALUE = character(1),
                                          USE.NAMES = FALSE,
                                          FUN = function(id_) {
                            paste0('<div class="btn-group" style="width: 25px;" role="group">',
                                   '<button ',
                                       'class="btn btn-sm" ',
                                       'type="button" ',
                                       'data-toggle="tooltip" ',
                                       'data-placement="top" ',
                                       'style="margin: 0" ',
                                       'title="', action$title, '" ',
                                       'onClick="Shiny.setInputValue(\'', ns("selected"), '\', ', id_, ', { priority: \'event\' });"',
                                       '>',
                                       '<i class="fa fa-', action$icon, '"></i>',
                                       '</button>',
                                   '</div>')
                        })
                        d <- cbind(data.frame(" " = buttons,
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

                reactive({ input$selected })
            })
        }
    )
}
