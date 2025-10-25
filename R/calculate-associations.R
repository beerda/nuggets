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


#' Calculate additional interest measures for association rules
#'
#' This function calculates various additional interest measures for
#' association rules based on their contingency table counts.
#'
#' The input nugget object must contain the columns
#' `pp` (positive antecedent & positive consequent),
#' `pn` (positive antecedent & negative consequent),
#' `np` (negative antecedent & positive consequent), and
#' `nn` (negative antecedent & negative consequent), representing the counts
#' from the contingency table. These columns are typically produced by
#' [dig_associations()] when the `contingency_table` argument is set to `TRUE`.
#'
#' The supported interest measures that can be calculated include:
#' `r .create_arules_measures_doc()`
#'
#' @param x A nugget of flavour `associations`, typically created with
#'    [dig_associations()] with argument `contingency_table = TRUE`.
#' @param measure A character vector specifying which interest measures to
#'    calculate. See the Details section for the list of supported measures.
#' @param ... Currently unused.
#' @return An S3 object which is an instance of `associations` and `nugget`
#'    classes and which is a tibble containing all the columns of the input
#'    nugget `x`, plus additional columns for each of the requested interest
#'    measures.
#' @author Michal Burda
#' @seealso [dig_associations()]
#' @examples
#' d <- partition(mtcars, .breaks = 2)
#' rules <- dig_associations(d,
#'                           antecedent = !starts_with("mpg"),
#'                           consequent = starts_with("mpg"),
#'                           min_support = 0.3,
#'                           min_confidence = 0.8,
#'                           contingency_table = TRUE)
#' rules <- calculate(rules,
#'                    measure = c("conviction", "leverage", "jaccard"))
#' @export
calculate.associations <- function(x,
                                   measure,
                                   ...) {
    .must_be_nugget(x, "associations")
    .must_have_numeric_column(x,
                              "pp",
                              arg_x = "x",
                              call = current_env())
    .must_have_numeric_column(x,
                              "pn",
                              arg_x = "x",
                              call = current_env())
    .must_have_numeric_column(x,
                              "np",
                              arg_x = "x",
                              call = current_env())
    .must_have_numeric_column(x,
                              "nn",
                              arg_x = "x",
                              call = current_env())

    supported_measures <- names(.arules_association_measures)
    .must_be_enum(measure,
                  supported_measures,
                  null = FALSE,
                  multi = TRUE,
                  arg = "measure",
                  call = current_env())

    if (any(c(x$pp, x$pn, x$np, x$nn) < 0)) {
        cli_abort(c("{.arg x} contains negative counts in columns {.var pp}, {.var pn}, {.var np}, or {.var nn}.",
                    "x" = "All counts must be non-negative."),
                  call = current_env())
    }

    if (any(measure %in% colnames(x))) {
        cli_warn(c("Some of the selected measures are already present in {.arg x} and will be overwritten.",
                   "i" = "Measures: {.var {intersect(measure, colnames(x))}}."),
                 call = current_env())
    }

    n1x <- x$pp + x$pn
    n0x <- x$np + x$nn
    nx1 <- x$pp + x$np
    nx0 <- x$pn + x$nn
    n <- n1x + n0x

    counts <- list(
        n11 = x$pp, n10 = x$pn, n01 = x$np, n00 = x$nn,
        n1x = n1x, n0x = n0x, nx1 = nx1, nx0 = nx0,
        n = n
    )

    res <- lapply(measure, function(m) {
        func <- .arules_association_measures[[m]]
        func(counts)
    })
    names(res) <- measure

    bind_cols(x, res)
}


.create_arules_measures_doc <- function() {
    url_base <- "https://mhahsler.github.io/arules/docs/measures#"
    measures <- names(.arules_association_measures)
    measures <- sort(measures)
    section_names <- gsub("_", "", measures, fixed = TRUE)

    paste0("- `", measures, "` - see [", url_base, section_names, "](", url_base, section_names, ") for details",
           collapse = "\n")
}
