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


test_that("must_be_vector", {
    x <- 1:5
    names(x) <- letters[1:5]
    expect_no_error(.must_be_vector(x))

    expect_no_error(.must_be_vector(1L:5L))
    expect_no_error(.must_be_vector(1:5 / 3))
    expect_no_error(.must_be_vector(letters[1:5]))

    expect_error(.must_be_vector(list(a=1)))
    expect_error(.must_be_vector(matrix(0, nrow = 2, ncol = 2)))
    expect_error(.must_be_vector(array(0, dim = c(1:3))))
    expect_error(.must_be_vector(factor(letters[1:5])))
    expect_error(.must_be_vector(structure(list(), class = "myclass")))
})
