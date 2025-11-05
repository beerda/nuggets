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


creationParamsTable <- function(rules) {
    aa <- attributes(rules)
    fun <- paste0("Generated using the function [",
                  aa$call_function,
                  "()](https://beerda.github.io/nuggets/reference/",
                  aa$call_function,
                  ".html) with the following parameters:")
    fun <- markdown(fun)

    args <- lapply(aa$call_args, function(x) {
        markdown(paste0("```r\n",
                        paste(deparse(x), collapse = ""),
                        "\n```"))
    })

    # do not present arguments containing variable names as usual values
    for (x in c("x")) {
        if (!is.null(args[[x]])) {
            args[[x]] <- markdown(paste0("```r\n",
                                         paste(aa$call_args[[x]], collapse = ""),
                                         "\n```"))
        }
    }

    htmlrows <- lapply(seq_along(args), function(i) {
        tags$tr(tags$td(paste(names(args)[i], "=")),
                tags$td(args[[i]]))
    })

    tagList(fun,
            br(),
            do.call(tags$table,
                    c(list(class = "info-table left", width = "100%"),
                      htmlrows)))
}
