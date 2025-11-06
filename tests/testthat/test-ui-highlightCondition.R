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


test_that("highlightCondition highlights single predicate correctly", {
    .skip_if_shiny_not_installed()

    res <- highlightCondition("A=1")
    expect_match(res, "^<span class=\"pred_n\">A</span>=<span class=\"pred_v\">1</span>$")
})

test_that("highlightCondition highlights multiple predicates separated by commas", {
    .skip_if_shiny_not_installed()

    res <- highlightCondition("A=1,B=2")
    # It should insert <br/> between predicates
    expect_match(res, "<span class=\"pred_n\">A</span>=<span class=\"pred_v\">1</span><br/><span class=\"pred_n\">B</span>=<span class=\"pred_v\">2</span>")
    # Exactly two predicate-name spans
    expect_equal(length(regmatches(res, gregexpr("class=\"pred_n\"", res))[[1]]), 2)
})

test_that("highlightCondition removes braces", {
    .skip_if_shiny_not_installed()

    res <- highlightCondition("{A=1,B=2}")
    expect_false(grepl("[{}]", res))
})

test_that("highlightCondition escapes HTML special characters", {
    .skip_if_shiny_not_installed()

    res <- highlightCondition("A=<script>")
    # '<' and '>' should be HTML escaped
    expect_match(res, "&lt;script&gt;")
    expect_false(grepl("<script>", res, fixed = TRUE))
})

test_that("highlightCondition handles empty and missing equal sign gracefully", {
    .skip_if_shiny_not_installed()

    expect_equal(highlightCondition(""), "<span class=\"pred_n\"></span>")
    # With no '=', it should just wrap in pred_n span
    res <- highlightCondition("ABC")
    expect_match(res, "<span class=\"pred_n\">ABC</span>")
    expect_false(grepl("pred_v", res))
})
