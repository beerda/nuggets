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
        ~data_name,          ~short_name,  ~long_name,           ~type,       ~round, ~scatter,
        "antecedent",        "antecedent", "Antecedent",         "condition", NA,     FALSE,
        "consequent",        "consequent", "Consequent",         "condition", NA,     FALSE,
        "coverage",          "asupp",      "Antecedent Support", "numeric",   2,      FALSE,
        "conseq_support",    "csupp",      "Consequent Support", "numeric",   2,      FALSE,
        "support",           "supp",       "Rule Support",       "numeric",   2,      TRUE,
        "confidence",        "conf",       "Confidence",         "numeric",   2,      TRUE,
        "lift",              "lift",       "Lift",               "numeric",   2,      TRUE,
        "conviction",        "conv",       "Conviction",         "numeric",   2,      TRUE,
        "antecedent_length", "len",        "Antecedent Length",  "integer",   NA,     TRUE
    )

    x$id <- seq_len(nrow(x))
    meta <- meta[meta$data_name %in% colnames(x), , drop = FALSE]

    header <- NULL
    detailModule <- NULL
    if (is.null(data)) {
        header <- infoBox(status = "warning",
                          dismissible = TRUE,
                          div("You started the explorer with rules only.",
                              "Some advanced features are disabled.",
                              "To enable full functionality, run",
                              span(class = "mono",
                                "explore(rules, data)"),
                              "with the original dataset used to mine the rules."))
    } else {
        detailModule <- associationsDetailModule(id = "details",
                                                 rules = x,
                                                 meta = meta,
                                                 data = data)
    }

    mainApp(x,
            title = "Associations",
            meta = meta,
            header = header,
            detailWindow = detailModule)
}
