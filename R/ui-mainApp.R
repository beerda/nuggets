mainApp <- function(data,
                    title,
                    meta) {
    # to show special numeric values (such as Inf) in DT
    options(htmlwidgets.TOJSON_ARGS = list(na = 'string'))

    data$id <- seq_len(nrow(data))

    title <- paste0(title, " - Nuggets Explorer")

    rulesTable <- rulesTableModule("rulesTable",
                                   data = data,
                                   meta = meta,
                                   actions = list(
                                       list(title = "show detail",
                                            icon = "magnifying-glass",
                                            action = "showDetailButton")
                                   ))

    filters <- lapply(seq_len(nrow(meta)), function(i) {
        col <- meta$data_name[i]
        if (meta$type[i] == "condition") {
            return(conditionFilterModule(id = paste0(col, "FilterModule"),
                                         x = data[[col]],
                                         meta = meta[i, , drop = FALSE],
                                         resetAllEvent = "resetAllEvent"))
        } else if (meta$type[i] == "numeric" || meta$type[i] == "integer") {
            return(numericFilterModule(id = paste0(col, "FilterModule"),
                                       x = data[[col]],
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

            # padding for tab content
            tags$style('div.tab-pane {padding-top: 10px;}'),

            # info box
            tags$style('div.info-box {display: flex; align-items: center; gap: 10px; padding: 10px; background-color: #d9edf7; margin-bottom: 10px; color: #31708f; border-radius: 3px;}'),

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
            tabPanel("Rules",
                fluidRow(
                    column(width = 4,
                        panel(heading = "Filter", filterTabSet)
                    ),
                    column(width = 8,
                        verticalLayout(
                            panel(heading = "Filtered Rules", rulesTable$ui()),
                            panel(heading = "Selected Rule Detail", "ased")
                        )
                    )
                )
            ),
            tabPanel("Details"),
            tabPanel("About",
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

        rulesSelection <- reactive({
            sel <- lapply(filters, function(f) f$filter(input))

            Reduce(`&`, sel)
        })

        selectedId <- rulesTable$server(rulesSelection)

        observeEvent(selectedId(), {
            cat("jetu\n")
            str(selectedId())
            showModal(
                modalDialog(
                    title = "My modal window",
                    "This window was hidden at the beginning and only shown after the button was clicked.",
                    easyClose = TRUE,
                    footer = modalButton("Close")
                )
            )
        })
    }

    shinyApp(ui = ui, server = server)
}
