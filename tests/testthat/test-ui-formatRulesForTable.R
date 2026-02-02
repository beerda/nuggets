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


test_that("formatRulesForTable highlights condition columns", {
    .skip_if_shiny_not_installed()

    rules <- data.frame(id = 1:2, cond = c("A=1", "B=2"), score = c(0.1, 0.2))
    meta <- data.frame(
        data_name = c("cond", "score"),
        type = c("condition", "numeric"),
        round = c(NA, NA),
        stringsAsFactors = FALSE
    )

    res <- formatRulesForTable(rules, meta)
    expect_equal(res$cond, highlightCondition(rules$cond))
    expect_equal(colnames(res), c("id", "cond", "score"))
})

test_that("formatRulesForTable rounds numeric columns with round specified", {
    .skip_if_shiny_not_installed()

    rules <- data.frame(id = 1:3, val = c(1.111, 2.222, 3.333))
    meta <- data.frame(
        data_name = "val",
        type = "numeric",
        round = 2,
        stringsAsFactors = FALSE
    )

    res <- formatRulesForTable(rules, meta)
    expect_equal(res$val, round(rules$val, 2))
})

test_that("formatRulesForTable does not round numeric columns when round is NA", {
    .skip_if_shiny_not_installed()

    rules <- data.frame(val = c(1.2345, 2.3456))
    meta <- data.frame(
        data_name = "val",
        type = "numeric",
        round = NA_real_,
        stringsAsFactors = FALSE
    )

    res <- formatRulesForTable(rules, meta)
    expect_equal(res$val, rules$val)
})

test_that("formatRulesForTable handles data frame without id column", {
    .skip_if_shiny_not_installed()

    rules <- data.frame(cond = c("X=1"), num = 42)
    meta <- data.frame(
        data_name = c("cond", "num"),
        type = c("condition", "numeric"),
        round = c(NA, NA),
        stringsAsFactors = FALSE
    )

    res <- formatRulesForTable(rules, meta)
    expect_equal(colnames(res), c("cond", "num"))
})

test_that("formatRulesForTable preserves column order id + meta$data_name", {
    .skip_if_shiny_not_installed()

    rules <- data.frame(id = 10:11, a = 1:2, b = 3:4)
    meta <- data.frame(
        data_name = c("b", "a"),
        type = c("numeric", "numeric"),
        round = c(NA, NA),
        stringsAsFactors = FALSE
    )

    res <- formatRulesForTable(rules, meta)
    expect_equal(colnames(res), c("id", "b", "a"))
    expect_equal(res$b, rules$b)
    expect_equal(res$a, rules$a)
})

test_that("formatRulesForTable works with multiple types in mixed order", {
    .skip_if_shiny_not_installed()

    rules <- data.frame(id = 1, cond = "A=1", score = 0.9876, name = "rule")
    meta <- data.frame(
        data_name = c("cond", "score", "name"),
        type = c("condition", "numeric", "other"),
        round = c(NA, 3, NA),
        stringsAsFactors = FALSE
    )

    res <- formatRulesForTable(rules, meta)
    expect_equal(colnames(res), c("id", "cond", "score", "name"))
    expect_equal(res$score, round(rules$score, 3))
    expect_equal(res$cond, highlightCondition(rules$cond))
})
