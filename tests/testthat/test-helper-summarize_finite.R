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


test_that(".summarize_finite", {
    expect_equal(.summarize_finite(c(1, 4, 2, 5, 3, NA, NaN, Inf, -Inf)),
                 data.frame(min = 1, Q1 = 2, median = 3, Q3 = 4, max = 5))
})
