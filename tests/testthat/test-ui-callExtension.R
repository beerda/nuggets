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


test_that("callExtension returns NULL if .extensions is NULL", {
    skip_if_not_installed("shiny")
    skip_if_not_installed("shinyWidgets")
    skip_if_not_installed("htmltools")
    
    res <- callExtension(NULL, "x")
    expect_null(res)
})

test_that("callExtension returns NULL if .id not found", {
    skip_if_not_installed("shiny")
    skip_if_not_installed("shinyWidgets")
    skip_if_not_installed("htmltools")
    
    ext <- list(a = 1, b = 2)
    res <- callExtension(ext, "missing")
    expect_null(res)
})

test_that("callExtension returns the extension value when not a function", {
    skip_if_not_installed("shiny")
    skip_if_not_installed("shinyWidgets")
    skip_if_not_installed("htmltools")
    
    ext <- list(msg = "hello")
    res <- callExtension(ext, "msg")
    expect_equal(res, "hello")
})

test_that("callExtension calls function extensions with arguments", {
    skip_if_not_installed("shiny")
    skip_if_not_installed("shinyWidgets")
    skip_if_not_installed("htmltools")
    
    ext <- list(sumfun = function(x, y) x + y)
    res <- callExtension(ext, "sumfun", 3, 4)
    expect_equal(res, 7)
})

test_that("callExtension passes through ... correctly", {
    skip_if_not_installed("shiny")
    skip_if_not_installed("shinyWidgets")
    skip_if_not_installed("htmltools")
    
    ext <- list(pastefun = function(...) paste(..., collapse = "-"))
    res <- callExtension(ext, "pastefun", "A", "B", "C")
    expect_equal(res, "A B C")

    ext <- list(pastefun = function(...) paste(..., collapse = "-"))
    res <- callExtension(ext, "pastefun", "A", "B", 1:3)
    expect_equal(res, "A B 1-A B 2-A B 3")
})

test_that("callExtension works with function returning NULL", {
    skip_if_not_installed("shiny")
    skip_if_not_installed("shinyWidgets")
    skip_if_not_installed("htmltools")
    
    ext <- list(none = function() NULL)
    res <- callExtension(ext, "none")
    expect_null(res)
})

test_that("callExtension ignores ... when extension is not a function", {
    skip_if_not_installed("shiny")
    skip_if_not_installed("shinyWidgets")
    skip_if_not_installed("htmltools")
    
    ext <- list(static = "constant")
    # Even though ... is provided, it should not fail
    res <- callExtension(ext, "static", "unused argument")
    expect_equal(res, "constant")
})

