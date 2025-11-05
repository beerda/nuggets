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


test_that(".parse_tree_def_from_condition - border cases", {
    def <- .parse_tree_def_from_condition(parse_condition(character(0)), root_name = "root")
    expect_equal(def, data.frame())

    def <- .parse_tree_def_from_condition(parse_condition("{}"), root_name = "root")
    expect_equal(def, data.frame())
})

test_that(".parse_tree_def_from_condition - no subnodes", {
    def <- .parse_tree_def_from_condition(parse_condition(c("{a,b}", "{b,c}")),
                                          root_name = "root")
    expect_equal(def,
                 data.frame(nid = c("n1", "n2", "n3"),
                            vid = c(NA_character_, NA_character_, NA_character_),
                            rid = rep("root", 3),
                            predicate = c("a", "b", "c"),
                            name = c("a", "b", "c"),
                            value = c(NA_character_, NA_character_, NA_character_)))
})

test_that(".parse_tree_def_from_condition - with subnodes", {
    def <- .parse_tree_def_from_condition(parse_condition(c("{a,b=1}", "{b=2,c}")),
                                          root_name = "predicate")
    expect_equal(def,
                 data.frame(nid = c("n1", "n2", "n2", "n3"),
                            vid = c(NA_character_, "v2", "v3", NA_character_),
                            rid = rep("predicate", 4),
                            predicate = c("a", "b=1", "b=2", "c"),
                            name = c("a", "b", "b", "c"),
                            value = c(NA_character_, "= 1", "= 2", NA_character_)))
})

test_that(".parse_tree_def_from_condition - complex (<= 50)", {
    def <- .parse_tree_def_from_condition(parse_condition(c("{A=1,B=2}", "{A=2,C=3}", "{B=1,C=2}", "{}")),
                                          root_name = "root")
    expect_equal(is.data.frame(def), TRUE)
    expect_equal(ncol(def), 6)
    expect_equal(nrow(def), 6)
    expect_equal(colnames(def), c("nid", "vid", "rid", "predicate", "name", "value"))
    expect_equal(def$nid, c("n1", "n1", "n2", "n2", "n3", "n3"))
    expect_equal(def$vid, paste0("v", 1:6))
    expect_equal(def$rid, rep("root", 6))
    expect_equal(def$predicate, c("A=1", "A=2", "B=1", "B=2", "C=2", "C=3"))
    expect_equal(def$name, c("A", "A", "B", "B", "C", "C"))
    expect_equal(def$value, c("= 1", "= 2", "= 1", "= 2", "= 2", "= 3"))
})

test_that(".parse_tree_def_from_condition - >50, no subnodes", {
    def <- .parse_tree_def_from_condition(parse_condition(c(sprintf("x%02d", 1:30), sprintf("y%02d", 1:30))),
                                          root_name = "root")
    expect_equal(def,
                 data.frame(nid = paste0("n", 1:60),
                            vid = rep(NA_character_, 60),
                            rid = rep("root", 60),
                            predicate = c(sprintf("x%02d", 1:30), sprintf("y%02d", 1:30)),
                            name = c(sprintf("x%02d", 1:30), sprintf("y%02d", 1:30)),
                            value = rep(NA_character_, 60),
                            pid = c(rep("X...", 30), rep("Y...", 30))))
})

test_that("ConditionFilterModule - ui: with empty condition", {
    skip_if_not_installed("shiny")
    skip_if_not_installed("shinyWidgets")
    skip_if_not_installed("htmltools")
    
    meta <- tribble(
        ~data_name,   ~short_name,  ~long_name,   ~type,
        "antecedent", "antecedent", "Antecedent", "condition"
    )

    mod <- conditionFilterModule(id = "test",
                                 x = c("{A=1,B=2}", "{A=2,B=2,C=3}", "{C=3}", "{}"),
                                 meta = meta)

    ui <- mod$ui()
    html <- as.character(ui)
    expect_match(html, "^<div class=\"tab-pane\" title=\"Antecedent\"")
    expect_match(html, "<input id=\"test-emptyCondition\" type=\"checkbox\"")

})

test_that("ConditionFilterModule - ui: without empty condition", {
    skip_if_not_installed("shiny")
    skip_if_not_installed("shinyWidgets")
    skip_if_not_installed("htmltools")
    
    meta <- tribble(
        ~data_name,   ~short_name,  ~long_name,   ~type,
        "antecedent", "antecedent", "Antecedent", "condition"
    )

    mod <- conditionFilterModule(id = "test",
                                 x = c("{A=1,B=2}", "{A=2,B=2,C=3}", "{C=3}", "{C=3}"),
                                 meta = meta)

    ui <- mod$ui()
    html <- as.character(ui)
    expect_match(html, "^<div class=\"tab-pane\" title=\"Antecedent\"")
    expect_no_match(html, "<input id=\"test-emptyCondition\" type=\"checkbox\"")

})

