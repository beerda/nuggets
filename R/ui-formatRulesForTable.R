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


formatRulesForTable <- function(rules, meta) {
    for (i in seq_len(nrow(meta))) {
        col <- meta$data_name[i]
        if (meta$type[i] == "condition") {
            rules[[col]] <- highlightCondition(rules[[col]])
        } else if (meta$type[i] == "numeric") {
            if (!is.na(meta$round[i])) {
                rules[[col]] <- round(rules[[col]], meta$round[i])
            }
        }
    }

    if ("id" %in% colnames(rules)) {
        rules <- rules[, c("id", meta$data_name), drop = FALSE]
        colnames(rules) <- c("id", meta$short_name)
    } else {
        rules <- rules[, meta$data_name, drop = FALSE]
        colnames(rules) <- meta$short_name
    }

    rules
}
