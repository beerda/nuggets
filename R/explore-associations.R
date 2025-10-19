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
#' @export
explore.associations <- function(x, data = NULL, ...) {
    .must_be_nugget(x, "associations")
    .must_be_data_frame(data, null = TRUE)

    meta <- tribble(
        ~data_name,          ~short_name,  ~long_name,           ~type,       ~round, ~scatter, ~clustering_default,
        "antecedent",        "antecedent", "Antecedent",         "condition", NA,     FALSE,    0,
        "consequent",        "consequent", "Consequent",         "condition", NA,     FALSE,    0,
        "coverage",          "asupp",      "Antecedent Support", "numeric",   2,      FALSE,    0,
        "conseq_support",    "csupp",      "Consequent Support", "numeric",   2,      FALSE,    0,
        "support",           "supp",       "Rule Support",       "numeric",   2,      TRUE,     0,
        "confidence",        "conf",       "Confidence",         "numeric",   2,      TRUE,     9,
        "lift",              "lift",       "Lift",               "numeric",   2,      TRUE,     10,
        "conviction",        "conv",       "Conviction",         "numeric",   2,      TRUE,     0,
        "antecedent_length", "len",        "Antecedent Length",  "integer",   NA,     TRUE,     0
    )

    x$id <- seq_len(nrow(x))
    meta <- meta[meta$data_name %in% colnames(x), , drop = FALSE]

    detailWindow <- NULL
    clusterWindow <- NULL
    extensions <- list()
    if (is.null(data)) {
        extensions[["navbarPage.header"]] <- infoBox(
            status = "warning",
            dismissible = TRUE,
            div("You started the explorer with rules only.",
                "Some advanced features are disabled.",
                "To enable full functionality, run",
                span(class = "mono", "explore(rules, data)"),
                "with the original dataset used to mine the rules."))

    } else {
        detailWindow <- associationsDetailModule(
            id = "details", rules = x, meta = meta, data = data)

        extensions[["navbarPage.Metadata.before"]] <- tabPanel(
            "Rule Detail",
            value = "rule-detail-tab",
            icon = icon("magnifying-glass"),
            detailWindow$ui())

        extensions[["filteredRulesPanel.rulesTable.action"]] <- list(
            title = "show detailed analysis of the rule",
            icon = "magnifying-glass")
    }

    if (nrow(x) > 2) {
        clusterWindow <- associationsClusterModule(
            id = "clusters", rules = x, meta = meta, data = data)

        extensions[["filteredRulesPanel"]] <- function(...) {
            return(
                tabsetPanel(
                    tabPanel("Table", ...),
                    tabPanel("Clusters", clusterWindow$ui())
                )
            )
        }
    }

    extensions[["server"]] <- function(input,
                                       output,
                                       session,
                                       rulesFiltering,
                                       ruleSelection) {
        observeEvent(ruleSelection(), {
            if (is.null(ruleSelection())) {
                hide(selector = '#nav a[data-value="rule-detail-tab"]')
            } else {
                show(selector = '#nav a[data-value="rule-detail-tab"]')
                updateTabsetPanel(session, "nav", selected = "rule-detail-tab")
            }
        }, ignoreNULL = FALSE)

        if (!is.null(detailWindow))
            detailWindow$server(ruleSelection)

        if (!is.null(clusterWindow))
            clusterWindow$server(rulesFiltering)
    }


    exploreApp(x,
               title = "Associations",
               meta = meta,
               extensions = extensions)
}
