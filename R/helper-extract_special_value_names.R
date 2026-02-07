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


.extract_special_value_names <- function(x) {
    special <- NULL
    if (any(x == -Inf, na.rm = TRUE)) {
        special <- c(special, "-Inf")
    }
    if (any(is.na(x) & !is.nan(x))) {
        special <- c(special, "NA")
    }
    if (any(is.nan(x), na.rm = TRUE)) {
        special <- c(special, "NaN")
    }
    if (any(x == Inf, na.rm = TRUE)) {
        special <- c(special, "Inf")
    }

    special
}
