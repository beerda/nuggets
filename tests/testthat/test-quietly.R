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


test_that("quietly error", {
    f <- function() {
        stop("a")
        1
    }

    expect_equal(.quietly(f()),
                 list(result = NULL,
                      comment = "error: a"))
})

test_that("quietly warning", {
    f <- function() {
        warn("a")
        1
    }

    expect_equal(.quietly(f()),
                 list(result = 1,
                      comment = "warning: a"))
})

test_that("quietly message", {
    f <- function() {
        message("a")
        1
    }

    expect_equal(.quietly(f()),
                 list(result = 1,
                      comment = "message: a"))
})

test_that("quietly normal execution", {
    f <- function() {
        1
    }

    expect_equal(.quietly(f()),
                 list(result = 1,
                      comment = ""))
})
