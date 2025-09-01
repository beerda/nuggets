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
explore.associations <- function(x, data = NULL, ...) {
    .must_inherit(x, "associations")
    .must_be_data_frame(data, null = TRUE)

    x$id <- seq_len(nrow(x))

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

    detailModule <- associationsDetailModule(id = "details",
                                             rules = x,
                                             meta = meta,
                                             data = data)

    mainApp(x,
            title = "Associations",
            meta = meta,
            detailWindow = detailModule)
}
