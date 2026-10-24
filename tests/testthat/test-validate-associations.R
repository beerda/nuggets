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


test_that("validate recomputes exactly the selected association rules", {
    d <- data.frame(a = c(TRUE, TRUE, FALSE, FALSE),
                    b = c(TRUE, FALSE, TRUE, FALSE),
                    c = c(TRUE, TRUE, FALSE, FALSE),
                    d = c(FALSE, TRUE, TRUE, FALSE))
    rules <- dig_associations(d,
                              antecedent = a:b,
                              consequent = c:d,
                              min_support = 0)
    rules <- rules[c(4, 2), ]

    new_d <- data.frame(a = c(TRUE, FALSE, TRUE),
                        b = c(FALSE, TRUE, TRUE),
                        c = c(TRUE, FALSE, TRUE),
                        d = c(FALSE, TRUE, TRUE))
    res <- validate(rules, new_d)

    expect_true(is_nugget(res, "associations"))
    expect_equal(res$antecedent, rules$antecedent)
    expect_equal(res$consequent, rules$consequent)
    expect_equal(res$support, c(1 / 3, 2 / 3))
    expect_equal(res$confidence, c(1 / 2, 2 / 3))
    expect_equal(attr(res, "call_function"), "dig_associations")
    expect_equal(attr(res, "call_data")$nrow, nrow(new_d))
    expect_equal(attr(res, "call_data")$ncol, ncol(new_d))
    expect_equal(attr(res, "call_data")$colnames, as.character(colnames(new_d)))
    expect_named(attr(res, "call_args"),
                 c("x", "antecedent", "consequent", "weights", "disjoint",
                   "excluded", "exact", "min_length", "max_length",
                   "min_coverage", "min_support", "min_confidence",
                   "contingency_table", "t_norm", "max_results", "verbose",
                   "threads"))
    expect_equal(attr(res, "call_args")$antecedent,
                 unique(unlist(parse_condition(rules$antecedent))))
    expect_equal(attr(res, "call_args")$consequent,
                 unique(unlist(parse_condition(rules$consequent))))
    expect_equal(attr(res, "call_args")$exact, parse_condition(rules$antecedent))
    expect_equal(attr(res, "call_args")$min_support, 0)
    expect_equal(attr(res, "call_args")$min_confidence, 0)
})


test_that("validate requires predicate columns used by association rules", {
    d <- data.frame(a = c(TRUE, FALSE),
                    b = c(TRUE, TRUE))
    rules <- dig_associations(d, a, b, min_support = 0)

    expect_error(validate(rules, d["a"]),
                 "must contain every predicate")
})


test_that("validate retains rules with zero support on new data", {
    d <- data.frame(a = c(TRUE, FALSE),
                    b = c(TRUE, FALSE))
    rules <- dig_associations(d, a, b, min_support = 0)
    new_d <- transform(d, b = FALSE)

    res <- validate(rules, new_d)

    expect_equal(res$antecedent, rules$antecedent)
    expect_equal(res$consequent, rules$consequent)
    expect_equal(res$support, c(0, 0))
    expect_equal(res$conseq_support, c(0, 0))
})
