#' Show interactive application to explore association rules
#'
#' @param x An object of class `associations`, typically created with
#'     [dig_associations()].
#' @param ... Currently ignored.
#' @return An object of class `shiny.appobj` representing the Shiny application.
#'     If printed in an interactive R session, the application will be run
#'     immediately.
#' @author Michal Burda
#' @export
explore.associations <- function(x, ...) {
    .must_inherit(x, "associations")

    meta <- tribble(
        ~data_name,          ~short_name,  ~long_name,           ~type,       ~round,
        "antecedent",        "antecedent", "Antecedent",         "condition", NA,
        "consequent",        "consequent", "Consequent",         "condition", NA,
        "coverage",          "asupp",      "Antecedent Support", "numeric",   2,
        "conseq_support",    "csupp",      "Consequent Support", "numeric",   2,
        "support",           "supp",       "Rule Support",       "numeric",   2,
        "confidence",        "conf",       "Confidence",         "numeric",   2,
        "lift",              "lift",       "Lift",               "numeric",   2,
        "conviction",        "conv",       "Conviction",         "numeric",   2,
        "antecedent_length", "len",        "Antecedent Length",  "integer",   NA
    )

    mainApp(x,
            title = "Associations",
            meta = meta)
}
