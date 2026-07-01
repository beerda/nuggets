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


associationsClusterModule <- function(id, rules, meta, data) {
    max_clusters <- 20
    measures <- meta$data_name[meta$type == "numeric"]
    selected_measure <- meta$data_name[which.max(meta$clustering_default)]

    list(ui = function() {
            shiny::fluidRow(
                shiny::column(width = 12,
                    shinyWidgets::panel(heading = "K-Means Clustering",
                        infoBox(paste("For rules selected by filters, cluster antecedents that have similar relationships to",
                                      "consequents based on the selected interest measure.")),
                        shiny::fluidRow(
                            shiny::column(width = 6,
                                shiny::sliderInput(shiny::NS(id, "k"),
                                            "Maximum number of clusters",
                                            min = 2,
                                            max = max_clusters,
                                            value = 2,
                                            step = 1,
                                            width = "100%"),
                            ),
                            shiny::column(width = 6,
                                shiny::selectInput(shiny::NS(id, "by"),
                                            "Clustering measure",
                                            choices = measures,
                                            selected = selected_measure,
                                            width = "100%"),
                                shiny::selectInput(shiny::NS(id, "algorithm"),
                                            "K-Means variant",
                                            choices = c("Hartigan-Wong", "Lloyd", "Forgy", "MacQueen"),
                                            selected = 1,
                                            width = "100%"),
                            ),
                        ),
                    ),
                    shinyWidgets::panel(heading = "Results",
                        shiny::tabsetPanel(
                            shiny::tabPanel("Plot",
                                shiny::fluidRow(
                                    shiny::column(width = 12,
                                        infoBox(paste("The plot identifies which antecedent groups are strongly",
                                                      "associated with certain consequents.",
                                                      "Each row is an antecedent group, each column is a consequent.",
                                                      "Balloon color shows the aggregated interest measure, size represents support.",
                                                      "Groups with the strongest associations appear in the top-left corner.")),
                                        shiny::plotOutput(shiny::NS(id, "clusteringPlot"), height = "500px")
                                    )
                                )
                            ),
                            shiny::tabPanel("Total Measures",
                                shiny::fluidRow(
                                    shiny::column(width = 6,
                                        shiny::plotOutput(shiny::NS(id, "totalSsPlot"), height = "125px")
                                    ),
                                    shiny::column(width = 6,
                                        shiny::uiOutput(shiny::NS(id, "totalMeasuresTable"))
                                    )
                                )
                            ),
                            shiny::tabPanel("Cluster Measures",
                                shiny::fluidRow(
                                    shiny::column(width = 6,
                                        shiny::plotOutput(shiny::NS(id, "clusterMsPlot"), height = "350px")
                                    ),
                                    shiny::column(width = 6,
                                        shiny::uiOutput(shiny::NS(id, "clusterMeasuresTable"))
                                    )
                                )
                            )
                        )
                    ),
                    shinyWidgets::panel(heading = "Cluster Details",
                        shiny::fluidRow(
                            shiny::column(width = 12,
                                shiny::uiOutput(shiny::NS(id, "clusterTabs")),
                                shiny::plotOutput(shiny::NS(id, "singleClusterPlot")),
                                DT::dataTableOutput(shiny::NS(id, "singleClusterTable"))
                            )
                        )
                    )
                )
            )
        },

        server = function(projectionReactive, selectionReactive) {
            shiny::moduleServer(id, function(input, output, session) {
                clustering <- shiny::reactive({
                    shiny::req(input$k, input$by, input$algorithm)
                    sel <- selectionReactive()
                    if (is.null(sel)) {
                        return(NULL)
                    }
                    d <- rules[sel, , drop = FALSE]
                    if (nrow(d) < 2) {
                        return(NULL)
                    }

                    set.seed(234)

                    suppressWarnings({
                        cluster_associations(d,
                                             n = input$k,
                                             by = input$by,
                                             algorithm = input$algorithm)
                    })
                })

                output$totalMeasuresTable <- shiny::renderUI({
                    clu <- clustering()
                    if (is.null(clu)) {
                        return(NULL)
                    }

                    nn <- c("between cluster sum of squares:",
                            "within cluster sum of squares:",
                            "total sum of squares:")
                    vv <- c(attr(clu, "between_ss"),
                            attr(clu, "within_ss"),
                            attr(clu, "total_ss"))
                    df <- data.frame(measure = nn,
                                     value = .format_percent(vv, vv[3], digits = 2),
                                     check.names = FALSE,
                                     stringsAsFactors = FALSE)

                    infoTable(df, header = TRUE, class = "hlrows leftnobold lrr")
                })

                output$clusterMeasuresTable <- shiny::renderUI({
                    clu <- clustering()
                    if (is.null(clu)) {
                        return(NULL)
                    }

                    sizes <- attr(clu, "cluster_size")
                    nn <- c(paste0("#", seq_along(sizes)), "total")
                    ss <- attr(clu, "cluster_within_ss")
                    ss <- c(ss, sum(ss))
                    ss <- round(ss, 2)
                    sizes <- c(sizes, sum(sizes))
                    df <- data.frame(cluster = nn,
                                     size = .format_percent(sizes, sizes[length(sizes)], digits = 0),
                                     `sum of squares` = .format_percent(ss, ss[length(ss)], digits = 2),
                                     `mean of squares` = round(ss / sizes, 2),
                                     check.names = FALSE,
                                     stringsAsFactors = FALSE)

                    infoTable(df, header = TRUE, class = "hlrows leftnobold lrr")
                })

                output$totalSsPlot <- shiny::renderPlot({
                    clu <- clustering()
                    if (is.null(clu)) {
                        return(NULL)
                    }

                    withinss <- attr(clu, "within_ss")
                    betweenss <- attr(clu, "between_ss")

                    df <- data.frame(ss = c("within", "between"),
                                     const = 1,
                                     value = c(withinss, betweenss))
                    ggplot(df) +
                        aes(x = value, y = const, fill = ss) +
                        geom_bar(stat = "identity", position = position_stack(reverse = TRUE), orientation = "y") +
                        labs(title = "sum of squares", x = NULL, y = NULL, fill = NULL) +
                        scale_x_continuous(expand = c(0, 0)) +
                        scale_y_continuous(expand = c(0, 0)) +
                        theme(legend.position = "bottom",
                              axis.text.y = element_blank(),
                              axis.ticks.y = element_blank(),
                              plot.title = element_text(hjust = 0.5),
                              panel.background = element_blank())
                }, res = 96)

                output$clusterMsPlot <- shiny::renderPlot({
                    clu <- clustering()
                    if (is.null(clu)) {
                        return(NULL)
                    }

                    sizes <- attr(clu, "cluster_size")
                    nn <- paste0("#", seq_along(sizes))
                    ms <- attr(clu, "cluster_within_ss") / sizes

                    df <- data.frame(name = factor(nn, levels = nn),
                                     sizes = sizes,
                                     ms = ms)
                    ggplot(df) +
                        aes(y = name, x = sizes, fill = ms) +
                        geom_bar(stat = "identity", position = position_stack(reverse = TRUE), orientation = "y") +
                        labs(title = NULL, y = NULL, x = "size", fill = "mean of sq.") +
                        scale_x_continuous(expand = c(0, 0)) +
                        scale_y_discrete(expand = c(0, 0), limits = rev) +
                        theme(legend.position = "bottom",
                              plot.title = element_text(hjust = 0.5))
                }, res = 96)

                output$clusteringPlot <- shiny::renderPlot({
                    clu <- clustering()
                    if (is.null(clu)) {
                        return(NULL)
                    }

                    clu$cluster_label <- paste0(clu$cluster_label,
                                                "#", clu$cluster)
                    clu$cluster_label <- factor(clu$cluster_label,
                                                levels = unique(clu$cluster_label))

                    ggplot(clu) +
                        aes(y = factor(.data[["cluster_label"]]),
                            x = .data[["consequent"]],
                            color = .data[[input$by]],
                            size = .data[["support"]]) +
                        geom_point() +
                        xlab("consequent") +
                        ylab("cluster") +
                        scale_y_discrete(limits = rev) +
                        theme(axis.text.x = element_text(angle = 90, hjust = 1))
                }, res = 96)

                output$clusterTabs <- shiny::renderUI({
                    clu <- clustering()
                    if (is.null(clu)) {
                        return(NULL)
                    }
                    k <- length(unique(clu$cluster))
                    tabs <- lapply(seq_len(k), function(i) {
                        shiny::tabPanel(
                            title = paste0("#", i),
                            value = i)
                    })

                    do.call(shiny::tabsetPanel,
                            c(id = shiny::NS(id, "selectedCluster"), tabs))
                })

                output$singleClusterPlot <- shiny::renderPlot({
                    shiny::req(input$selectedCluster)

                    clu <- clustering()
                    if (is.null(clu)) {
                        return(NULL)
                    }

                    d <- attr(clu, "cluster_predicates")[[input$selectedCluster]]
                    d <- as.data.frame(d)
                    colnames(d) <- c("tab", "Freq")

                    ggplot(d) +
                        aes(y = .data[["tab"]], x = .data[["Freq"]], label = .data[["Freq"]]) +
                        geom_col() +
                        geom_text(hjust = -0.4) +
                        ylab("antecedent predicate") +
                        xlab("frequency in cluster") +
                        scale_y_discrete(limits = rev) +
                        scale_x_continuous(expand = expansion(mult = c(0, 0.15)))
                }, res = 96)

                output$singleClusterTable <- DT::renderDT({
                    shiny::req(input$selectedCluster)

                    clu <- clustering()
                    if (is.null(clu)) {
                        return(NULL)
                    }

                    sel <- selectionReactive()
                    proj <- c("id", projectionReactive())
                    d <- rules[sel, proj, drop = FALSE]
                    ante <- attr(clu, "cluster_antecedents")[[input$selectedCluster]]
                    d <- d[d$antecedent %in% ante, , drop = FALSE]
                    d$id <- NULL
                    d <- formatRulesForTable(d, meta)
                    tooltips <- meta$long_name[match(colnames(d), meta$data_name)]

                    datatable2(d, tooltips = tooltips)
                })

            })
        }
    )
}
