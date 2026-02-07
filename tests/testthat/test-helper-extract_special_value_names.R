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


test_that(".extract_special_value_names", {
    expect_equal(.extract_special_value_names(NULL), NULL)
    expect_equal(.extract_special_value_names(1:5), NULL)
    expect_equal(.extract_special_value_names(c(1:5, NA)), c("NA"))
    expect_equal(.extract_special_value_names(c(1:5, NaN)), c("NaN"))
    expect_equal(.extract_special_value_names(c(1:5, -Inf)), c("-Inf"))
    expect_equal(.extract_special_value_names(c(1:5, Inf)), c("Inf"))

    expect_equal(.extract_special_value_names(c(1:5, Inf, NaN, NA)),
                 c("NA", "NaN", "Inf"))

    expect_equal(.extract_special_value_names(c(1:5, Inf, NaN, -Inf, NA, 1)),
                 c("-Inf", "NA", "NaN", "Inf"))
})
