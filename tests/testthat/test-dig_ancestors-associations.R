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


