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


#' Plot a mosaic plot for a contingency table
#'
#' @param x A data frame with exactly one row and columns named `pp`,
#'     `pn`, `np`, and `nn`, representing the counts of true positives, false
#'     positives, false negatives, and true negatives, respectively. All values must
#'     be greater or equal to zero.
#' @param ... Additional arguments passed to `plot_contingency.default()`.
#' @return A ggplot object representing the mosaic plot of the contingency table.
#' @author Michal Burda
#' @rdname plot_contingency
#' @method plot_contingency data.frame
#' @export
plot_contingency.data.frame <- function(x, ...) {
    .must_be_named_data_frame(x)

    if (nrow(x) != 1L) {
        cli_abort(c("The data frame must have exactly one row.",
                    "x" = "You've supplied a data frame with {nrow(x)} rows."),
                  call = caller_env())
    }

    req_cols <- c("pp", "pn", "np", "nn")
    if (!all(req_cols %in% names(x))) {
        missing_cols <- setdiff(req_cols, names(x))
        cli_abort(c("The data frame must have columns named {.field pp}, {.field pn}, {.field np}, and {.field nn}.",
                    "x" = "The following required columns are missing: {.field {missing_cols}}."),
                  call = caller_env())
    }

    with(x, plot_contingency.default(pp, pn, np, nn, ...))
}
