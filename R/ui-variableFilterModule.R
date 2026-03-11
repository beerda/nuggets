#######################################################################
# nuggets: An R framework for exploration of patterns in data
# Copyright (C) 2026 Michal Burda
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


.create_tree_def_from_variables <- function(rules, meta, root_name) {
    if (nrow(meta) == 0 || nrow(rules) == 0) {
        return(data.frame(rid = character(0),
                          nid = character(0),
                          vid = character(0),
                          column_name = character(0),
                          value = character(0),
                          stringsAsFactors = FALSE))
    }

    cols <- meta$data_name
    all_rows <- list()
    vid_counter <- 0

    for (i in seq_along(cols)) {
        col <- cols[i]
        vals <- unique(rules[[col]])
        vals <- vals[!is.na(vals)]
        vals <- sort(vals)

        nid <- paste0("n", i)

        for (v in vals) {
            vid_counter <- vid_counter + 1
            vid <- paste0("v", vid_counter)
            all_rows[[length(all_rows) + 1]] <- data.frame(
                rid = root_name,
                nid = nid,
                vid = vid,
                column_name = col,
                value = v,
                stringsAsFactors = FALSE
            )
        }
    }

    if (length(all_rows) == 0) {
        return(data.frame(rid = character(0),
                          nid = character(0),
                          vid = character(0),
                          column_name = character(0),
                          value = character(0),
                          stringsAsFactors = FALSE))
    }

    do.call(rbind, all_rows)
}


.create_variable_filtering_table <- function(rules, def) {
    if (nrow(rules) == 0 || nrow(def) == 0) {
        return(matrix(FALSE, nrow = nrow(rules), ncol = nrow(def)))
    }

    m <- matrix(FALSE, nrow = nrow(rules), ncol = nrow(def))
    for (j in seq_len(nrow(def))) {
        col <- def$column_name[j]
        val <- def$value[j]
        m[, j] <- !is.na(rules[[col]]) & rules[[col]] == val
    }

    m
}


variableFilterModule <- function(id, rules, meta) {
    root_name <- "variable"
    def <- .create_tree_def_from_variables(rules, meta, root_name)
    tab <- .create_variable_filtering_table(rules, def)

    showTree <- NULL
    if (nrow(def) > 0) {
        tree <- shinyWidgets::create_tree(def,
                            levels = c("rid", "column_name", "value"),
                            levels_id = c("rid", "nid", "vid"))
        showTree <- shinyWidgets::treeInput(shiny::NS(id, "tree"),
                                            label = "variable",
                                            choices = tree,
                                            selected = root_name,
                                            returnValue = "id",
                                            closeDepth = 1)
    }

    list(ui = function() {
            filterTabPanel(title = "Variable",
                           value = "variable",
                           info = "Filter the rules by choosing variables.",
                showTree,
                htmltools::hr(),
                shiny::actionButton(shiny::NS(id, "resetButton"), "Reset"),
                shiny::actionButton(shiny::NS(id, "resetAllButton"), "Reset all")
            )
        },

        server = function(reset_all_trigger) {
            shiny::moduleServer(id, function(input, output, session) {
                shiny::observeEvent(input$resetButton, {
                    if (!is.null(showTree)) {
                        shinyWidgets::updateTreeInput("tree", selected = def$vid, session = session)
                    }
                })

                shiny::observeEvent(input$resetAllButton, {
                    reset_all_trigger(Sys.time())
                })
            })
        },

        filter = function(input) {
            treeInput <- input[[shiny::NS(id, "tree")]]

            if (is.null(treeInput) || nrow(def) == 0) {
                return(rep(TRUE, nrow(rules)))
            }

            ids <- def$rid %in% treeInput |
                   def$nid %in% treeInput |
                   def$vid %in% treeInput

            sel <- tab[, ids, drop = FALSE]
            # TRUE only when all variable values of the row are among selected
            rowSums(sel) == rowSums(tab)
        },

        reset = function(session) {
            if (!is.null(showTree)) {
                shinyWidgets::updateTreeInput(shiny::NS(id, "tree"), selected = def$vid, session = session)
            }
        }
    )
}
