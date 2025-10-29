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


test_that(".convert_data_to_list", {
  x <- data.frame(a = 1:3, b = 4:6)
  expect_equal(.convert_data_to_list(x),
               list(a = 1:3, b = 4:6))

  x <- matrix(1:6,
              nrow = 2,
              dimnames = list(NULL, c("a", "b", "c")))
  expect_equal(.convert_data_to_list(x),
               list(a = 1:2, b = 3:4, c = 5:6))

  x <- 1:3
  expect_error(.convert_data_to_list(x),
               "must be a matrix or a data frame")

  x <- data.frame()
  expect_error(.convert_data_to_list(x),
               "must have at least one column")

  x <- data.frame(a = numeric(0))
  expect_error(.convert_data_to_list(x),
               "must have at least one row")
})
