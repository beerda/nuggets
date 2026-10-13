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


test_that("filter_satisfying and filter_violating select complementary rows", {
    d <- data.frame(a = c(1, 0.8, 0.5, 0.2, 0),
                    b = c(0.5, 1, 0.5, 0, 1))

    expect_equal(filter_satisfying(d, "{a,b}", threshold = 0.5),
                 d[c(1, 2), , drop = FALSE])
    expect_equal(filter_violating(d, "{a,b}", threshold = 0.5),
                 d[c(3, 4, 5), , drop = FALSE])
})

test_that("condition filters use the default threshold for crisp data", {
    d <- data.frame(a = c(TRUE, TRUE, FALSE, FALSE),
                    b = c(TRUE, FALSE, TRUE, FALSE))

    expect_equal(filter_satisfying(d, "{a,b}"),
                 d[1, , drop = FALSE])
    expect_equal(filter_violating(d, "{a,b}"),
                 d[c(2, 3, 4), , drop = FALSE])
})

test_that("condition filters respect t-norms and preserve matrix inputs", {
    x <- matrix(c(0.8, 0.8, 0.2,
                  0.9, 0.4, 0.7),
                ncol = 2,
                dimnames = list(NULL, c("a", "b")))

    expect_equal(filter_satisfying(x, "{a,b}", threshold = 0.35,
                                   t_norm = "goedel"),
                 x[c(1, 2), , drop = FALSE])
    expect_equal(filter_satisfying(x, "{a,b}", threshold = 0.35,
                                   t_norm = "goguen"),
                 x[1, , drop = FALSE])
    expect_equal(filter_violating(x, "{}", threshold = 1),
                 x[0, , drop = FALSE])
})

test_that("condition filters validate their arguments", {
    d <- data.frame(a = c(1, 0.5), b = c(0.5, 1))

    expect_error(filter_satisfying(TRUE, "{a}"),
                 "`x` must be a matrix or a data frame")
    expect_error(filter_satisfying(d, c("{a}", "{b}")),
                 "`condition` must be a character scalar")
    expect_error(filter_satisfying(d, "{a}", threshold = 1L),
                 "`threshold` must be a double scalar")
    expect_error(filter_satisfying(d, "{a}", threshold = 1.1),
                 "`threshold` must be between")
    expect_error(filter_satisfying(d, "{a}", t_norm = "foo"),
                 "`t_norm` must be equal to one of")
    expect_error(filter_violating(d, "{z}"),
                 "Can't find some column names in `x` that correspond to all predicates in `condition`.")
})
