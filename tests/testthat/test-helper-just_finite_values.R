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


test_that(".just_finite_values", {
  expect_equal(.just_finite_values(c(1.0, 2.0, NA, 3.0, NaN, -Inf, Inf)),
               c(1.0, 2.0, 3.0))
  expect_equal(.just_finite_values(c(1L, 2L, NA, 3L, NaN, -Inf, Inf)),
               c(1L, 2L, 3L))
})
