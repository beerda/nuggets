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


exploreApp <- function(rules,
                       title,
                       meta,
                       extensions) {
    # to show special numeric values (such as Inf) in DT
    options(htmlwidgets.TOJSON_ARGS = list(na = 'string'))

    shiny::addResourcePath("pkgimages",
                    system.file(c("figures"),
                                package = "nuggets"))

    rulesTable <- rulesTableModule("rulesTable",
                                   rules = rules,
                                   meta = meta,
                                   action = callExtension(extensions, "filteredRulesPanel.rulesTable.action"))

    columnProjector <- columnProjectionModule(id = "columnProjectorModule",
                                              rules = rules,
                                              meta = meta)

    filters <- lapply(seq_len(nrow(meta)), function(i) {
        col <- meta$data_name[i]
        if (meta$type[i] == "condition") {
            return(conditionFilterModule(id = paste0(col, "FilterModule"),
                                         x = rules[[col]],
                                         meta = meta[i, , drop = FALSE]))
        } else if (meta$type[i] == "numeric" || meta$type[i] == "integer") {
            return(numericFilterModule(id = paste0(col, "FilterModule"),
                                       x = rules[[col]],
                                       meta = meta[i, , drop = FALSE]))
        } else {
            return(NULL)
        }
    })
    names(filters) <- meta$data_name
    filters <- filters[lengths(filters) != 0]  # drop NULL elements
    filter_choices <- names(filters)
    filter_subtext <- meta$long_name[match(filter_choices, meta$data_name)]
    indexes <- which(!is.na(filter_subtext))
    names(filters) <- NULL # tabsetPanel does not like named lists
    filterTabSet <- do.call(tabsetPanel,
                            c(list(id = "columnFilterTabset", type = "hidden", header = htmltools::tags::hr()),
                              lapply(filters, function(f) f$ui())))

    scatterFilter <- scatterFilterModule(id = "scatterFilterModule",
                                         rules = rules,
                                         meta = meta)
    filters <- c(filters, list(scatterFilter))

    ui <- shiny::tagList(
        htmltools::tags::head(
            htmltools::tags::style(htmltools::HTML("
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

                ul.nav-tabs {
                    margin-bottom: 12px;
                }

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
                    /* Make navbar non-fixed so it participates in layout */
                    .navbar-fixed-top { position: static !important; }
                    /* In case Bootstrap added body padding for fixed navbar, remove it on small screens */
                    body { padding-top: 0 !important; }

                    /* full-width overlay for sidebar */
                    .shared-sidebar {
                        position: relative;
                        left: 0;
                        right: 0;
                        top: 0 !important;
                        bottom: 0;
                        padding: 0;
                        height: 100% !important;
                        width: 100% !important;
                        border-right: none;
                        background: #ffffff;
                    }
                    .shared-sidebar.collapsed {
                        width: 100% !important;
                    }

                    /* cancel left margin; also cancel extra top offset since navbar is static now */
                    #mainContent > div.container-fluid > div.tab-content,
                    #mainContent.no-sidebar > div.container-fluid > div.tab-content {
                        margin-left: 0;
                        margin-top: 0 !important;
                    }

                    /* keep navbar above overlayed elements just in case */
                    .navbar {
                        z-index: 1100;
                    }
                }
            "))
        ),
        shinyjs::useShinyjs(),

        htmltools::div(id = "mainContent",
            shiny::navbarPage(
                title = shiny::tagList(
                    shiny::actionButton("toggle_sidebar",
                                 label = NULL,
                                 icon = shiny::icon("bars"),
                                 style = "padding: 0px 10px 0px 10px;"),
                    htmltools::span(htmltools::tags::img(src = "pkgimages/nugget.png",
                                         style = "padding-left: 10px; filter: grayscale(100%);",
                                         height = "24px"),
                                title)),
                id = "nav",
                windowTitle = title,
                fluid = TRUE,
                position = "fixed-top",
                header = shiny::tagList(
                    htmltools::div(id = "sharedSidebar", class = "shared-sidebar",
                        shinyWidgets::panel(heading = "Filters",
                            shiny::tabsetPanel(
                                columnProjector$ui(),
                                shiny::tabPanel("Rows",
                                    shinyWidgets::pickerInput("columnFiltersInput",
                                                label = "Show filter:",
                                                choices = filter_choices,
                                                choicesOpt = list(subtext = filter_subtext),
                                                options = shinyWidgets::pickerOptions(container = "body"),
                                                width = "100%"),
                                    filterTabSet),
                                shiny::tabPanel("Advanced",
                                    shiny::tabsetPanel(type = "pills", header = htmltools::tags::hr(),
                                        scatterFilter$ui()
                                    )
                                )
                            )
                        )
                    )
                ),
                shiny::tabPanel("Rules", icon = shiny::icon("chart-simple"), value = "rules",
                    shiny::fluidRow(
                        callExtension(extensions, "Rules.top"),
                        shiny::column(width = 12,
                            shinyWidgets::panel(heading = "Filtered Rules", rulesTable$ui())
                        )
                    )
                ),
                callExtension(extensions, "navbarPage.Metadata.before1"),
                callExtension(extensions, "navbarPage.Metadata.before2"),
                callExtension(extensions, "navbarPage.Metadata.before3"),
                shiny::tabPanel("Metadata", icon = shiny::icon("list"), value = "metadata",
                    shiny::fluidRow(
                        shiny::column(width = 8, offset = 2,
                            shinyWidgets::panel(heading = "Metadata",
                                shiny::tabsetPanel(
                                    shiny::tabPanel("Rulebase", rulebaseTable(rules, meta)),
                                    shiny::tabPanel("Data", callDataTable(rules, meta)),
                                    shiny::tabPanel("Call", creationParamsTable(rules))
                                )
                            )
                        )
                    )
                ),
                shiny::tabPanel("About", icon = shiny::icon("circle-info"), value = "about",
                    shiny::fluidRow(
                        shiny::column(width = 6, offset = 3,
                            shinyWidgets::panel(heading = "About the app",
                                  htmltools::tags::div(style = "text-align: center; font-size: 40pt; color: gray; padding-bottom: 10px",
                                           width = "100%",
                                           htmltools::tags::img(src = "pkgimages/logo.png", width = "200px")),
                                  aboutTable("nuggets")
                            )
                        )
                    )
                )
            )
        )
    )


    server <- function(input, output, session) {
        sidebar_collapsed <- shiny::reactiveVal(FALSE)
        manual_sidebar_collapsed <- shiny::reactiveVal(FALSE)
        reset_all_trigger <- shiny::reactiveVal(Sys.time()) # set system time to force reactivity

        set_sidebar_collapsed <- function(val, animate) {
            sidebar_collapsed(val)
            if (isTRUE(animate)) {
                shinyjs::addClass("sharedSidebar", "animated")
                shinyjs::addClass("mainContent", "animated")
            } else {
                shinyjs::removeClass("sharedSidebar", "animated")
                shinyjs::removeClass("mainContent", "animated")
            }
            if (isTRUE(val)) {
                shinyjs::addClass("sharedSidebar", "collapsed")
                shinyjs::addClass("mainContent", "no-sidebar")
            } else {
                shinyjs::removeClass("sharedSidebar", "collapsed")
                shinyjs::removeClass("mainContent", "no-sidebar")
            }
        }

        shiny::observeEvent(input$toggle_sidebar, {
            set_sidebar_collapsed(!isTRUE(sidebar_collapsed()), animate = TRUE)
            manual_sidebar_collapsed(sidebar_collapsed())
            shinyjs::runjs("window.dispatchEvent(new Event('resize'));") # notify any plots of size change
        })

        shiny::observeEvent(input$nav, {
            shiny::req(input$nav)
            if (input$nav %in% c("rules", callExtension(extensions, "navbarPage.enableSidebar.for"))) {
                set_sidebar_collapsed(manual_sidebar_collapsed(), animate = FALSE)
                shinyjs::removeClass("toggle_sidebar", "grayed")
            } else {
                set_sidebar_collapsed(TRUE, animate = FALSE)
                shinyjs::addClass("toggle_sidebar", "grayed")
            }
        }, ignoreNULL = TRUE)

        # On initial load, sync UI to reactiveVal (expanded by default)
        shiny::observe({
            shiny::isolate({
                set_sidebar_collapsed(isTRUE(sidebar_collapsed()), animate = FALSE)
            })
        })

        shiny::observeEvent(input$columnFiltersInput, {
            shiny::updateTabsetPanel(session,
                              "columnFilterTabset",
                              selected = paste0(input$columnFiltersInput, "-filter-tab"))
        })

        rulesProjection <- columnProjector$server(reset_all_trigger)

        lapply(filters, function(f) f$server(reset_all_trigger))

        shiny::observeEvent(reset_all_trigger(), {
            columnProjector$reset(session)
            lapply(filters, function(f) f$reset(session))
        }, ignoreInit = TRUE)

        rulesFiltering <- shiny::reactive({
            sel <- lapply(filters, function(f) f$filter(input))

            Reduce(`&`, sel)
        })

        ruleSelection <- rulesTable$server(rulesProjection, rulesFiltering)

        callExtension(extensions,
                      "server",
                      input = input,
                      output = output,
                      session = session,
                      rulesFiltering = rulesFiltering,
                      rulesProjection = rulesProjection,
                      ruleSelection = ruleSelection)
    }

    shiny::shinyApp(ui = ui, server = server)
}
