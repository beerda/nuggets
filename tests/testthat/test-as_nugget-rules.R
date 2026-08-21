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


test_that("as_nugget arules::apriori", {
    skip_if_not_installed("arules")

    set.seed(2123)
    rows <- 100
    cols <- 5
    m <- matrix(sample(c(T, F), rows * cols, replace = TRUE),
                nrow = rows,
                ncol = cols)
    colnames(m) <- letters[seq_len(cols)]

    expected <- dig_associations(m,
                                 min_support = 0.001,
                                 min_length = 0,
                                 max_length = 5,
                                 min_confidence = 0.5)
    expected <- expected[order(expected$consequent, expected$antecedent), ]
    attr(expected, "search_stats") <- NULL
    attr(expected, "call_function") <- "arules::apriori"
    attr(expected, "call_args") <- list(data = "m",
                                        parameter = "list(minlen = 1, maxlen = 6, supp = 0.001, conf = 0.5)",
                                        control = "list(verbose = FALSE)")

    afit <- arules::apriori(m, parameter = list(minlen = 1,
                                        maxlen = 6,
                                        supp=0.001,
                                        conf = 0.5),
                    control = list(verbose = FALSE))

    res <- as_nugget(afit)
    res <- res[order(res$consequent, res$antecedent), ]

    expect_equal(res, expected)
})


test_that("as_nugget arules::eclat", {
    skip_if_not_installed("arules")

    set.seed(2123)
    rows <- 100
    cols <- 5
    m <- matrix(sample(c(T, F), rows * cols, replace = TRUE),
                nrow = rows,
                ncol = cols)
    colnames(m) <- letters[seq_len(cols)]

    expected <- dig_associations(m,
                                 min_support = 0.001,
                                 min_length = 1,
                                 max_length = 5,
                                 min_confidence = 0.5)
    expected <- expected[order(expected$consequent, expected$antecedent), ]
    attr(expected, "search_stats") <- NULL
    attr(expected, "call_function") <- "arules::eclat"
    attr(expected, "call_args") <- list(data = "m",
                                        parameter = "list(minlen = 1, maxlen = 6, supp = 0.001)",
                                        control = "list(verbose = FALSE)")

    efit <- arules::eclat(m, parameter = list(minlen = 1,
                                        maxlen = 6,
                                        supp=0.001),
                    control = list(verbose = FALSE))
    erules <- arules::ruleInduction(efit, confidence = 0.5)

    res <- as_nugget(erules)
    res <- res[order(res$consequent, res$antecedent), ]

    expect_equal(res, expected)
})
