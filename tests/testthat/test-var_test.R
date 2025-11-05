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


test_that(".var_test error", {
    expect_warning(res <- .var_test(NULL, 2),
                   "var.test: error: not enough 'x' observations")
    expect_null(res)
})

test_that(".var_test max p-value not reached", {
    x <- 1:20
    y <- 20:1
    expect_null(.var_test(x = x, y = y, max_p_value = 0.05))
})

test_that(".var_test two-sample", {
    x <- 1:20
    y <- 3:20

    res <- .var_test(x = x,
                     y = y,
                     alternative = "two.sided")

    expect_true(is.list(res))
    expect_equal(length(res), 10)
    expect_equal(res$estimate, 1.228, tolerance = 1e-4)
    expect_equal(res$statistic, 1.228, tolerance = 1e-4)
    expect_equal(res$p_value, 0.67511, tolerance = 1e-4)
    expect_equal(res$n_x, 20)
    expect_equal(res$n_y, 18)
    expect_equal(res$conf_lo, 0.46639, tolerance = 1e-4)
    expect_equal(res$conf_hi, 3.1524, tolerance = 1e-4)
    expect_equal(res$alternative, "two.sided")
    expect_equal(res$method, "F test to compare two variances")
    expect_equal(res$comment, "")
})
