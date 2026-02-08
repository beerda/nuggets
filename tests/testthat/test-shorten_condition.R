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


test_that("shorten_condition", {
    expect_equal(shorten_condition(NULL), NULL)
    expect_equal(shorten_condition(character(0)), character(0))

    expect_equal(shorten_condition(c("{a=1,b=100,c=3}", "{a=2}", "{b=100,c=3}"),
                                   method = "letters"),
                 c("{A,B,C}", "{D}", "{B,C}"))

    expect_equal(shorten_condition(c("{helloWorld=1}",
                                     "{helloWorld = 2}",
                                     "{c=3, helloWorld=1}"),
                                   method = "abbrev4"),
                 c("{hllW=1}", "{hllW=2}", "{c=3,hllW=1}"))

    expect_equal(shorten_condition(c("{helloWorld=1}",
                                     "{helloWorld = 2}",
                                     "{c=3, helloWorld=1}"),
                                   method = "abbrev8"),
                 c("{hellWrld=1}", "{hellWrld=2}", "{c=3,hellWrld=1}"))
})


test_that("shorten_condition errors", {
    # Test non-character input
    expect_error(shorten_condition(123),
                 "`x` must be a character vector or NULL")

    expect_error(shorten_condition(list("a", "b")),
                 "`x` must be a character vector or NULL")

    # Test invalid method
    expect_error(shorten_condition(c("{a=1}", "{b=2}"), method = "invalid"),
                 '`method` must be equal to one of: "letters", "abbrev4", "abbrev8", "none"')

    # Test too many unique predicates for letters method
    # Create a condition with more than 26 unique predicates
    conditions <- paste0("{", letters, "=1}")
    conditions <- c(conditions, "{z1=1}")  # 27th predicate
    expect_error(shorten_condition(conditions, method = "letters"),
                 "If `method` is \"letters\" the number of unique values in `x` must not be greater than 26.")
})
