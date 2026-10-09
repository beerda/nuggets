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
        if (!is.null(aa$runtime_millis)) {
            seconds <- aa$runtime_millis / 1000
            days <- floor(seconds / 86400)
            hours <- floor((seconds %% 86400) / 3600)
            minutes <- floor((seconds %% 3600) / 60)
            secs <- seconds %% 60
            aa$runtime_millis <- sprintf("%dd %02d:%02d:%05.2f", days, hours, minutes, secs)
        }
        vv <- unlist(aa)
        nn <- names(aa)
        nn <- gsub("_", " ", nn)
        nn <- gsub("$", ":", nn)
        nn <- gsub("runtime millis", "Search run time", nn)

        # make first letter uppercase
        nn <- paste0(toupper(substr(nn, 1, 1)), substr(nn, 2, nchar(nn)))

        df <- data.frame(nn, vv, stringsAsFactors = FALSE)
    }

    infoTable(df, class = "hlrows")
}
