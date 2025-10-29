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


test_that(".wilcox_test error", {
    expect_warning(res <- .wilcox_test(NULL, 2),
                   "wilcox.test: error: 'x' must be numeric")
    expect_null(res)
})

test_that(".wilcox_test max p-value not reached", {
    x <- 1:20
    y <- 20:1
    expect_null(.wilcox_test(x = x, y = y, paired = FALSE, max_p_value = 0.05))
    expect_null(.wilcox_test(x = x, y = y, paired = TRUE, max_p_value = 0.05))
})

test_that(".wilcox_test one-sample", {
    x <- (-10):10
    res <- .wilcox_test(x = x,
                        mu = 0,
                        alternative = "two.sided",
                        exact = FALSE)

    expect_true(is.list(res))
    expect_equal(length(res), 9)
    expect_equal(res$estimate, 0)
    expect_equal(res$statistic, 105)
    expect_equal(res$p_value, 1)
    expect_equal(res$n, 21)
    expect_equal(res$conf_lo, -3, tolerance = 1e-4)
    expect_equal(res$conf_hi, 3, tolerance = 1e-4)
    expect_equal(res$alternative, "two.sided")
    expect_equal(res$method, "Wilcoxon signed rank test with continuity correction")
    expect_equal(res$comment, "")
})

test_that(".wilcox_test paired", {
    x <- 1:20
    y <- 20:1

    res <- .wilcox_test(x = x,
                        y = y,
                        paired = TRUE,
                        exact = FALSE,
                        alternative = "two.sided")

    expect_true(is.list(res))
    expect_equal(length(res), 9)
    expect_equal(res$estimate, 0)
    expect_equal(res$statistic, 105, tolerance = 1e-4)
    expect_equal(res$p_value, 1.0, tolerance = 1e-3)
    expect_equal(res$n, 20)
    expect_equal(res$conf_lo, -6, tolerance = 1e-4)
    expect_equal(res$conf_hi, 6, tolerance = 1e-4)
    expect_equal(res$alternative, "two.sided")
    expect_equal(res$method, "Wilcoxon signed rank test with continuity correction")
    expect_equal(res$comment, "")
})

test_that(".wilcox_test two-sample", {
    x <- 1:20
    y <- 3:20

    res <- .wilcox_test(x = x,
                        y = y,
                        paired = FALSE,
                        exact = FALSE,
                        alternative = "two.sided")

    expect_true(is.list(res))
    expect_equal(length(res), 10)
    expect_equal(res$estimate, -1)
    expect_equal(res$statistic, 162, tolerance = 1e-4)
    expect_equal(res$p_value, 0.60857, tolerance = 1e-4)
    expect_equal(res$n_x, 20)
    expect_equal(res$n_y, 18)
    expect_equal(res$conf_lo, -5, tolerance = 1e-4)
    expect_equal(res$conf_hi, 3, tolerance = 1e-4)
    expect_equal(res$alternative, "two.sided")
    expect_equal(res$method, "Wilcoxon rank sum test with continuity correction")
    expect_equal(res$comment, "")
})

test_that(".wilcox_test warning in comment", {
    x <- 1:20
    y <- x + 1

    res <- .wilcox_test(x = x,
                        y = y,
                        paired = TRUE,
                        exact = FALSE,
                        alternative = "two.sided")

    expect_true(is.list(res))
    expect_equal(length(res), 9)
    expect_equal(res$method, "Wilcoxon signed rank test with continuity correction")
    expect_equal(res$comment, "warning: cannot compute confidence interval when all observations are zero or tied")
})
