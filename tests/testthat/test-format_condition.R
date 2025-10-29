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


test_that("format_condition", {
  expect_equal(format_condition(NULL), "{}")
  expect_equal(format_condition("a"), "{a}")
  expect_equal(format_condition(letters[1:4]), "{a,b,c,d}")

  expect_error(format_condition(1:4))
  expect_error(format_condition(list(a=letters[1:4])))
})
