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


callDataTable <- function(rules, meta) {
    call_data <- attr(rules, "call_data")
    call_args <- attr(rules, "call_args")
    cn <- call_data$colnames

    d <- tibble("column name" = cn)

    for (cond in meta$data_name[meta$type == "condition"]) {
        d[[cond]] <- lapply(cn, function(col) {
            if (col %in% call_args[[cond]]) htmltools::tags$span(style = "color: limegreen;", "\u2714") else ""
        })
    }

    if (!is.null(call_args$disjoint)) {
        d[["disjoint"]] <- call_args$disjoint
    }

    infoTable(d, header = TRUE, class = "center hlrows")
}
