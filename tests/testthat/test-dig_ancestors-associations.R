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


test_that("dig_ancestors of associations", {
    d <- data.frame(a = c(T, T, F, F, F),
                    b = c(T, T, T, T, F),
                    c = c(F, F, F, T, T),
                    d = c(T, T, F, T, T),
                    e = c(T, F, T, T, T))

    rules <- dig_associations(d,
                              antecedent = -e,
                              consequent = e,
                              min_support = 0,
                              min_confidence = 0)

    rule <- rules[rules$antecedent == "{a,b,c,d}", ]

    res <- dig_ancestors(rule, d)
    expect_true(is_nugget(res, "associations"))
    expect_true(is_tibble(res))
    expect_equal(attr(res, "call_function"), "dig_associations")
    expect_equal(nrow(res), nrow(rules))
    expect_equal(ncol(res), ncol(rules))
    expect_equal(res$antecedent, rules$antecedent)
    expect_equal(res$consequent, rules$consequent)
})


test_that("dig_ancestors preserves the input rule weights", {
    d <- data.frame(a = c(T, T, F, F),
                    b = c(T, F, T, F),
                    e = c(T, F, F, F),
                    w = c(1, 1, 10, 10))

    unweighted_rules <- dig_associations(d,
                                         antecedent = a:b,
                                         consequent = e,
                                         min_support = 0,
                                         min_confidence = 0)
    weighted_rules <- dig_associations(d,
                                       antecedent = a:b,
                                       consequent = e,
                                       weights = w,
                                       min_support = 0,
                                       min_confidence = 0)

    unweighted_rule <- unweighted_rules[unweighted_rules$antecedent == "{a,b}", ]
    weighted_rule <- weighted_rules[weighted_rules$antecedent == "{a,b}", ]

    unweighted_ancestors <- dig_ancestors(unweighted_rule, d)
    weighted_ancestors <- dig_ancestors(weighted_rule, d)
    expected_unweighted <- dig_associations(d,
                                            antecedent = a:b,
                                            consequent = e,
                                            min_support = 0,
                                            min_confidence = 0)
    expected_weighted <- dig_associations(d,
                                          antecedent = a:b,
                                          consequent = e,
                                          weights = w,
                                          min_support = 0,
                                          min_confidence = 0)

    expect_null(attr(unweighted_ancestors, "call_args")$weights)
    expect_equal(attr(weighted_ancestors, "call_args")$weights, "w")
    for (column in names(unweighted_ancestors)) {
        expect_equal(unweighted_ancestors[[column]], expected_unweighted[[column]])
        expect_equal(weighted_ancestors[[column]], expected_weighted[[column]])
    }
    expect_equal(unweighted_ancestors$support[unweighted_ancestors$antecedent == "{b}"],
                 1 / 4)
    expect_equal(weighted_ancestors$support[weighted_ancestors$antecedent == "{b}"],
                 1 / 22)
})
