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


rulebaseTable <- function(meta, rulesAfter, rulesBefore = NULL) {
    df <- .rulebaseTable(rulesAfter, meta)
    if (!is.null(rulesBefore)) {
        bf <- .rulebaseTable(rulesBefore, meta)
        n <- df[[1]]
        b <- bf[[2]]
        a <- df[[2]]
        df <- data.frame(n,
                         paste0(a, " / ", b, " (", round(100 * a / b, 0), "%)"))
    }

    infoTable(df, class = "hlrows")
}

.rulebaseTable <- function(rules, meta) {
    conds <- meta[meta$type == "condition", , drop= FALSE]
    distinct_condition_names <- paste0("Number of distinct ", tolower(conds$long_name), "s:")
    distinct_condition_counts <- vapply(conds$data_name, function(col) {
        length(unique(rules[[col]]))
    }, integer(1))

    data.frame(c("Number of rules:", "Number of columns:", distinct_condition_names),
               c(nrow(rules), ncol(rules), distinct_condition_counts),
               stringsAsFactors = FALSE)
}
