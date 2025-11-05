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


associationsDetailModule <- function(id, rules, meta, data) {
    for (i in seq_len(nrow(meta))) {
        col <- meta$data_name[i]
        if (meta$type[i] == "condition") {
            rules[[paste0("highlighted-", col)]] <- highlightCondition(rules[[col]])
        }
    }

    list(ui = function() {
            shiny::fluidRow(
                shiny::column(width = 4,
                    shinyWidgets::panel(heading = "Selected Rule",
                        shiny::uiOutput(shiny::NS(id, "selectedRule"))
                    ),
                    shinyWidgets::panel(heading = "Settings",
                        shiny::radioButtons(shiny::NS(id, "shorteningRadio"),
                                     "Abbreviation of predicates",
                                     choices = c("letters", "abbrev4", "abbrev8", "none"),
                                     selected = "letters",
                                     inline = TRUE)
                    )
                ),
                shiny::column(width = 8,
                    shinyWidgets::panel(heading = "Ancestors",
                        DT::dataTableOutput(shiny::NS(id, "ancestorTable")),
                        htmltools::br(),
                        shiny::plotOutput(shiny::NS(id, "ancestorPlot"), height = "500px")
                    )
                )
            )
        },

        server = function(selectionReactive) {
            shiny::moduleServer(id, function(input, output, session) {
                ancestors <- shiny::reactive({
                    shiny::req(input$shorteningRadio)
                    ruleId <- selectionReactive()
                    shiny::req(ruleId)

                    rule <- rules[rules$id == ruleId, , drop = FALSE]
                    ante <- parse_condition(rule$antecedent)[[1]]
                    cons <- parse_condition(rule$consequent)[[1]]
                    res <- dig_associations(data,
                                            antecedent = all_of(ante),
                                            consequent = all_of(cons),
                                            min_length = 0,
                                            max_length = Inf,
                                            min_coverage = 0,
                                            min_support = 0,
                                            min_confidence = 0,
                                            max_results = Inf)
                    res <- res[order(res$antecedent_length), , drop = FALSE]

                    res
                })

                output$selectedRule <- shiny::renderUI({
                    ruleId <- selectionReactive()
                    shiny::req(ruleId)

                    res <- rules[rules$id == ruleId, , drop = FALSE]

                    htmltools::div(style = 'display: flex; flex-wrap: wrap; align-items: center; gap: 20px',
                        htmltools::div(htmltools::HTML(res[["highlighted-antecedent"]])),
                        htmltools::div(shiny::icon("arrow-right-long"), htmltools::tags::span(style = "width: 10px; display:inline-block;"), htmltools::HTML(res[["highlighted-consequent"]]))
                    )
                })

                output$ancestorTable <- DT::renderDT({
                    shiny::req(input$shorteningRadio)
                    res <- ancestors()
                    shiny::req(res)

                    abbrev <- shorten_condition(res$antecedent, method = input$shorteningRadio)
                    res <- formatRulesForTable(res, meta)
                    nn <- colnames(res)
                    res$abbrev <- highlightCondition(abbrev)
                    res <- res[, c("abbrev", nn), drop = FALSE]

                    DT::datatable(res,
                              options = list(paging = FALSE,
                                             autoWidth = FALSE,
                                             searching = FALSE,
                                             scrollX = TRUE,
                                             info = FALSE),
                              escape = FALSE,
                              rownames = FALSE,
                              selection = "none",
                              filter = "none")
                })

                output$ancestorPlot <- shiny::renderPlot({
                    shiny::req(input$shorteningRadio)
                    res <- ancestors()
                    shiny::req(res)

                    res$abbrev <- shorten_condition(res$antecedent, method = input$shorteningRadio)
                    res$label = paste(res$abbrev,
                                      "\nconf:",
                                      format(round(res$confidence, 2), nsmall = 2))

                    ggplot(res) +
                        aes(condition = .data$antecedent,
                            fill = .data$confidence,
                            linewidth = .data$confidence,
                            size = .data$coverage,
                            label = .data$label) +
                        geom_diamond(nudge_y = 0.25) +
                        scale_x_continuous(expand = expansion(mult = c(0, 0), add = c(0.5, 0.5)))
                }, res = 96)
            })
        }
    )
}
