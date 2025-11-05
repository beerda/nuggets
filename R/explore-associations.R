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


#' Show interactive application to explore association rules
#'
#' @description
#' `r lifecycle::badge("experimental")`
#'
#' Launches an interactive Shiny application for visual exploration of mined
#' association rules. The explorer provides tools for inspecting rule quality,
#' comparing interestingness measures, and interactively filtering subsets of
#' rules. When the original dataset is supplied, the application also allows
#' for contextual exploration of rules with respect to the underlying data.
#'
#' @param x An object of S3 class `associations`, typically created with
#'   [dig_associations()].
#' @param data An optional data frame containing the dataset from which the
#'   rules were mined. Providing this enables additional contextual features in
#'   the explorer, such as examining supporting records.
#' @param ... Currently ignored.
#'
#' @return An object of class `shiny.appobj` representing the Shiny application.
#'   When "printed" in an interactive R session, the application is launched
#'   immediately in the default web browser.
#'
#' @seealso [dig_associations()]
#' @author Michal Burda
#'
#' @examples
#' \dontrun{
#' data("iris")
#' # convert all columns into dummy logical variables
#' part <- partition(iris, .breaks = 3)
#'
#' # find association rules
#' rules <- dig_associations(part)
#'
#' # launch the interactive explorer
#' explore(rules, data = part)
#' }
#' @rdname explore
#' @method explore associations
#' @export
explore.associations <- function(x, data = NULL, ...) {
    .must_be_nugget(x, "associations")
    .must_be_data_frame(data, null = TRUE)

    # Check for required Shiny-related packages
    required_packages <- c("shiny", "shinyjs", "shinyWidgets", "DT", "htmltools", "htmlwidgets", "jsonlite")
    missing_packages <- required_packages[!sapply(required_packages, requireNamespace, quietly = TRUE)]
    
    if (length(missing_packages) > 0) {
        cli_abort(c(
            "Required packages are not installed.",
            "i" = paste("Please install the following packages:", paste(missing_packages, collapse = ", ")),
            "i" = paste0("You can install them with: install.packages(c(", paste(shQuote(missing_packages, type = "cmd"), collapse = ", "), "))")
        ))
    }

    initial_meta <- tribble(
        ~data_name,          ~long_name,                          ~type,       ~group,              ~round, ~scatter, ~clustering_default,
        "antecedent",        "Antecedent",                        "condition", "formula",           NA,     FALSE,    0,
        "consequent",        "Consequent",                        "condition", "formula",           NA,     FALSE,    0,
        "coverage",          "Coverage (Antecedent Support)",     "numeric",   "basic measures",    2,      FALSE,    0,
        "conseq_support",    "Consequent Support",                "numeric",   "basic measures",    2,      FALSE,    0,
        "support",           "Support",                           "numeric",   "basic measures",    2,      TRUE,     0,
        "confidence",        "Confidence",                        "numeric",   "basic measures",    2,      TRUE,     9,
        "lift",              "Lift",                              "numeric",   "basic measures",    2,      TRUE,     10,
        "antecedent_length", "Antecedent Length",                 "integer",   "basic measures",    NA,     TRUE,     0,
        "pp",                "Antecedent \u2227 Consequent",           "numeric",   "contingency table", 2,      FALSE,    0,
        "pn",                "Antecedent \u2227 \u00acConsequent",      "numeric",   "contingency table", 2,      FALSE,    0,
        "np",                "\u00acAntecedent \u2227 Consequent",      "numeric",   "contingency table", 2,      FALSE,    0,
        "nn",                "\u00acAntecedent \u2227 \u00acConsequent", "numeric",   "contingency table", 2,      FALSE,    0
    )

    supported_measures <- names(.get_supported_association_measures())
    measures_meta <- tibble(data_name = supported_measures,
                            long_name = .get_supported_association_measure_names()[supported_measures],
                            group = "additional measures",
                            type = "numeric",
                            round = 2,
                            scatter = TRUE,
                            clustering_default = 0)
   measures_meta$group[measures_meta$data_name %in% names(.guha_association_measures)] <- "GUHA"

    x$id <- seq_len(nrow(x))
    meta <- bind_rows(initial_meta, measures_meta)
    meta <- meta[meta$data_name %in% colnames(x), , drop = FALSE]

    detailWindow <- NULL
    clusterWindow <- NULL
    extensions <- list()

    if (nrow(x) > 2) {
        clusterWindow <- associationsClusterModule(
            id = "clustering", rules = x, meta = meta, data = data)
        extensions[["navbarPage.enableSidebar.for"]] <- "clustering"
        extensions[["navbarPage.Metadata.before1"]] <- shiny::tabPanel(
            "Clustering",
            icon = shiny::icon("circle-nodes"),
            value = "clustering",
            clusterWindow$ui())
    }

    if (is.null(data)) {
        extensions[["Rules.top"]] <- infoBox(
            status = "warning",
            dismissible = TRUE,
            htmltools::div("You started the explorer with rules only.",
                "Some advanced features are disabled.",
                "To enable full functionality, run",
                htmltools::span(class = "mono", "explore(rules, data)"),
                "with the original dataset used to mine the rules."))

    } else {
        detailWindow <- associationsDetailModule(
            id = "details", rules = x, meta = meta, data = data)

        extensions[["navbarPage.Metadata.before3"]] <- shiny::tabPanel(
            "Rule Detail",
            value = "rule-detail-tab",
            icon = shiny::icon("magnifying-glass"),
            detailWindow$ui())

        extensions[["filteredRulesPanel.rulesTable.action"]] <- list(
            title = "show detailed analysis of the rule",
            icon = "magnifying-glass")
    }

    extensions[["server"]] <- function(input,
                                       output,
                                       session,
                                       rulesFiltering,
                                       rulesProjection,
                                       ruleSelection,
                                       ...) {
        shiny::observeEvent(ruleSelection(), {
            if (is.null(ruleSelection())) {
                shinyjs::hide(selector = '#nav a[data-value="rule-detail-tab"]')
            } else {
                shinyjs::show(selector = '#nav a[data-value="rule-detail-tab"]')
                shiny::updateTabsetPanel(session, "nav", selected = "rule-detail-tab")
            }
        }, ignoreNULL = FALSE)

        if (!is.null(detailWindow))
            detailWindow$server(ruleSelection)

        if (!is.null(clusterWindow))
            clusterWindow$server(rulesProjection, rulesFiltering)
    }


    exploreApp(x,
               title = "Associations",
               meta = meta,
               extensions = extensions)
}
