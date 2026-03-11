#######################################################################
# nuggets: An R framework for exploration of patterns in data
# Copyright (C) 2026 Michal Burda
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program. If not, see <https://www.gnu.org/licenses/>.
#######################################################################


.create_tree_def_from_variables <- function(x, root_name) {
    val <- unique(x)
    vid <- paste0("v", seq_along(val))

    if (is.null(val) || length(val) <= 0) {
        return(data.frame())
    }

    data.frame(rid = "##root##",
               rname = root_name,
               vid = vid,
               value = val,
               stringsAsFactors = FALSE)
}


variableFilterModule <- function(id, x, meta) {
    x[is.na(x)] <- "(NA)"
    root_name <- "value"
    def <- .create_tree_def_from_variables(x, root_name)
    histogramPlot <- NULL
    tree <- NULL
    g <- NULL
    if (nrow(def) > 0) {
        histogramPlot <- shiny::plotOutput(shiny::NS(id, "histogramPlot"))
        tree <- shinyWidgets::create_tree(def,
                            levels = c("rname", "value"),
                            levels_id = c("rid", "vid"))

        g <- ggplot(data.frame(x = x)) +
            aes(y = x) +
            geom_bar(fill = "white", color = "black") +
            scale_x_continuous(name = "number of rules",
                               sec.axis = sec_axis(~ . * 100 / length(x), name = "% of rules")) +
            labs(y = NULL,
                 x = tolower(meta$long_name), y = "number of rules")
    }

    list(ui = function() {
            filterTabPanel(title = meta$long_name,
                           value = meta$data_name,
                           info = paste0("Filter the rules by choosing the values for ",
                                        tolower(meta$long_name), "."),
                histogramPlot,
                shinyWidgets::treeInput(shiny::NS(id, "tree"),
                          label = tolower(meta$long_name),
                          choices = tree,
                          selected = root_name,
                          returnValue = "id",
                          closeDepth = 1),
                htmltools::hr(),
                shiny::actionButton(shiny::NS(id, "resetButton"), "Reset"),
                shiny::actionButton(shiny::NS(id, "resetAllButton"), "Reset all")
            )
        },

        server = function(reset_all_trigger) {
            shiny::moduleServer(id, function(input, output, session) {
                shiny::observeEvent(input$resetButton, {
                    shinyWidgets::updateTreeInput("tree", selected = def$vid, session = session)
                })

                shiny::observeEvent(input$resetAllButton, {
                    reset_all_trigger(Sys.time())
                })

                if (nrow(def) > 0) {
                    output$histogramPlot <- shiny::renderPlot({ g }, res = 96)
                }
            })
        },

        filter = function(input) {
            val <- input[[shiny::NS(id, "tree")]]

            res <- NULL
            if (is.null(val)) {
                res <- rep(FALSE, length(x))
            } else {
                ids <- grep("^v", val, value = TRUE)
                res <- x %in% def$value[match(ids, def$vid)]
            }

            res
        },

        reset = function(session) {
            shinyWidgets::updateTreeInput(shiny::NS(id, "tree"), selected = def$vid, session = session)
        }
    )
}
