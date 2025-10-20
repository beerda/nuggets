exploreApp <- function(rules,
                       title,
                       meta,
                       extensions) {
    # to show special numeric values (such as Inf) in DT
    options(htmlwidgets.TOJSON_ARGS = list(na = 'string'))

    addResourcePath("pkgimages",
                    system.file(c("figures"),
                                package = "nuggets"))

    rulesTable <- rulesTableModule("rulesTable",
                                   rules = rules,
                                   meta = meta,
                                   action = callExtension(extensions, "filteredRulesPanel.rulesTable.action"))

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

    scatterFilter <- scatterFilterModule(id = "scatterFilterModule",
                                         rules = rules,
                                         meta = meta,
                                         resetAllEvent = "resetAllEvent")
    filters <- c(filters, list(scatterFilter))

    ui <- tagList(
        tags$head(
            tags$style(HTML("
                /* monospace font for code */
                .mono {font-family: \"Courier New\", Courier, monospace;}

                /* predicate syntax highlighting */
                span.pred_n {color: darkble;}
                span.pred_v {color: green;}

                /* info box */
                div.info-box {display: flex; align-items: center; gap: 10px;}

                /* info table */
                table.info-table {border: none;}
                table.info-table td {padding-bottom: 5px; padding-left: 5px; text-align: right; vertical-align: top;}
                table.info-table th {text-align: center; vertical-align: center; padding-top: 5px; padding-bottom: 5px; padding-left: 5px;}
                table.info-table.left td {text-align: left;}
                table.info-table.center td {text-align: center;}
                table.info-table td:first-child {font-weight: bold; text-align: left; padding-right: 10px;}
                table.info-table th:first-child {font-weight: bold; text-align: left; padding-right: 10px;}
                table.info-table.hlrows tbody tr:nth-child(odd) {background-color: #f5f5f5;}

                nav.navbar { margin-bottom: 15px; }
                .grayed { opacity: 0.3; pointer-events: none; }

                /* container for the left sidebar */
                .shared-sidebar {
                    position: fixed;
                    left: 0;
                    top: 52px;
                    bottom: 0;
                    width: max(400px, 25%);
                    padding: 15px 15px 15px 15px;
                    background: #f8f9fa;
                    border-right: 1px solid #ddd;
                    overflow: auto;
                    z-index: 1000;
                }
                .shared-sidebar.collapsed {
                    width: 0;
                    padding-left: 0;
                    padding-right: 0;
                    border: none;
                }
                .shared-sidebar.collapsed * {
                    display: none;
                }
                .shared-sidebar.animated {
                    transition: width 0.25s ease, transform 0.25s ease;
                }
                /* main content area: single wrapper we toggle via shinyjs */
                #mainContent > div.container-fluid > div.tab-content {
                    margin-left: max(393px, 25%);
                    padding: 0px 0px 0px 7px;
                    margin-top: 67px;
                }
                /* when 'no-sidebar' class is present we remove the left margin */
                #mainContent.no-sidebar > div.container-fluid > div.tab-content {
                    margin-left: 0;
                }
                #mainContent.animated > div.container-fluid > div.tab-content {
                    transition: margin-left 0.25s ease;
                }

                @media (max-width: 768px) {
                    /* full-width overlay for sidebar */
                    .shared-sidebar {
                        position: relative;
                        left: 0;
                        right: 0;
                        top: 0;
                        bottom: 0;
                        padding 0;
                        height: 100% !important;
                        width: 100% !important;
                        border-right: none;
                        background: #ffffff;
                    }
                    .shared-sidebar.collapsed {
                        width: 100% !important;
                    }
                    #mainContent > div.container-fluid > div.tab-content, #mainContent.no-sidebar > div.container-fluid > div.tab-content {
                        margin-left: 0;
                    }
                    .navbar {
                        z-index: 1100;
                    }
                }
            "))
        ),
        useShinyjs(),

        div(id = "mainContent",
            navbarPage(
                title = tagList(
                    actionButton("toggle_sidebar",
                                 label = NULL,
                                 icon = icon("bars"),
                                 style = "padding: 0px 10px 0px 10px;"),
                    span(tags$img(src = "pkgimages/nugget.png",
                                         style = "padding-left: 10px; filter: grayscale(100%);",
                                         height = "24px"),
                                title)),
                id = "nav",
                windowTitle = title,
                fluid = TRUE,
                position = "fixed-top",
                header = tagList(
                    div(id = "sharedSidebar", class = "shared-sidebar",
                        panel(heading = "Filters",
                            tabsetPanel(
                                tabPanel("Basic", filterTabSet),
                                tabPanel("Advanced",
                                    tabsetPanel(type = "pills", header = tags$hr(),
                                        scatterFilter$ui()
                                    )
                                )
                            )
                        )
                    )
                ),
                tabPanel("Rules", icon = icon("chart-simple"), value = "rules",
                    fluidRow(
                        callExtension(extensions, "Rules.top"),
                        column(width = 12,
                            panel(heading = "Filtered Rules", rulesTable$ui())
                        )
                    )
                ),
                callExtension(extensions, "navbarPage.Metadata.before1"),
                callExtension(extensions, "navbarPage.Metadata.before2"),
                callExtension(extensions, "navbarPage.Metadata.before3"),
                tabPanel("Metadata", icon = icon("list"), value = "metadata",
                    fluidRow(
                        column(width = 8, offset = 2,
                            panel(heading = "Metadata",
                                tabsetPanel(
                                    tabPanel("Rulebase", rulebaseTable(rules, meta)),
                                    tabPanel("Data", callDataTable(rules, meta)),
                                    tabPanel("Call", creationParamsTable(rules))
                                )
                            )
                        )
                    )
                ),
                tabPanel("About", icon = icon("circle-info"), value = "about",
                    fluidRow(
                        column(width = 6, offset = 3,
                            panel(heading = "About the app",
                                  tags$div(style = "text-align: center; font-size: 40pt; color: gray; padding-bottom: 10px",
                                           width = "100%",
                                           tags$img(src = "pkgimages/logo.png", width = "200px")),
                                  aboutTable("nuggets")
                            )
                        )
                    )
                )
            )
        )
    )


    server <- function(input, output, session) {
        sidebar_collapsed <- reactiveVal(FALSE)
        manual_sidebar_collapsed <- reactiveVal(FALSE)

        set_sidebar_collapsed <- function(val, animate) {
            sidebar_collapsed(val)
            if (isTRUE(animate)) {
                addClass("sharedSidebar", "animated")
                addClass("mainContent", "animated")
            } else {
                removeClass("sharedSidebar", "animated")
                removeClass("mainContent", "animated")
            }
            if (isTRUE(val)) {
                addClass("sharedSidebar", "collapsed")
                addClass("mainContent", "no-sidebar")
            } else {
                removeClass("sharedSidebar", "collapsed")
                removeClass("mainContent", "no-sidebar")
            }
        }

        observeEvent(input$toggle_sidebar, {
            set_sidebar_collapsed(!isTRUE(sidebar_collapsed()), animate = TRUE)
            manual_sidebar_collapsed(sidebar_collapsed())
            runjs("window.dispatchEvent(new Event('resize'));") # notify any plots of size change
        })

        observeEvent(input$nav, {
            req(input$nav)
            if (input$nav %in% c("rules", callExtension(extensions, "navbarPage.enableSidebar.for"))) {
                set_sidebar_collapsed(manual_sidebar_collapsed(), animate = FALSE)
                removeClass("toggle_sidebar", "grayed")
            } else {
                set_sidebar_collapsed(TRUE, animate = FALSE)
                addClass("toggle_sidebar", "grayed")
            }
        }, ignoreNULL = TRUE)

        # On initial load, sync UI to reactiveVal (expanded by default)
        observe({
            isolate({
                set_sidebar_collapsed(isTRUE(sidebar_collapsed()), animate = FALSE)
            })
        })

        lapply(filters, function(f) f$server())

        observeEvent(input$resetAllEvent, {
            lapply(filters, function(f) f$reset(session))
        })

        rulesFiltering <- reactive({
            sel <- lapply(filters, function(f) f$filter(input))

            Reduce(`&`, sel)
        })

        ruleSelection <- rulesTable$server(rulesFiltering)

        callExtension(extensions,
                      "server",
                      input = input,
                      output = output,
                      session = session,
                      rulesFiltering = rulesFiltering,
                      ruleSelection = ruleSelection)
    }

    shinyApp(ui = ui, server = server)
}
