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


searchStatsTable <- function(rules) {
    aa <- attributes(rules)$search_stats
    if (is.null(aa)) {
        df <- data.frame()
    } else {
        df <- data.frame(c("Search run time [s]:",
                           "Computed conjunctions:",
                           "Cached conjunctions:",
                           "Total conjunctions:",
                           "Found patterns:",
                           "Data representation:"),
                         c(signif(aa$runtime_millis / 1000, 2),
                           aa$computed_conjunctions,
                           aa$cached_conjunctions,
                           aa$total_conjunctions,
                           aa$found_patterns,
                           aa$data_representation),
                         stringsAsFactors = FALSE)
    }

    infoTable(df, class = "hlrows")
}
