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


test_that("rulebaseTable", {
    .skip_if_shiny_not_installed()

    
    rules <- data.frame(a = 1:3,
                        b = 4:6,
                        cond = c("x", "y", "x"))
    meta <- data.frame(data_name = c("a", "b", "cond"),
                       long_name = c("A", "B", "foobar"),
                       type = c("numeric", "numeric", "condition"),
                       stringsAsFactors = FALSE)

    ui <- rulebaseTable(rules, meta)
    html <- as.character(ui)

    expect_match(html, "^<table class=\"info-table")
    expect_match(html, "<td>Number of rules:</td>[^<]*<td>3</td>")
    expect_match(html, "<td>Number of columns:</td>[^<]*<td>3</td>")
    expect_match(html, "<td>Number of distinct foobars:</td>[^<]*<td>2</td>")
    expect_match(html, "</table>$")

    rules <- data.frame()
    ui <- rulebaseTable(rules, meta)
    html <- as.character(ui)

    expect_match(html, "^<table class=\"info-table")
    expect_match(html, "<td>Number of rules:</td>[^<]*<td>0</td>")
    expect_match(html, "<td>Number of columns:</td>[^<]*<td>0</td>")
    expect_match(html, "<td>Number of distinct foobars:</td>[^<]*<td>0</td>")
    expect_match(html, "</table>$")
})
