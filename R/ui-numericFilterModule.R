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


numericFilterModule <- function(id, x, meta) {
    int <- meta$type == "integer"

    special <- NULL
    if (any(x == -Inf, na.rm = TRUE)) {
        special <- c(special, "-Inf")
    }
    if (any(is.na(x))) {
        special <- c(special, "NA")
    }
    if (any(is.nan(x), na.rm = TRUE)) {
        special <- c(special, "NaN")
    }
    if (any(x == Inf, na.rm = TRUE)) {
        special <- c(special, "Inf")
    }

    digits <- NULL
    if (int) {
        digits <- 0
        x <- as.integer(x)
    } else if (!is.na(meta$round)) {
        digits <- meta$round
        x <- as.numeric(x)
    }

    finx <- x
    finx <- finx[!is.na(finx)]
    finx <- finx[!is.nan(finx)]
    finx <- finx[is.finite(finx)]

    rng <- bound_range(finx,
                       digits = digits,
                       na_rm = TRUE)

    summaryTable <- quantile(finx, probs = seq(0, 1, 0.25), names = FALSE)
    summaryTable <- as.data.frame(t(summaryTable))
    colnames(summaryTable) <- c("min", "Q1", "median", "Q3", "max")

    minX <- min(finx)
    maxX <- max(finx)

    g <- ggplot(data.frame(x = finx)) + aes(x = x)
    if (int) {
        g <- g + geom_bar()
    } else {
        g <- g + geom_histogram(bins = 30, fill = "white", color = "black")
    }

    list(ui = function() {
            specialCheckboxInput <- NULL;
            if (!is.null(special)) {
                specialCheckboxInput <- shiny::checkboxGroupInput(shiny::NS(id, "special"),
                                                          label = "special values",
                                                          choices = special,
                                                          selected = special,
                                                          inline = TRUE)
            }

            filterTabPanel(title = meta$long_name,
                           value = meta$data_name,
                           info = paste0("Filter the rules by choosing a range of values for ",
                                         tolower(meta$long_name), "."),
                shiny::tableOutput(shiny::NS(id, "summaryTable")),
                shiny::plotOutput(shiny::NS(id, "histogramPlot")),
                shiny::sliderInput(shiny::NS(id, "slider"),
                            label = tolower(meta$long_name),
                            min = rng[1],
                            max = rng[2],
                            step = if (int) 1 else NULL,
                            value = rng,
                            round = FALSE,
                            width = "100%"),
                specialCheckboxInput,
                htmltools::hr(),
                shiny::actionButton(shiny::NS(id, "resetButton"), "Reset"),
                shiny::actionButton(shiny::NS(id, "resetAllButton"), "Reset all")
            )
        },

        server = function(reset_all_trigger) {
            shiny::moduleServer(id, function(input, output, session) {
                output$summaryTable <- shiny::renderTable({
                    summaryTable
                }, width = "100%", bordered = TRUE, striped = TRUE, align = "c", digits = 2)

                output$histogramPlot <- shiny::renderPlot({
                    shiny::req(input$slider)

                    val <- input$slider
                    border <- val
                    if (int) {
                        border[1] <- border[1] - 0.5
                        border[2] <- border[2] + 0.5
                    }
                    if (val[1] > minX) {
                        g <- g +
                            geom_rect(xmin = -Inf, xmax = border[1], ymin = -Inf, ymax = Inf, fill = "gray", alpha = 0.01) +
                            geom_vline(xintercept = border[1], linetype = "dashed", color = "red")
                    }
                    if (val[2] < maxX) {
                        g <- g +
                            geom_rect(xmin = border[2], xmax = Inf, ymin = -Inf, ymax = Inf, fill = "gray", alpha = 0.01) +
                            geom_vline(xintercept = border[2], linetype = "dashed", color = "red")
                    }

                    if (int) {
                        g <- g + scale_x_continuous(breaks = sort(unique(finx)))
                    } else {
                        g <- g + scale_x_continuous()
                    }

                    g + scale_y_continuous(name = "number of rules",
                                           sec.axis = sec_axis(~ . * 100 / length(x), name = "% of rules")) +
                        labs(x = tolower(meta$long_name), y = "number of rules")
                }, res = 96)

                shiny::observeEvent(input$resetButton, {
                    shiny::updateSliderInput("slider", value = rng, session = session)
                    if (!is.null(special)) {
                        shiny::updateCheckboxGroupInput("special", selected = special, session = session)
                    }
                })

                shiny::observeEvent(input$resetAllButton, {
                    reset_all_trigger(Sys.time())
                })
            })
        },

        filter = function(input) {
            val <- input[[shiny::NS(id, "slider")]]
            if (is.null(val) || length(val) != 2) {
                return(rep(TRUE, length(x)))
            }

            res <- !is.na(x) & !is.nan(x) & !is.infinite(x) & x >= val[1] & x <= val[2]
            spec <- input[[shiny::NS(id, "special")]]
            if (!is.null(spec)) {
                if ("NA" %in% spec) {
                    res <- res | (is.na(x) & !is.nan(x))
                }
                if ("NaN" %in% spec) {
                    res <- res | is.nan(x)
                }
                if ("-Inf" %in% spec) {
                    res <- res | (is.infinite(x) & x == -Inf)
                }
                if ("Inf" %in% spec) {
                    res <- res | (is.infinite(x) & x == Inf)
                }
            }

            res
        },

        reset = function(session) {
            shiny::updateSliderInput(inputId = shiny::NS(id, "slider"), value = rng, session = session)
            if (!is.null(special)) {
                shiny::updateCheckboxGroupInput(inputId = shiny::NS(id, "special"), selected = special, session = session)
            }
        }
    )
}
