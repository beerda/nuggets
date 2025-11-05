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


infoTable <- function(df, header = FALSE, class = NULL, width = "100%") {
    trs <- lapply(seq_len(nrow(df)), function(i) {
        htmltools::tags$tr(lapply(df[i, ], function(x) htmltools::tags$td(x)))
    })

    head <- NULL
    if (header) {
        head <- htmltools::tags$thead(
            htmltools::tags$tr(lapply(colnames(df), function(x) htmltools::tags$th(x)))
        )
    }

    htmltools::tags$table(class = paste(c("info-table", class), collapse = " "),
               width = width,
               head,
               do.call(htmltools::tags$tbody, trs))
}

