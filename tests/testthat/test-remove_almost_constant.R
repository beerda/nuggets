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


test_that("remove_almost_constant empty tibble", {
    d <- data.frame(a = logical(0),
                    b = numeric(0))

    res <- remove_almost_constant(d, .threshold = 1.0, .na_rm = FALSE)
    expect_equal(res, tibble())
})


test_that("remove_almost_constant variants", {
    d <- data.frame(a1 = 1:10,
                    a2 = c(1:9, NA),
                    b1 = "b",
                    b2 = NA,
                    c1 = rep(c(T,F), 5),
                    c2 = rep(c(T,NA), 5),
                    d = c(T,T,T,T,F,F,F,F,NA,NA))

    res <- remove_almost_constant(d, .threshold = 1.0, .na_rm = FALSE)
    expect_equal(res, as_tibble(d[, c("a1", "a2", "c1", "c2", "d")]))

    res <- remove_almost_constant(d, .threshold = 1.0, .na_rm = TRUE)
    expect_equal(res, as_tibble(d[, c("a1", "a2", "c1", "d")]))

    res <- remove_almost_constant(d, .threshold = 0.5, .na_rm = FALSE)
    expect_equal(res, as_tibble(d[, c("a1", "a2", "d")]))

    res <- remove_almost_constant(d, .threshold = 0.5, .na_rm = TRUE)
    expect_equal(res, as_tibble(d[, c("a1", "a2")]))

    res <- remove_almost_constant(d, a1:b2, .threshold = 0.5, .na_rm = TRUE)
    expect_equal(res, as_tibble(d[, c("a1", "a2", "c1", "c2", "d")]))
})


test_that("remove_almost_constant errors", {
    d <- data.frame(a = 1:10, b = "x", c = TRUE)

    # Test non-data frame input
    expect_error(remove_almost_constant(as.list(d)),
                 "`.data` must be a data frame")

    # Test invalid .threshold type
    expect_error(remove_almost_constant(d, .threshold = "x"),
                 "`.threshold` must be a double scalar")

    # Test .threshold out of range
    expect_error(remove_almost_constant(d, .threshold = -0.1),
                 "`.threshold` must be between 0 and 1")
    expect_error(remove_almost_constant(d, .threshold = 1.1),
                 "`.threshold` must be between 0 and 1")

    # Test invalid .verbose type
    expect_error(remove_almost_constant(d, .verbose = "TRUE"),
                 "`.verbose` must be a flag")
})


test_that("remove_almost_constant messages", {
    d <- data.frame(a = 1:10,
                    b = rep("x", 10),
                    c = rep(TRUE, 10))

    # Test message when .verbose = TRUE and columns are removed
    expect_message(remove_almost_constant(d, .threshold = 1.0, .verbose = TRUE),
                   "Removing \\(almost\\) constant columns: b, c")

    # Test no message when .verbose = FALSE
    expect_silent(remove_almost_constant(d, .threshold = 1.0, .verbose = FALSE))

    # Test message with unnamed data frame
    d_unnamed <- d
    names(d_unnamed) <- NULL
    expect_message(remove_almost_constant(d_unnamed, .threshold = 1.0, .verbose = TRUE),
                   "Removing \\(almost\\) constant columns: 2, 3")

    # Test no message when no columns are removed
    d2 <- data.frame(a = 1:10, b = 11:20, c = rep(c(TRUE, FALSE), 5))
    expect_silent(remove_almost_constant(d2, .threshold = 1.0, .verbose = TRUE))
})
