mainApp <- function(rules,
                    title,
                    meta,
                    header = NULL,
                    footer = NULL,
                    detailWindow = NULL) {
    # to show special numeric values (such as Inf) in DT
    options(htmlwidgets.TOJSON_ARGS = list(na = 'string'))

    title <- paste0(title, " - Nuggets Explorer")

    detailAction <- NULL
    detailPanel <- NULL
    if (!is.null(detailWindow)) {
        detailAction <- list(title = "show detail", icon = "magnifying-glass")
        detailPanel <- tabPanel("Rule Detail",
                                icon = icon("magnifying-glass"),
                                detailWindow$ui())
    }

    rulesTable <- rulesTableModule("rulesTable",
                                   rules = rules,
                                   meta = meta,
                                   action = detailAction)

    filters <- lapply(seq_len(nrow(meta)), function(i) {
        col <- meta$data_name[i]
        if (meta$type[i] == "condition") {
            return(conditionFilterModule(id = paste0(col, "FilterModule"),
                                         x = rules[[col]],
                                         meta = meta[i, , drop = FALSE],
                                         resetAllEvent = "resetAllEvent"))
        } else if (meta$type[i] == "numeric" || meta$type[i] == "integer") {
            return(numericFilterModule(id = paste0(col, "FilterModule"),
                                       x = rules[[col]],
                                       meta = meta[i, , drop = FALSE],
                                       resetAllEvent = "resetAllEvent"))
        } else {
            return(NULL)
        }
    })
    filters <- filters[lengths(filters) != 0]  # drop NULL elements
    filterTabSet <- do.call(tabsetPanel,
                            c(list(type = "pills", header = tags$hr()),
                              lapply(filters, function(f) f$ui())))


    ui <- tagList(
        tags$head(
            # predicate syntax highlighting
            tags$style('span.pred_n {color: darkblue;}'),
            tags$style('span.pred_v {color: green;}'),

            tags$style('.mono {font-family: "Courier New", Courier, monospace;}'),

            # padding for tab content
            tags$style('div.tab-pane {padding-top: 10px;}'),

            # info box
            tags$style('div.info-box {display: flex; align-items: center; gap: 10px;}'),

            # info table
            tags$style('table.info-table {border: none;}'),
            tags$style('table.info-table td {padding-bottom: 5px; text-align: right; vertical-align: top;}'),
            tags$style('table.info-table.left td {text-align: left;}'),
            tags$style('table.info-table td:first-child {font-weight: bold; text-align: left; padding-right: 10px}'),
        ),
        useShinyjs(),
        navbarPage(title = span(icon("gem"), title),
                   id = "mainTabset",
                   windowTitle = title,
                   header = header,
                   footer = footer,
            tabPanel("Rules", icon = icon("table"),
                fluidRow(
                    column(width = 4,
                        panel(heading = "Filter", filterTabSet)
                    ),
                    column(width = 8,
                        panel(heading = "Filtered Rules", rulesTable$ui())
                    )
                )
            ),
            detailPanel,
            tabPanel("About", icon = icon("circle-info"),
                fluidRow(
                    column(width = 6, offset = 3,
                        panel(heading = "About the app",
                              tags$div(style = "text-align: center; font-size: 40pt; color: gray; padding-bottom: 10px", width = "100%", icon("gem")),
                              aboutTable("nuggets")
                        )
                    )
                )
            )
        )
    )


    server <- function(input, output, session) {
        lapply(filters, function(f) f$server())

        observeEvent(input$resetAllEvent, {
            lapply(filters, function(f) f$reset(session))
        })

        rulesFiltering <- reactive({
            sel <- lapply(filters, function(f) f$filter(input))

            Reduce(`&`, sel)
        })

        ruleSelection <- rulesTable$server(rulesFiltering)

        if (!is.null(detailWindow)) {
            observeEvent(ruleSelection(), {
                updateTabsetPanel(session, "mainTabset", selected = "Rule Detail")
            })

            detailWindow$server(ruleSelection)
        }
    }

    shinyApp(ui = ui, server = server)
}
