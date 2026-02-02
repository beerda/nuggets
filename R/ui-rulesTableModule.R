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


# @param actions a list with the following elements:
#        - `title`: the title of the button (displayed on hover);
#        - `icon`: the icon of the button (a FontAwesome icon name).
rulesTableModule <- function(id, rules, meta, action) {
    rules <- formatRulesForTable(rules, meta)

    list(ui = function() {
            DT::dataTableOutput(shiny::NS(id, "table"))
        },

        server = function(projectionReactive, selectionReactive) {
            shiny::moduleServer(id, function(input, output, session) {
                ns <- session$ns

                output$table <- DT::renderDT({
                    sel <- selectionReactive()
                    proj <- c("id", projectionReactive())
                    d <- rules[sel, proj, drop = FALSE]

                    if (!is.null(action)) {
                        buttons <- vapply(X = d$id,
                                          FUN.VALUE = character(1),
                                          USE.NAMES = FALSE,
                                          FUN = function(id_) {
                            paste0('<div class="btn-group" style="width: 25px;" role="group">',
                                   '<button ',
                                       'class="btn btn-sm" ',
                                       'type="button" ',
                                       'data-toggle="tooltip" ',
                                       'data-placement="top" ',
                                       'style="margin: 0" ',
                                       'title="', action$title, '" ',
                                       'onClick="Shiny.setInputValue(\'', ns("selected"), '\', ', id_, ', { priority: \'event\' });"',
                                       '>',
                                       '<i class="fa fa-', action$icon, '"></i>',
                                       '</button>',
                                   '</div>')
                        })
                        d <- cbind(data.frame(" " = buttons,
                                              check.names = FALSE,
                                              stringsAsFactors = FALSE),
                                   d)
                    }

                    d$id <- NULL
                    tooltips <- meta$long_name[match(colnames(d), meta$data_name)]

                    datatable2(d, tooltips = tooltips)
                })

                shiny::reactive({ input$selected })
            })
        }
    )
}
