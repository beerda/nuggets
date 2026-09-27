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


test_that("dig_itemsets computes weighted logical itemset characteristics", {
    weights <- 1:5 / 10
    d <- data.frame(a = c(T, T, F, T, F),
                    b = c(T, F, T, T, F),
                    c = c(F, T, T, T, F),
                    w = weights)

    res <- dig_itemsets(d,
                        items = a:c,
                        weights = w,
                        min_support = 0)
    res <- res[order(res$length, res$itemset), ]

    expected_n <- c(sum(weights),
                    sum(weights * d$a),
                    sum(weights * d$b),
                    sum(weights * d$c),
                    sum(weights * d$a * d$b),
                    sum(weights * d$a * d$c),
                    sum(weights * d$b * d$c),
                    sum(weights * d$a * d$b * d$c))

    expect_equal(attr(res, "call_args")$weights, "w")
    expect_equal(res$itemset,
                 c("{}", "{a}", "{b}", "{c}", "{a,b}", "{a,c}", "{b,c}",
                   "{a,b,c}"))
    expect_equal(res$n, expected_n, tolerance = 1e-6)
    expect_equal(res$support, expected_n / sum(weights), tolerance = 1e-6)
    expect_equal(res$length, c(0L, 1L, 1L, 1L, 2L, 2L, 2L, 3L))
})


test_that("dig_itemsets uses weighted support for min_support", {
    weights <- 1:5 / 10
    d <- data.frame(a = c(T, T, F, T, F),
                    b = c(T, F, T, T, F),
                    c = c(F, T, T, T, F),
                    w = weights)

    res <- dig_itemsets(d,
                        items = a:c,
                        weights = w,
                        min_support = 0.45)
    res <- res[order(res$length, res$itemset), ]

    expect_equal(res$itemset, c("{}", "{a}", "{b}", "{c}", "{b,c}"))
    expect_equal(res$support, c(1, c(0.7, 0.8, 0.9, 0.7) / sum(weights)),
                 tolerance = 1e-6)
    expect_true(all(res$support >= 0.45))
})


test_that("dig_itemsets computes weighted numeric itemset characteristics", {
    weights <- 1:5 / 10
    d <- data.frame(a = c(0.1, 0.7, 0.4, 0.9, 0.8),
                    b = c(0.3, 0.8, 0.6, 1.0, 0.2),
                    c = c(0.9, 0.5, 0.7, 0.6, 0.4),
                    w = weights)
    t_norms <- list(
        goedel = function(x, y) pmin(x, y),
        goguen = function(x, y) x * y,
        lukas = function(x, y) pmax(0, x + y - 1)
    )

    for (t_norm_name in names(t_norms)) {
        t_norm <- t_norms[[t_norm_name]]
        degrees <- list(
            "{}" = rep(1, nrow(d)),
            "{a}" = d$a,
            "{b}" = d$b,
            "{c}" = d$c,
            "{a,b}" = t_norm(d$a, d$b),
            "{a,c}" = t_norm(d$a, d$c),
            "{b,c}" = t_norm(d$b, d$c),
            "{a,b,c}" = t_norm(t_norm(d$a, d$b), d$c)
        )
        expected_n <- vapply(degrees, function(x) sum(weights * x), numeric(1))

        res <- dig_itemsets(d,
                            items = a:c,
                            weights = w,
                            min_support = 0,
                            t_norm = t_norm_name)
        res <- res[order(res$length, res$itemset), ]

        expect_equal(res$itemset, names(degrees), info = t_norm_name)
        expect_equal(res$n, unname(expected_n), tolerance = 1e-2,
                     info = t_norm_name)
        expect_equal(res$support, unname(expected_n / sum(weights)),
                     tolerance = 1e-2, info = t_norm_name)
        expect_equal(res$length, c(0L, 1L, 1L, 1L, 2L, 2L, 2L, 3L),
                     info = t_norm_name)
    }
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
