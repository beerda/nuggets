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


test_that("is_subset", {
    expect_true(is_subset(c(), c()))
    expect_true(is_subset(c(), 1:5))
    expect_true(is_subset(3:5, 1:8))
    expect_true(is_subset(3:5, 3:5))

    expect_false(is_subset(2:5, c()))
    expect_false(is_subset(2:5, 3:5))

    expect_error(is_subset(list(), list()))
    expect_error(is_subset(matrix(0, nrow = 3, ncol = 3),
                           matrix(0, nrow = 3, ncol = 3)))
})
