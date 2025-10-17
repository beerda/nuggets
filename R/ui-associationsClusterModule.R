associationsClusterModule <- function(id, rules, meta, data) {
    measures <- meta$data_name[meta$type == "numeric"]
    selected_measure <- meta$data_name[which.max(meta$clustering_default)]

    list(ui = function() {
            tagList(
                fluidRow(
                    column(width = 6,
                        sliderInput(NS(id, "k"),
                                    "Number of clusters",
                                    min = 2,
                                    max = 2,
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
                fluidRow(
                    column(width = 12,
                        hr(),
                        plotOutput(NS(id, "clusteringPlot"), height = "500px")
                    )
                )
            )
        },

        server = function(selectionReactive) {
            moduleServer(id, function(input, output, session) {
                lengthUniqueAnte <- reactive({
                    sel <- selectionReactive()

                    length(unique(rules$antecedent[sel]))
                })

                observe({
                    l <- lengthUniqueAnte()
                    updateSliderInput(session,
                                      "k",
                                      max = min(20, l - 1))
                })

                output$clusteringPlot <- renderPlot({
                    req(input$k)
                    req(input$by)
                    req(input$algorithm)

                    if (lengthUniqueAnte() <= input$k) {
                        return(NULL)
                    }

                    sel <- selectionReactive()
                    d <- rules[sel, , drop = FALSE]

                    clu <- cluster_associations(d,
                                                n = input$k,
                                                by = input$by,
                                                algorithm = input$algorithm)

                    ggplot(clu) +
                        aes(x = as.factor(cluster),
                            y = consequent,
                            color = .data[[input$by]],
                            size = support) +
                        geom_point() +
                        xlab("cluster") +
                        scale_y_discrete(limits = rev)
                }, res = 96)
            })
        }
    )
}
