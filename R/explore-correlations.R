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


#' @title Show interactive application to explore conditional correlations
#'
#' @description
#' `r lifecycle::badge("experimental")`
#'
#' Launches an interactive Shiny application for visual exploration of
#' conditional correlation patterns. The explorer provides tools for inspecting
#' pattern quality, comparing measures, and interactively filtering subsets
#' of patterns. When the original dataset is supplied, the application also
#' allows for contextual exploration of correlations with respect to the
#' underlying data.
#'
#' @param x An object of S3 class `correlations`, typically created with
#'   [dig_correlations()].
#' @param data An optional data frame containing the dataset from which the
#'   correlations were computed. Providing this enables additional contextual
#'   features in the explorer, such as examining supporting records.
#' @param ... Currently ignored.
#'
#' @return An object of class `shiny.appobj` representing the Shiny application.
#'   When "printed" in an interactive R session, the application is launched
#'   immediately in the default web browser.
#'
#' @seealso [dig_correlations()]
#' @author Michal Burda
#'
#' @examples
#' \dontrun{
#' d <- partition(iris, Species)
#' res <- dig_correlations(d,
#'                         condition = where(is.logical),
#'                         xvars = Sepal.Length:Petal.Width,
#'                         yvars = Sepal.Length:Petal.Width)
#'
#' # launch the interactive explorer
#' explore(res, data = d)
#' }
#' @method explore correlations
#' @export
explore.correlations <- function(x, data = NULL, ...) {
    .require_shiny()
    .must_be_nugget(x, "correlations")
    .must_be_data_frame(data, null = TRUE)

    if (!is.null(data)) {
        predicates <- parse_condition(x$condition)
        predicates <- unlist(predicates)
        predicates <- unique(predicates)
        vars <- unique(c(x$xvar, x$yvar))
        .must_have_columns(data, c(predicates, vars), arg_x = "data")
    }

    initial_meta <- tribble(
        ~data_name,     ~long_name,                ~type,       ~group,           ~round, ~scatter,
        "condition",    "Condition",               "condition", "formula",        NA,     FALSE,
        "xvar",         "X Variable",              "variable",  "formula",        NA,     FALSE,
        "yvar",         "Y Variable",              "variable",  "formula",        NA,     FALSE,
        "estimate",     "Estimate",                "numeric",   "test",            4,      TRUE,
        "p_value",      "P-value",                 "numeric",   "test",            6,      TRUE,
        "method",       "Method",                  "character", "test",           NA,     FALSE,
        "alternative",  "Alternative",             "character", "test",           NA,     FALSE,
        "support",      "Support",                 "numeric",   "basic measures",  2,      TRUE,
        "condition_length", "Condition Length",    "integer",   "basic measures", NA,      TRUE,
        "n",            "N",                       "integer",   "basic measures", NA,      TRUE,
    )

    x$id <- seq_len(nrow(x))
    meta <- initial_meta[initial_meta$data_name %in% colnames(x), , drop = FALSE]

    extensions <- list()

#    if (is.null(data)) {
#        extensions[["Rules.top"]] <- infoBox(
#            status = "warning",
#            dismissible = TRUE,
#            htmltools::div("You started the explorer with results only.",
#                "Some advanced features are disabled.",
#                "To enable full functionality, run",
#                htmltools::span(class = "mono", "explore(results, data)"),
#                "with the original dataset used to compute the correlations."))
#    }

    exploreApp(x,
               title = "Correlations",
               meta = meta,
               extensions = extensions)
}
