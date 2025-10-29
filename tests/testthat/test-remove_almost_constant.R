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
