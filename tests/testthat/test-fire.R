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


test_that("fire numeric", {
    d <- data.frame(a = c(  1, 0.8, 0.5, 0.2,   0),
                    b = c(0.5,   1, 0.5,   0,   1),
                    c = c(0.9, 0.9, 0.1, 0.8, 0.7))

    res <- fire(d, character(0))
    expect_equal(res, matrix(1, nrow=5, ncol=0))

    res <- fire(d, "{}")
    expect_equal(res, matrix(1, nrow=5, ncol=1))

    res <- fire(d, "{c}")
    expect_equal(res, matrix(d$c, nrow=5, ncol=1))

    res <- fire(d, "{a,b}")
    expect_equal(res, matrix(d$a * d$b, nrow=5, ncol=1))

    res <- fire(d, c("{a,c}", "{}", "{a,b,c}"))
    expect_equal(res,
                 matrix(c(d$a * d$c,
                          rep(1, nrow(d)),
                          d$a * d$b * d$c),
                          nrow=5, ncol=3))
})

test_that("fire logical", {
    d <- data.frame(a = c(T, T, T, F, F),
                    b = c(T, F, T, F, T),
                    c = c(F, F, T, T, T))

    res <- fire(d, character(0))
    expect_equal(res, matrix(1, nrow=5, ncol=0))

    res <- fire(d, "{}")
    expect_equal(res, matrix(1, nrow=5, ncol=1))

    res <- fire(d, "{c}")
    expect_equal(res, matrix(1 * d$c, nrow=5, ncol=1))

    res <- fire(d, "{a,b}")
    expect_equal(res, matrix(d$a * d$b, nrow=5, ncol=1))

    res <- fire(d, c("{a,c}", "{}", "{a,b,c}"))
    expect_equal(res,
                 matrix(c(d$a * d$c,
                          rep(1, nrow(d)),
                          d$a * d$b * d$c),
                          nrow=5, ncol=3))
})

test_that("fire t-norms", {
    d <- data.frame(a = c(  1, 0.8, 0.5, 0.2,   0),
                    b = c(0.5,   1, 0.5,   0,   1),
                    c = c(0.9, 0.9, 0.1, 0.8, 0.7))

    res <- fire(d,
                c("{a,c}", "{}", "{a,b,c}"),
                t_norm = "goedel")
    expect_equal(res,
                 matrix(c(pmin(d$a, d$c),
                          rep(1, nrow(d)),
                          pmin(d$a, d$b, d$c)),
                          nrow=5, ncol=3))

    res <- fire(d,
                c("{a,c}", "{}", "{a,b,c}"),
                t_norm = "goguen")
    expect_equal(res,
                 matrix(c(d$a * d$c,
                          rep(1, nrow(d)),
                          d$a * d$b * d$c),
                          nrow=5, ncol=3))

    res <- fire(d,
                c("{a,c}", "{}", "{a,b,c}"),
                t_norm = "lukas")
    expect_equal(res,
                 matrix(c(0.9, 0.7, 0, 0, 0,
                          1, 1, 1, 1, 1,
                          0.4, 0.7, 0, 0, 0),
                          nrow=5, ncol=3))
})

test_that("fire errors", {
    d <- data.frame(a = c(  1, 0.8, 0.5, 0.2,   0),
                    b = c(0.5,   1, 0.5,   0,   1),
                    c = c(0.9, 0.9, 0.1, 0.8, 0.7))

    expect_error(fire(TRUE, "{}"),
                 "`x` must be a matrix or a data frame")

    expect_error(fire(d, TRUE),
                 "`condition` must be a character vector")

    expect_error(fire(d, "{z}"),
                 "Can't find some column names in `x` that correspond to all predicates in `condition`.")

    expect_error(fire(d, "{a}", t_norm = "foo"),
                 "`t_norm` must be equal to one of")
})
