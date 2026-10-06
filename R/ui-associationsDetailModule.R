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
    ns <- shiny::NS(id)

    for (i in seq_len(nrow(meta))) {
        col <- meta$data_name[i]
        if (meta$type[i] == "condition") {
            rules[[paste0("highlighted-", col)]] <- highlightCondition(rules[[col]])
        }
    }

    ancestorsTab <- NULL
    if (!is.null(data)) {
        ancestorsTab <- shiny::tabPanel("Ancestors",
                            DT::dataTableOutput(shiny::NS(id, "ancestorTable")),
                            htmltools::br(),
                            shiny::plotOutput(shiny::NS(id, "ancestorPlot"), height = "500px")
                        )
    }

    choicesForSize <- c("coverage", "confidence", "lift")
    choicesForFill <- c("coverage", "confidence", "lift")
    choicesForLinewidth <- c("coverage", "confidence", "lift")

    list(ui = function() {
            shiny::fluidRow(
                shiny::column(width = 4,
                    shinyWidgets::panel(heading = "Selected Rule",
                        shiny::uiOutput(shiny::NS(id, "selectedRule"))
                    ),
                    shinyWidgets::panel(heading = "Settings",
                        shiny::conditionalPanel(
                            condition = sprintf("input['%s'] == 'Contingency Table'", ns("ruleDetailTabs")),
                            "No settings available."
                        ),
                        shiny::conditionalPanel(
                            condition = sprintf("input['%s'] == 'Ancestors'", ns("ruleDetailTabs")),
                            shiny::radioButtons(shiny::NS(id, "shorteningRadio"),
                                         "Abbreviation of predicates in the antecedent",
                                         choices = c("letters", "abbrev4", "abbrev8", "none"),
                                         selected = "letters",
                                         inline = TRUE),
                            shiny::selectInput(shiny::NS(id, "plotSize"), "Node size", choices = choicesForSize, selected = "coverage"),
                            shiny::selectInput(shiny::NS(id, "plotFill"), "Node fill", choices = choicesForFill, selected = "confidence"),
                            shiny::selectInput(shiny::NS(id, "plotLinewidth"), "Line width", choices = choicesForLinewidth, selected = "confidence")
                        )
                    )
                ),
                shiny::column(width = 8,
                    shinyWidgets::panel(heading = "Rule Detail",
                        shiny::tabsetPanel(
                            id = shiny::NS(id, "ruleDetailTabs"),
                            shiny::tabPanel("Contingency Table",
                                infoBox(paste("The contingency table shows how many data rows contain:",
                                              "both antecedent and consequent, antecedent only, consequent only, or neither.",
                                              "'obs' is the observed count, 'exp' is the expected count if antecedent and consequent were independent, ",
                                              "and 'diff' is the difference between observed and expected counts.",
                                              "Dashed lines in the plot indicate the expected values if antecedent and consequent were independent.")),
                                shiny::fluidRow(
                                    shiny::column(width = 6,
                                        shiny::plotOutput(shiny::NS(id, "contingencyPlot"), height = "200px")
                                    ),
                                    shiny::column(width = 6,
                                        shiny::tableOutput(shiny::NS(id, "contingencyTable"))
                                    )
                                )
                            ),
                            ancestorsTab
                        )
                    )
                )
            )
        },

        server = function(selectionReactive) {
            shiny::moduleServer(id, function(input, output, session) {
                selectedRule <- shiny::reactive({
                    ruleId <- selectionReactive()
                    shiny::req(ruleId)

                    rules[rules$id == ruleId, , drop = FALSE]
                })

                output$selectedRule <- shiny::renderUI({
                    rule <- selectedRule()
                    shiny::req(rule)

                    htmltools::div(style = 'display: flex; flex-wrap: wrap; align-items: center; gap: 20px',
                        htmltools::div(htmltools::HTML(rule[["highlighted-antecedent"]])),
                        htmltools::div(shiny::icon("arrow-right-long"),
                                       htmltools::tags$span(style = "width: 10px; display:inline-block;"),
                                       htmltools::HTML(rule[["highlighted-consequent"]]))
                    )
                })

                output$contingencyPlot <- shiny::renderPlot({
                    rule <- selectedRule()
                    shiny::req(rule)

                    plot_contingency(rule)
                }, res = 96)

                output$contingencyTable <- shiny::renderTable({
                    rule <- selectedRule()
                    shiny::req(rule)

                    n <- rule$pp + rule$pn + rule$np + rule$nn
                    exp_pp <- (rule$pp + rule$pn) * (rule$pp + rule$np) / n
                    exp_pn <- (rule$pp + rule$pn) * (rule$pn + rule$nn) / n
                    exp_np <- (rule$np + rule$nn) * (rule$pp + rule$np) / n
                    exp_nn <- (rule$np + rule$nn) * (rule$pn + rule$nn) / n

                    pp_text <- .format_contingency_table_cell(rule$pp, exp_pp, n)
                    pn_text <- .format_contingency_table_cell(rule$pn, exp_pn, n)
                    np_text <- .format_contingency_table_cell(rule$np, exp_np, n)
                    nn_text <- .format_contingency_table_cell(rule$nn, exp_nn, n)

                    res <- data.frame(c1 = c(pp_text, np_text),
                                      c2 = c(pn_text, nn_text))
                    rownames(res) <- c("<b>ante</b>", "<b>\u00acante</b>")
                    colnames(res) <- c("<b>conseq</b>", "<b>\u00acconseq</b>")

                    res
                }, rownames = TRUE, sanitize.text.function = identity, sanitize.rownames.function = identity, sanitize.colnames.function = identity)

                if (!is.null(data)) {
                    ancestors <- shiny::reactive({
                        shiny::req(input$shorteningRadio)
                        rule <- selectedRule()
                        shiny::req(rule)

                        res <- dig_ancestors(rule, data)
                        res <- res[order(res$antecedent_length), , drop = FALSE]

                        res
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
                        shiny::req(input$shorteningRadio,
                                   input$plotSize,
                                   input$plotFill,
                                   input$plotLinewidth)
                        res <- ancestors()
                        shiny::req(res)

                        res$abbrev <- shorten_condition(res$antecedent, method = input$shorteningRadio)
                        res$label = paste(res$abbrev,
                                          "\nconf:",
                                          format(round(res$confidence, 2), nsmall = 2))

                        ggplot(res) +
                            aes(condition = .data$antecedent,
                                fill = .data[[input$plotFill]],
                                linewidth = .data[[input$plotLinewidth]],
                                size = .data[[input$plotSize]],
                                label = .data$label) +
                            geom_diamond(nudge_y = 0.25) +
                            scale_x_continuous(expand = expansion(mult = c(0, 0), add = c(0.5, 0.5)))
                    }, res = 96)
                }
            })
        }
    )
}


.format_contingency_table_cell <- function(obs, exp, n) {
    dif <- obs - exp
    clr <- ifelse(dif > 0, "green", ifelse(dif < 0, "red", "black"))

    paste0("obs:&nbsp;", obs, "&nbsp;(", round(100 * obs / n, 1), "%)<br>",
           '<span class="gray">exp:&nbsp;', round(exp, 1), " (", round(100 * exp / n, 1), "%)</span><br>",
           '<span class="', clr, '">diff:&nbsp;', round(dif, 1), " (", round(100 * dif / n, 1), "%)</span>")
}
