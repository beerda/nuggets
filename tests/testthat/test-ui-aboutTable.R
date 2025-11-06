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


test_that("aboutTable", {
    .skip_if_shiny_not_installed()

    
    ui <- aboutTable("stats")
    html <- as.character(ui)

    # Structure
    expect_match(html, paste0("^<div>\\n *",
                              "<table class=\"info-table left\" width=\"100%\">"))
    expect_match(html, "</table>\\n *</div>$")

    # Expected rows
    expect_match(html, "<tr>\\n *<td>Package:</td>\\n *<td>stats</td>\\n *</tr>")
    expect_match(html, "<td>Version:</td>")
    expect_match(html, "<td>Date:</td>")
    expect_match(html, "<td>Author:</td>")
    expect_match(html, "<td>License:</td>")
    expect_match(html, "<td>URL:</td>")
    expect_match(html, "<td>Bug reports:</td>")
    expect_match(html, "<td>Cite:</td>")
})
