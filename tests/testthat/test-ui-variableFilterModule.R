#######################################################################
# nuggets: An R framework for exploration of patterns in data
# Copyright (C) 2026 Michal Burda
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



test_that("VariableFilterModule UI", {
    .skip_if_shiny_not_installed()

    meta <- tribble(
        ~data_name,          ~short_name,  ~long_name,           ~type,
        "xvar",              "xv",         "X-Variable",         "variable",
    )

    mod <- variableFilterModule("test",
                                x = c("a", "b", "c"),
                                meta = meta)

    ui <- mod$ui()
    html <- as.character(ui)
    expect_match(html, "^<div class=\"tab-pane\" title=\"X-Variable\"")
})

test_that(".create_tree_def_from_variables", {
    res <- .create_tree_def_from_variables(c("a", "b", "c", "b"), "variable")
    expect_equal(nrow(res), 3)
    expect_equal(res$rid, c("##root##", "##root##", "##root##"))
    expect_equal(res$rname, c("variable", "variable", "variable"))
    expect_equal(res$vid, c("v1", "v2", "v3"))
    expect_equal(res$value, c("a", "b", "c"))

    res <- .create_tree_def_from_variables(c("a", "a", "a", "a"), "variable")
    expect_equal(nrow(res), 1)

    res <- .create_tree_def_from_variables(character(0), "variable")
    expect_equal(nrow(res), 0)
})

test_that("VariableFilterModule - filter", {
    .skip_if_shiny_not_installed()

    meta <- tribble(
        ~data_name,          ~short_name,  ~long_name,           ~type,
        "xvar",              "xv",         "X-Variable",         "variable",
    )

    # all empty
    mod <- variableFilterModule("test",
                                x = c("a", "b", "c", "b"),
                                meta = meta)
    input <- list()
    res <- mod$filter(input)
    expect_equal(res, c(F, F, F, F))

    input <- list("test-tree" = c("v1"))
    res <- mod$filter(input)
    expect_equal(res, c(T, F, F, F))

    input <- list("test-tree" = c("v2"))
    res <- mod$filter(input)
    expect_equal(res, c(F, T, F, T))

    input <- list("test-tree" = c("##root##", "v1", "v2", "v3"))
    res <- mod$filter(input)
    expect_equal(res, c(T, T, T, T))
})
