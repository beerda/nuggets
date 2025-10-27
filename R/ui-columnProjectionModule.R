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


.create_tree_def_from_colnames <- function(meta, root_name) {
    if (is.null(meta) || length(meta) == 0) {
        return(data.frame())
    }

    group <- meta$type
    gid <- paste0("g", match(group, unique(group)))
    vid <- paste0("v", seq_along(meta$data_name))
    value <- meta$data_name
    colname <- meta$data_name

    res <- data.frame(rid = root_name,
                      gid = gid,         # group ID
                      vid = vid,         # value ID
                      group = group,     # group name shown
                      value = value,     # node name shown
                      colname = colname,
                      stringsAsFactors = FALSE)

    res
}


columnProjectionModule <- function(id, rules, meta) {
    root_name <- "column"
    def <- .create_tree_def_from_colnames(meta, root_name)
    tree <- create_tree(def,
                        levels = c("rid", "group", "value"),
                        levels_id = c("rid", "gid", "vid"))

    list(ui = function() {
            tabPanel(title = "Columns",
                     value = "column-projection-tab",
                infoBox("Select columns to be shown in the table."),
                treeInput(NS(id, "tree"),
                          label = NULL,
                          choices = tree,
                          selected = root_name,
                          returnValue = "id",
                          closeDepth = 2),
                hr(),
                actionButton(NS(id, "resetButton"), "Reset"),
                actionButton(NS(id, "resetAllButton"), "Reset all")
            )
        },

        server = function(reset_all_trigger) {
            moduleServer(id, function(input, output, session) {
                observeEvent(input$resetButton, {
                    updateTreeInput("tree", selected = def$vid, session = session)
                })

                observeEvent(input$resetAllButton, {
                    reset_all_trigger(Sys.time())
                })

                reactive({
                    treeInput <- input$tree
                    res <- NULL
                    if (!is.null(treeInput)) {
                        res <- def$colname[def$vid %in% treeInput]
                    }
                    if (length(res) == 0) {
                        res <- NULL
                    }

                    res
                })
            })
        },

        reset = function(session) {
            updateTreeInput(NS(id, "tree"), selected = def$vid, session = session)
        }
    )
}
