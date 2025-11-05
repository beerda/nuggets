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
            fluidRow(
                column(width = 12,
                    panel(heading = "K-Means Clustering",
                        infoBox(paste("For rules selected by filters, cluster antecedents that have similar relationships to",
                                      "consequents based on the selected interest measure.")),
                        fluidRow(
                            column(width = 6,
                                sliderInput(NS(id, "k"),
                                            "Number of clusters",
                                            min = 2,
                                            max = max_clusters,
                                            value = 2,
                                            step = 1,
                                            width = "100%"),
                            ),
                            column(width = 6,
                                selectInput(NS(id, "by"),
                                            "Clustering measure",
                                            choices = measures,
                                            selected = selected_measure,
                                            width = "100%"),
                                selectInput(NS(id, "algorithm"),
                                            "K-Means variant",
                                            choices = c("Hartigan-Wong", "Lloyd", "Forgy", "MacQueen"),
                                            selected = 1,
                                            width = "100%"),
                            ),
                        ),
                    ),
                    panel(heading = "Results",
                        fluidRow(
                            column(width = 12,
                                infoBox(paste("The plot identifies which antecedent groups are strongly",
                                              "associated with certain consequents.",
                                              "Each row is an antecedent group, each column is a consequent.",
                                              "Balloon color shows the aggregated interest measure, size represents support.",
                                              "Groups with the strongest associations appear in the top-left corner.")),
                                plotOutput(NS(id, "clusteringPlot"), height = "500px")
                            )
                        )
                    ),
                    panel(heading = "Cluster Details",
                        fluidRow(
                            column(width = 12,
                                uiOutput(NS(id, "clusterTabs")),
                                plotOutput(NS(id, "singleClusterPlot")),
                                dataTableOutput(NS(id, "singleClusterTable"))
                            )
                        )
                    )
                )
            )
        },

        server = function(projectionReactive, selectionReactive) {
            moduleServer(id, function(input, output, session) {
                lengthUniqueAnte <- reactive({
                    sel <- selectionReactive()

                    length(unique(rules$antecedent[sel]))
                })

                observe({
                    l <- lengthUniqueAnte()
                    updateSliderInput(session,
                                      "k",
                                      max = min(max_clusters, l - 1))
                })

                clustering <- reactive({
                    req(input$k, input$by, input$algorithm)
                    if (lengthUniqueAnte() <= input$k) {
                        return(NULL)
                    }

                    sel <- selectionReactive()
                    d <- rules[sel, , drop = FALSE]

                    cluster_associations(d,
                                         n = input$k,
                                         by = input$by,
                                         algorithm = input$algorithm)
                })

                output$clusteringPlot <- renderPlot({
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

                output$clusterTabs <- renderUI({
                    req(input$k)
                    tabs <- lapply(seq_len(input$k), function(i) {
                        tabPanel(
                            title = paste("#", i),
                            value = i)
                    })

                    do.call(tabsetPanel,
                            c(id = NS(id, "selectedCluster"), tabs))
                })

                output$singleClusterPlot <- renderPlot({
                    req(input$selectedCluster)

                    clu <- clustering()
                    if (is.null(clu)) {
                        return(NULL)
                    }

                    d <- attr(clu, "cluster_predicates")[[input$selectedCluster]]
                    d <- as.data.frame(d)

                    ggplot(d) +
                        aes(y = .data[["tab"]], x = .data[["Freq"]], label = .data[["Freq"]]) +
                        geom_col() +
                        geom_text(hjust = -0.4) +
                        ylab("antecedent predicate") +
                        xlab("frequency in cluster") +
                        scale_y_discrete(limits = rev) +
                        scale_x_continuous(expand = expansion(mult = c(0, 0.15)))
                }, res = 96)

                output$singleClusterTable <- renderDT({
                    req(input$selectedCluster)

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
