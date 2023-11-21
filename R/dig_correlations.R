#'
#' @return
#' @author Michal Burda
#' @seealso [dig()]
#' @export
dig_correlations <- function(x,
                             condition = everything(),
                             vars = NULL,
                             xvars = NULL,
                             yvars = NULL,
                             method = c("pearson", "kendall", "spearman"),
                             use = "everything",
                             min_length = 0L,
                             max_length = Inf,
                             min_support = 0.02) {
    if (is.null(vars)) {
        .must_not_be_null(xvars, "vars is not supplied")
        .must_not_be_null(yvars, "vars is not supplied")
    } else {
        .must_be_null(xvars, "vars is supplied")
        .must_be_null(yvars, "vars is supplied")
        xvars <- vars
        yvars <- vars
    }

    match.arg(method)
    .must_be_character_scalar(method)
    .must_be_character_scalar(use)

    condition <- enquo(condition)
    xvars <- enquo(xvars)
    yvars <- enquo(yvars)


}
