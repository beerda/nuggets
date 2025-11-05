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


test_that("is_degree", {
    expect_true(is_degree(0L))
    expect_true(is_degree(1L))
    expect_true(is_degree(0L:1L))
    expect_true(is_degree(0.5))
    expect_true(is_degree(c(0:100 / 100)))
    expect_true(is_degree(matrix(c(0:99 / 99), nrow = 25)))
    expect_true(is_degree(array(c(0:99 / 99), dim = c(2, 5, 10))))
    expect_true(is_degree(NA_real_, na_rm = TRUE))

    expect_false(is_degree(c()))
    expect_false(is_degree("0"))
    expect_false(is_degree(list(a=0)))
    expect_false(is_degree(2L))
    expect_false(is_degree(1.1))
    expect_false(is_degree(NA_real_, na_rm = FALSE))
    expect_false(is_degree(NA_character_, na_rm = TRUE))
})
