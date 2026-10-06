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


test_that("is_from identifies data compatible with a nugget", {
    data <- data.frame(a = c(TRUE, FALSE, TRUE),
                       b = c(FALSE, TRUE, TRUE))
    nugget <- dig(data, function() 1)

    expect_true(is_from(nugget, data))
    expect_false(is_from(nugget, data[-1, ]))
    expect_false(is_from(nugget, data["a"]))
    expect_false(is_from(nugget, setNames(data, c("x", "y"))))
})
