#' Show interactive application to explore association rules
#'
#' @param x An object of class `associations`, typically created with
#'     [dig_associations()].
#' @param data An optional data frame containing the original dataset used to
#'     mine the rules. Providing this dataset enables additional features in the
#'     explorer.
#' @param ... Currently ignored.
#' @return An object of class `shiny.appobj` representing the Shiny application.
#'     If printed in an interactive R session, the application will be run
#'     immediately.
#' @author Michal Burda
#' @export
explore.associations <- function(x, data = NULL, ...) {
    .must_inherit(x, "associations")
    .must_be_data_frame(data, null = TRUE)

    x$id <- seq_len(nrow(x))

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
        "antecedent_length", "len",        "Antecedent Length",  "integer",   NA,     FALSE
    )

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
