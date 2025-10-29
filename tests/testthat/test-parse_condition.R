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


test_that("parse_condition", {
    expect_equal(parse_condition(), list())
    expect_equal(parse_condition(character(0)), list())
    expect_equal(parse_condition("{}"), list(character(0)))
    expect_equal(parse_condition("{,}"), list(character(0)))
    expect_equal(parse_condition("{a,b,,c}"), list(c("a", "b", "c")))
    expect_equal(parse_condition("{a,b,,c,}"), list(c("a", "b", "c")))
    expect_equal(parse_condition("{,a,b,,c}"), list(c("a", "b", "c")))
    expect_equal(parse_condition("{,a,b,,c,}"), list(c("a", "b", "c")))

    expect_equal(parse_condition(c("{a}", "{x=1, z=2, y=3}", NA, "{}"),
                                 .sort = FALSE),
                 list(c("a"),
                      c("x=1", "z=2", "y=3"),
                      NA_character_,
                      character(0)))

    expect_equal(parse_condition(c("{a}", "{x=1, z=2, y=3}", NA, "{}"),
                                 .sort = TRUE),
                 list(c("a"),
                      c("x=1", "y=3", "z=2"),
                      NA_character_,
                      character(0)))

    expect_equal(parse_condition(c("{b}", "{x=1, z=2, y=3}", "{q}", "{}",      NA,    "{}"),
                                 c("{a}", "{v=10, w=11}",    "{}",  "{r,s,t}", "{l}", "{}"),
                                 .sort = FALSE),
                 list(c("b", "a"),
                      c("x=1", "z=2", "y=3", "v=10", "w=11"),
                      c("q"),
                      c("r", "s", "t"),
                      c(NA_character_, "l"),
                      character(0)))

    expect_equal(parse_condition(c("{b}", "{x=1, z=2, y=3}", "{q}", "{}",      NA,    "{}"),
                                 c("{a}", "{v=10, w=11}",    "{}",  "{r,s,t}", "{l}", "{}"),
                                 .sort = TRUE),
                 list(c("a", "b"),
                      c("v=10", "w=11", "x=1", "y=3", "z=2"),
                      c("q"),
                      c("r", "s", "t"),
                      c("l", NA_character_),
                      character(0)))
})


test_that("parse_condition argument recycling", {
    expect_equal(parse_condition(c("{b}", "{x=1, z=2, y=3}", "{q}", "{}",      NA,    "{}"),
                                 c("{gg}"),
                                 .sort = FALSE),
                 list(c("b", "gg"),
                      c("x=1", "z=2", "y=3", "gg"),
                      c("q", "gg"),
                      c("gg"),
                      c(NA_character_, "gg"),
                      c("gg")))

    expect_equal(parse_condition(c("{b}", "{x=1, z=2, y=3}", "{q}", "{}",      NA,    "{}"),
                                 c("{gg}"),
                                 .sort = TRUE),
                 list(c("b", "gg"),
                      c("gg", "x=1", "y=3", "z=2"),
                      c("gg", "q"),
                      c("gg"),
                      c("gg", NA_character_),
                      c("gg")))
})

test_that("parse_condtition errors", {
    expect_error(parse_condition(1:5),
                 "Arguments `...` must be character vectors.")
    expect_error(parse_condition("a", .sort = 2),
                 "`.sort` must be a flag")
})
