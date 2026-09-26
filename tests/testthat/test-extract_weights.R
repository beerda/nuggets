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


test_that(".extract_weights", {
    x <- list(a = c(T,T,F),
              b = c(1.5, 0.1, 100),
              c = c(-1, 0, 1),
              d = c(Inf, 1, 2))

    expect_equal(.extract_weights(x, NULL),
                 list(name = character(),
                      value = numeric()))

    expect_equal(.extract_weights(x, b),
                 list(name = "b",
                      value = c(1.5, 0.1, 100)))

    expect_error(.extract_weights(x, a:b), "must select at most one column")
    expect_error(.extract_weights(x, c), "must be numeric")
    expect_error(.extract_weights(x, d), "must be numeric")
    expect_error(.extract_weights(x, a), "must be numeric")
})
