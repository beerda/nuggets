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


test_that("dig_itemsets basic output", {
    d <- data.frame(a = c(T, T, F, F, F),
                    b = c(T, T, T, T, F),
                    c = c(F, F, F, T, T))

    res <- dig_itemsets(d,
                        items = everything(),
                        min_support = 0.0001)
    res <- res[order(res$length, res$itemset), ]

    expect_true(is_nugget(res, "itemsets"))
    expect_true(is_tibble(res))
    expect_equal(attr(res, "call_function"), "dig_itemsets")
    expect_equal(attr(res, "call_args")$items, c("a", "b", "c"))
    expect_equal(attr(res, "call_args")$min_support, 0.0001)
    expect_equal(colnames(res), c("itemset", "support", "n", "length"))
    expect_equal(res$itemset, c("{}", "{a}", "{b}", "{c}", "{a,b}", "{b,c}"))
    expect_equal(round(res$support, 6), c(1.0, 0.4, 0.8, 0.4, 0.4, 0.2))
    expect_equal(res$n, c(5, 2, 4, 2, 2, 1))
    expect_equal(res$length, c(0, 1, 1, 1, 2, 2))
})


test_that("dig_itemsets max_results limiting", {
    d <- data.frame(a = c(T, T, F, F, F),
                    b = c(T, T, T, T, F),
                    c = c(F, F, F, T, T))

    res <- dig_itemsets(d,
                        items = everything(),
                        min_support = 0.0001,
                        max_results = 3)

    expect_true(is_nugget(res, "itemsets"))
    expect_equal(nrow(res), 3)
    expect_equal(attr(res, "call_args")$max_results, 3)
})


test_that("dig_itemsets errors", {
    d <- matrix(rep(c(T, F), 10), ncol = 2)
    expect_error(dig_itemsets(as.list(d)), "`x` must be a matrix or a data frame.")
    expect_error(dig_itemsets(d, min_support = "x"),
                 "`min_support` must be a double scalar.")
    expect_error(dig_itemsets(d, max_results = "x"),
                 "`max_results` must be an integerish scalar.")
    expect_error(dig_itemsets(d, verbose = "x"),
                 "`verbose` must be a flag.")
})
