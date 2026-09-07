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


#' @title Show interactive application to explore itemsets
#'
#' @description
#' `r lifecycle::badge("experimental")`
#'
#' Launches an interactive Shiny application for visual exploration of itemsets.
#' The explorer provides tools for inspecting pattern quality,
#' comparing measures, and interactively filtering subsets of patterns.
#'
#' @param x An object of S3 class `itemsets`, typically created with
#'   [dig_itemsets()].
#' @param data An optional data frame containing the dataset from which the
#'   itemsets were computed. Currently unused.
#' @param ... Currently ignored.
#'
#' @return An object of class `shiny.appobj` representing the Shiny application.
#'   When "printed" in an interactive R session, the application is launched
#'   immediately in the default web browser.
#'
#' @seealso [dig_itemsets()]
#' @author Michal Burda
#'
#' @examples
#' \dontrun{
#' d <- partition(mtcars, .breaks = 2, .keep = TRUE)
#' res <- dig_itemsets(d,
#'                     items = where(is.logical),
#'                     min_support = 0.3,
#'                     max_length = 2)
#'
#' # launch the interactive explorer
#' explore(res)
#' }
#' @method explore itemsets
#' @export
explore.itemsets <- function(x, data = NULL, ...) {
    .require_shiny()
    .must_be_nugget(x, "itemsets")
    .must_be_data_frame(data, null = TRUE)

    if (!is.null(data)) {
        predicates <- parse_condition(x$items)
        predicates <- unlist(predicates)
        predicates <- unique(predicates)
        vars <- unique(x$var)
        .must_have_columns(data, c(predicates, vars), arg_x = "data")
    }

    initial_meta <- tribble(
        ~data_name,     ~long_name,                ~type,       ~group,           ~round, ~scatter,
        "itemset",      "Itemset",                 "condition", "formula",        NA,     FALSE,
        "support",      "Support",                 "numeric",   "basic measures", 2,       TRUE,
        "length",       "Length",                  "integer",   "basic measures", NA,      TRUE,
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
#                "with the original dataset used to compute the contrasts."))
#    }

    exploreApp(x,
               title = "Baseline Contrasts",
               meta = meta,
               extensions = extensions)
}
