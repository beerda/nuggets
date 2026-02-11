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


#' @param d A data frame with exactly one row and columns named `pp`,
#'     `pn`, `np`, and `nn`, representing the counts of true positives, false
#'     positives, false negatives, and true negatives, respectively. All values must
#'     be greater or equal to zero.
#' @param ... Additional arguments passed to `plot_contingency.default()`.
#' @rdname plot_contingency
#' @method plot_contingency data.frame
#' @export
plot_contingency.data.frame <- function(d, ...) {
    .must_be_named_data_frame(d)

    if (nrow(d) != 1L) {
        cli_abort(c("The data frame must have exactly one row.",
                    "x" = "You've supplied a data frame with {nrow(d)} rows."),
                  call = caller_env())
    }

    req_cols <- c("pp", "pn", "np", "nn")
    if (!all(req_cols %in% names(d))) {
        missing_cols <- setdiff(req_cols, names(d))
        cli_abort(c("The data frame must have columns named {.field pp}, {.field pn}, {.field np}, and {.field nn}.",
                    "x" = "The following required columns are missing: {.field {missing_cols}}."),
                  call = caller_env())
    }

    with(d, plot_contingency.default(pp, pn, np, nn, ...))
}
