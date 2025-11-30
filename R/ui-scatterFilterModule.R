#######################################################################
# nuggets: An R framework for exploration of patterns in data
# Copyright (C) 2025 Michal Burda
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


scatterFilterModule <- function(id, rules, meta) {
    choices <- meta$data_name[meta$scatter]
    if (length(choices) < 3) {
        stop("Need at least three numeric attributes with scatter=TRUE in meta to use scatter filter.")
    }

    list(ui = function() {
            filterTabPanel(title = "XY-Scatter",
                           value = "XY-Scatter",
                           info = "Select rules by drawing a rectangle around them on the plot.",
                shiny::plotOutput(shiny::NS(id, "scatterPlot"), brush = shiny::NS(id, "scatterPlotBrush")),
                htmltools::br(),
                shiny::selectInput(shiny::NS(id, "scatterX"), "X-axis", choices = choices, selected = choices[1]),
                shiny::selectInput(shiny::NS(id, "scatterY"), "Y-axis", choices = choices, selected = choices[2]),
                shiny::selectInput(shiny::NS(id, "scatterColor"), "Color", choices = choices, selected = choices[3]),
                htmltools::hr(),
                shiny::actionButton(shiny::NS(id, "resetButton"), "Reset"),
                shiny::actionButton(shiny::NS(id, "resetAllButton"), "Reset all")
            )
        },

        server = function(reset_all_trigger) {
            shiny::moduleServer(id, function(input, output, session) {
                output$scatterPlot <- shiny::renderPlot({
                    res <- rules
                    ggplot(res) +
                        aes(x = .data[[input$scatterX]],
                            y = .data[[input$scatterY]],
                            color = .data[[input$scatterColor]]) +
                        geom_point(alpha = 0.5) +
                        scale_color_continuous(type = "viridis") +
                        theme(legend.position = "bottom")
                }, res = 96)

                shiny::observeEvent(input$resetButton, {
                    session$resetBrush(shiny::NS(id, "scatterPlotBrush"))
                })

                shiny::observeEvent(input$resetAllButton, {
                    reset_all_trigger(Sys.time())
                })
            })
        },

        filter = function(input) {
            brush <- input[[shiny::NS(id, "scatterPlotBrush")]]
            if (is.null(brush)) {
                return(rep(TRUE, nrow(rules)))
            }

            brush$mapping <- lapply(brush$mapping, function(x) {
                # workaround: brush works bad with the way the output$scatterPlot
                # is created using .data[[input$scatterX]] etc.
                gsub("\\.data\\[\\[\"(.*)\"\\]\\]", "\\1", x)
            })
            res <- shiny::brushedPoints(rules, brush, allRows = TRUE)

            res$selected_
        },

        reset = function(session) {
            session$resetBrush(shiny::NS(id, "scatterPlotBrush"))
        }
    )
}