test_that("ConditionFilterModule - filter", {
    skip_if_not_installed("shiny")
    skip_if_not_installed("shinyWidgets")
    skip_if_not_installed("htmltools")
    
    meta <- tribble(
        ~data_name,   ~short_name,  ~long_name,   ~type,
        "antecedent", "antecedent", "Antecedent", "condition"
    )

    # all empty
    mod <- conditionFilterModule(id = "test",
                                 x = c("{A=1,B=2}", "{A=2,B=2,C=3}", "{C=3}", "{}"),
                                 meta = meta)
    input <- list()
    res <- mod$filter(input)
    expect_equal(res, c(F, F, F, F))

    mod <- conditionFilterModule(id = "test",
                                 x = c("{A=1,B=2}", "{A=2,B=2,C}", "{C}", "{}"),
                                 meta = meta)
    input <- list("test-tree" = c("v1"), # A=1
                  "test-radio" = "any",
                  "test-emptyCondition" = FALSE)
    res <- mod$filter(input)
    expect_equal(res, c(T, F, F, F))

    mod <- conditionFilterModule(id = "test",
                                 x = c("{A=1,B=2}", "{A=2,B=2,C}", "{C}", "{}"),
                                 meta = meta)
    input <- list("test-tree" = c("v1"), # A=1
                  "test-radio" = "any",
                  "test-emptyCondition" = TRUE)
    res <- mod$filter(input)
    expect_equal(res, c(T, F, F, T))

    mod <- conditionFilterModule(id = "test",
                                 x = c("{A=1,B=2}", "{A=2,B=2,C}", "{C}", "{}"),
                                 meta = meta)
    input <- list("test-tree" = c("v1"), # A=1
                  "test-radio" = "all",
                  "test-emptyCondition" = FALSE)
    res <- mod$filter(input)
    expect_equal(res, c(F, F, F, F))

    mod <- conditionFilterModule(id = "test",
                                 x = c("{A=1,B=2}", "{A=2,B=2,C}", "{C}", "{}"),
                                 meta = meta)
    input <- list("test-tree" = c("v1"), # A=1
                  "test-radio" = "all",
                  "test-emptyCondition" = TRUE)
    res <- mod$filter(input)
    expect_equal(res, c(F, F, F, T))

    mod <- conditionFilterModule(id = "test",
                                 x = c("{A=1,B=2}", "{A=2,B=2,C}", "{C}", "{}"),
                                 meta = meta)
    input <- list("test-tree" = c("n3"), # C
                  "test-radio" = "any",
                  "test-emptyCondition" = FALSE)
    res <- mod$filter(input)
    expect_equal(res, c(F, T, T, F))

    mod <- conditionFilterModule(id = "test",
                                 x = c("{A=1,B=2}", "{A=2,B=2,C}", "{C}", "{}"),
                                 meta = meta)
    input <- list("test-tree" = c("n3"), # C
                  "test-radio" = "any",
                  "test-emptyCondition" = TRUE)
    res <- mod$filter(input)
    expect_equal(res, c(F, T, T, T))

    mod <- conditionFilterModule(id = "test",
                                 x = c("{A=1,B=2}", "{A=2,B=2,C}", "{C}", "{}"),
                                 meta = meta)
    input <- list("test-tree" = c("n3"), # C
                  "test-radio" = "all",
                  "test-emptyCondition" = FALSE)
    res <- mod$filter(input)
    expect_equal(res, c(F, F, T, F))

    mod <- conditionFilterModule(id = "test",
                                 x = c("{A=1,B=2}", "{A=2,B=2,C}", "{C}", "{}"),
                                 meta = meta)
    input <- list("test-tree" = c("n3"), # C
                  "test-radio" = "all",
                  "test-emptyCondition" = TRUE)
    res <- mod$filter(input)
    expect_equal(res, c(F, F, T, T))

    mod <- conditionFilterModule(id = "test",
                                 x = c("{A=1,B=2}", "{A=2,B=2,C}", "{C}", "{}"),
                                 meta = meta)
    input <- list("test-tree" = c("v1", "n2", "v3"), # A=1, B=2
                  "test-radio" = "all",
                  "test-emptyCondition" = TRUE)
    res <- mod$filter(input)
    expect_equal(res, c(T, F, F, T))

    mod <- conditionFilterModule(id = "test",
                                 x = c("{A=1,B=2}", "{A=2,B=2,C}", "{C}", "{}"),
                                 meta = meta)
    input <- list("test-tree" = c("v1", "n2", "v3"), # A=1, B=2
                  "test-radio" = "any",
                  "test-emptyCondition" = TRUE)
    res <- mod$filter(input)
    expect_equal(res, c(T, T, F, T))

    mod <- conditionFilterModule(id = "test",
                                 x = c("{A=1,B=2}", "{A=2,B=2,C}", "{C}", "{}"),
                                 meta = meta)
    input <- list("test-tree" = c("predicate", "n1", "v1", "v2", "n2", "v3", "n3"), # A=1, A=2, B=2, C
                  "test-radio" = "all",
                  "test-emptyCondition" = TRUE)
    res <- mod$filter(input)
    expect_equal(res, c(T, T, T, T))

    mod <- conditionFilterModule(id = "test",
                                 x = c("{A=1,B=2}", "{A=2,B=2,C}", "{C}", "{}"),
                                 meta = meta)
    input <- list("test-tree" = c("predicate", "n1", "v1", "v2", "n2", "v3", "n3"), # A=1, A=2, B=2, C
                  "test-radio" = "all",
                  "test-emptyCondition" = FALSE)
    res <- mod$filter(input)
    expect_equal(res, c(T, T, T, F))
})



