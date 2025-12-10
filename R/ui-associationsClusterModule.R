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

                output$clusteringPlot <- shiny::renderPlot({
                    clu <- clustering()
                    if (is.null(clu)) {
                        return(NULL)
                    }

                    clu$cluster_label <- paste0(clu$cluster_label,
                                                " #", clu$cluster)
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
                            title = paste("#", i),
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
