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


test_that("creationParamsTable", {
    skip_if_not_installed("shiny")
    skip_if_not_installed("shinyWidgets")
    skip_if_not_installed("htmltools")
    
    rules <- data.frame(x = 1:3)
    attr(rules, "call_function") <- "dig_tautologies"
    attr(rules, "call_args") <- list(
        min_support = 0.5,
        min_confidence = 0.7
    )

    ui <- creationParamsTable(rules)
    html <- as.character(ui)

    expect_match(html, "^<p>Generated using the function <a href=\"https://beerda.github.io/nuggets/reference/dig_tautologies\\.html\">dig_tautologies\\(\\)</a> with the following parameters:</p>")
    expect_match(html, "<td>min_support =</td>[^<]*<td><pre><code class=\"language-r\">0\\.5.*</code></pre>[^<]*</td>")
    expect_match(html, "<td>min_confidence =</td>[^<]*<td><pre><code class=\"language-r\">0\\.7.*</code></pre>[^<]*</td>")
})

