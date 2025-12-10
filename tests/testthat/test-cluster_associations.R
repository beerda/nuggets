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


test_that("cluster_associations()", {
    d <- data.frame(antecedent = c("{a,b}", "{a,c}", "{b,d}", "{d}", "{b,c}"),
                    consequent = c("{x}", "{x}", "{y}", "{y}", "{x}"),
                    support = c(0.5, 0.4, 0.3, 0.2, 0.6),
                    confidence = c(0.8, 0.7, 0.6, 0.5, 0.9),
                    lift = c(1.5, 1.4, 1.3, 1.2, 1.6))
    d <- nugget(d, "associations",
                call_function = "dig_associations",
                call_data = list(),
                call_args = list())

    res <- cluster_associations(d, 2, lift, predicates_in_label = 3)
    expect_true(is_tibble(res))
    expect_equal(nrow(res), 2)
    expect_equal(ncol(res), 6)
    expect_equal(colnames(res), c("cluster", "cluster_label", "consequent", "support", "confidence", "lift"))
    expect_equal(res$cluster, 1:2)
    expect_equal(as.character(res$cluster_label), c("3 rules: {a, b, c}", "2 rules: {d, b}"))
    expect_equal(as.character(res$consequent), c("{x}", "{y}"))
    expect_equal(res$support, c(0.5, 0.25))
    expect_equal(res$confidence, c(0.8, 0.55))
    expect_equal(res$lift, c(1.5, 1.25))

    cluster_predicates <- attr(res, "cluster_predicates")
    cluster_size <- attr(res, "cluster_size")
    expect_equal(length(cluster_predicates), 2)
    expect_equal(as.list(cluster_predicates[[1]]), list(a = 2, b = 2, c = 2))
    expect_equal(as.list(cluster_predicates[[2]]), list(d = 2, b = 1))
    expect_equal(cluster_size, c("1" = 3, "2" = 2))
})


test_that("cluster_associations() single row", {
    d <- data.frame(antecedent = c("{a,b}"),
                    consequent = c("{x}"),
                    support = c(0.5),
                    confidence = c(0.8),
                    lift = c(1.5))
    d <- nugget(d, "associations",
                call_function = "dig_associations",
                call_data = list(),
                call_args = list())

    expect_warning(
        res <- cluster_associations(d, 1, lift, predicates_in_label = 3),
        "The number of clusters `n` should be less than the number of distinct data points")
    expect_true(is_tibble(res))
    expect_equal(nrow(res), 1)
    expect_equal(ncol(res), 6)
    expect_equal(colnames(res), c("cluster", "cluster_label", "consequent", "support", "confidence", "lift"))
    expect_equal(res$cluster, 1)
    expect_equal(as.character(res$cluster_label), c("1 rules: {a, b}"))
    expect_equal(as.character(res$consequent), c("{x}"))
    expect_equal(res$support, c(0.5))
    expect_equal(res$confidence, c(0.8))
    expect_equal(res$lift, c(1.5))

    cluster_predicates <- attr(res, "cluster_predicates")
    cluster_size <- attr(res, "cluster_size")
    expect_equal(length(cluster_predicates), 1)
    expect_equal(as.list(cluster_predicates[[1]]), list(a = 1, b = 1))
    expect_equal(cluster_size, c("1" = 1))
})


test_that("cluster_associations() is order invariant", {
    d <- data.frame(antecedent = c("{a,b}", "{a,c}", "{b,d}", "{d}", "{b,c}"),
                    consequent = c("{x}", "{x}", "{y}", "{y}", "{x}"),
                    support = c(0.5, 0.4, 0.3, 0.2, 0.6),
                    confidence = c(0.8, 0.7, 0.6, 0.5, 0.9),
                    lift = c(1.5, 1.4, 1.3, 1.2, 1.6))
    d <- nugget(d, "associations",
                call_function = "dig_associations",
                call_data = list(),
                call_args = list())
    d <- d[rev(seq_len(nrow(d))), ]

    res <- cluster_associations(d, 2, lift, predicates_in_label = 3)
    expect_true(is_tibble(res))
    expect_equal(nrow(res), 2)
    expect_equal(ncol(res), 6)
    expect_equal(colnames(res), c("cluster", "cluster_label", "consequent", "support", "confidence", "lift"))
    expect_equal(res$cluster, 1:2)
    expect_equal(as.character(res$cluster_label), c("3 rules: {a, b, c}", "2 rules: {d, b}"))
    expect_equal(as.character(res$consequent), c("{x}", "{y}"))
    expect_equal(res$support, c(0.5, 0.25))
    expect_equal(res$confidence, c(0.8, 0.55))
    expect_equal(res$lift, c(1.5, 1.25))

    cluster_predicates <- attr(res, "cluster_predicates")
    cluster_size <- attr(res, "cluster_size")
    expect_equal(as.list(cluster_predicates[[1]]), list(a = 2, b = 2, c = 2))
    expect_equal(as.list(cluster_predicates[[2]]), list(d = 2, b = 1))
    expect_equal(cluster_size, c("1" = 3, "2" = 2))
})


test_that("cluster_associations() predicates_in_label", {
    d <- data.frame(antecedent = c("{a,b}", "{a,c}", "{b,d}", "{d}", "{b,c}"),
                    consequent = c("{x}", "{x}", "{y}", "{y}", "{x}"),
                    support = c(0.5, 0.4, 0.3, 0.2, 0.6),
                    confidence = c(0.8, 0.7, 0.6, 0.5, 0.9),
                    lift = c(1.5, 1.4, 1.3, 1.2, 1.6))
    d <- nugget(d, "associations",
                call_function = "dig_associations",
                call_data = list(),
                call_args = list())

    res <- cluster_associations(d, 2, lift, predicates_in_label = 2)
    expect_true(is_tibble(res))
    expect_equal(nrow(res), 2)
    expect_equal(ncol(res), 6)
    expect_equal(as.character(res$cluster_label), c("3 rules: {a, b, +1 item}", "2 rules: {d, b}"))
})
