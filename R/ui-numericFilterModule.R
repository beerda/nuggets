numericFilterModule <- function(id,
                                x,
                                meta,
                                resetAllEvent) {
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
                specialCheckboxInput <- checkboxGroupInput(NS(id, "special"),
                                                          label = "special values",
                                                          choices = special,
                                                          selected = special,
                                                          inline = TRUE)
            }

            tabPanel(meta$long_name,
                infoBox(paste0("Filter the rules by choosing a range of values for ",
                               tolower(meta$long_name), ".")),
                tableOutput(NS(id, "summaryTable")),
                plotOutput(NS(id, "histogramPlot")),
                sliderInput(NS(id, "slider"),
                            label = tolower(meta$long_name),
                            min = rng[1],
                            max = rng[2],
                            step = if (int) 1 else NULL,
                            value = rng,
                            round = FALSE,
                            width = "100%"),
                specialCheckboxInput,
                hr(),
                actionButton(NS(id, "resetButton"), "Reset"),
                actionButton(resetAllEvent, "Reset all")
            )
        },

        server = function() {
            moduleServer(id, function(input, output, session) {
                output$summaryTable <- renderTable({
                    summaryTable
                }, width = "100%", bordered = TRUE, striped = TRUE, align = "c", digits = 2)

                output$histogramPlot <- renderPlot({
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

                observeEvent(input$resetButton, {
                    updateSliderInput("slider", value = rng, session = session)
                    if (!is.null(special)) {
                        updateCheckboxGroupInput("special", selected = special, session = session)
                    }
                })
            })
        },

        filter = function(input) {
            val <- input[[NS(id, "slider")]]
            if (is.null(val) || length(val) != 2) {
                return(rep(TRUE, length(x)))
            }

            res <- !is.na(x) & !is.nan(x) & !is.infinite(x) & x >= val[1] & x <= val[2]
            spec <- input[[NS(id, "special")]]
            if (!is.null(spec)) {
                if ("NA" %in% spec) {
                    res <- res | is.na(x)
                }
                if ("NaN" %in% spec) {
                    res <- res | is.nan(x)
                }
                if ("-Inf" %in% spec) {
                    res <- res | (x == -Inf)
                }
                if ("Inf" %in% spec) {
                    res <- res | (x == Inf)
                }
            }

            res
        },

        reset = function(session) {
            updateSliderInput(inputId = NS(id, "slider"), value = rng, session = session)
            if (!is.null(special)) {
                updateCheckboxGroupInput(inputId = NS(id, "special"), selected = special, session = session)
            }
        }
    )
}
