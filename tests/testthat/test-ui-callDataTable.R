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


test_that("callDataTable()", {
    skip_if_not_installed("shiny")
    skip_if_not_installed("shinyWidgets")
    skip_if_not_installed("htmltools")
    
    meta <- data.frame(
        data_name = c("condA", "condB", "numX"),
        type = c("condition", "condition", "numeric"),
        stringsAsFactors = FALSE
    )

    call_data <- list(colnames = c("A", "B", "C"))
    call_args <- list(
        condA = c("A", "C"),
        condB = "B",
        disjoint = c("A", "A", "C")
    )

    rules <- data.frame(x = 1)  # dummy object
    attr(rules, "call_data") <- call_data
    attr(rules, "call_args") <- call_args

    ui <- callDataTable(rules, meta)
    html <- as.character(ui)

    expect_match(html, "^<table class=\"info-table")
    expect_match(html, "<thead>.*<th>column name</th>[^<]*<th>condA</th>[^<]*<th>condB</th>[^<]*<th>disjoint</th>.*</thead>")
    expect_match(html, "<tr>.*<td>A</td>[^<]*<td>[^<]*<span[^<]*\u2714</span>[^<]*</td>[^<]*<td></td>[^<]*<td>A</td>.*</tr>")
    expect_match(html, "<tr>.*<td>B</td>[^<]*<td></td>[^<]*<td>[^<]*<span[^<]*\u2714</span>[^<]*</td>[^<]*<td>A</td>.*</tr>")
    expect_match(html, "<tr>.*<td>C</td>[^<]*<td>[^<]*<span[^<]*\u2714</span>[^<]*</td>[^<]*<td></td>[^<]*<td>C</td>.*</tr>")
    expect_match(html, "</table>$")
})
