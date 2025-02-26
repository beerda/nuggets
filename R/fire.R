#' Obtain truth-degrees of conditions
#'
#' Given a data frame or a matrix of truth values of predicates, compute
#' truth values of given vector of conditions.
#'
#' Each element of `condition` is a character string of the format `"{p1,p2,p3}"`,
#' where `"p1"`, `"p2"`, and `"p3"` are predicates. Data `x` must contain columns
#' whose names correspond to all predicates used in conditions. Each condition
#' is evaluated on all data rows as an elementary conjunction, where the conjunction
#' operation is specified by the `t_norm` argument. An empty condition, `{}`,
#' is always evaluated as 1.
#'
#' @param x a matrix or data frame. The matrix must be numeric (double) or logical.
#'      If `x` is a data frame then each column must be either numeric (double) or
#'      logical.
#' @param condition a character vector of conditions, each element as formatted
#'      by [format_condition()]. E.g., `"{p1,p2,p3}"` is a condition with three
#'      predicates `"p1"`, `"p2"`, and `"p3"`. All predicates present in the
#'      condition must exist as column names in `x`.
#' @param t_norm a t-norm used to compute conjunction of weights. It must be one of
#'      `"goedel"` (minimum t-norm), `"goguen"` (product t-norm), or `"lukas"`
#'      (Lukasiewicz t-norm).
#' @return A numeric matrix with values from the interval \eqn{[0,1]} indicating
#'      the truth values. The resulting matrix has `nrow(x)` rows and
#'      `length(condition)` columns. That is, a value on *i*-th row and *j*-th
#'      column corresponds to a truth value of *j*-th condition evaluated at
#'      *i*-th data row.
#' @author Michal Burda
#' @export
#' @examples
#' d <- data.frame(a = c(  1, 0.8, 0.5, 0.2,   0),
#'                 b = c(0.5,   1, 0.5,   0,   1),
#'                 c = c(0.9, 0.9, 0.1, 0.8, 0.7))
#' fire(d, c("{a,c}", "{}", "{a,b,c}"))
fire <- function(x,
                 condition,
                 t_norm = "goguen") {

    cols <- .convert_data_to_list(x,
                                  error_context = list(arg_x = "x",
                                                       call = current_env()))

    .must_be_character_vector(condition)
    .must_be_enum(t_norm, c("goguen", "goedel", "lukas"))

    fns <- list(goguen = .pgoguen_tnorm,
                goedel = .pgoedel_tnorm,
                lukas = .plukas_tnorm)
    f <- fns[[t_norm]]

    condition <- parse_condition(condition)
    predicates <- unique(unlist(condition))
    undefined <- setdiff(predicates, colnames(x))
    if (length(undefined) > 0) {
        details <- paste0("Column {.var ", undefined, "} can't be found.")
        cli_abort(c("Can't find some column names in {.arg x} that correspond to all predicates in {.arg condition}.",
                    "i" = "Consider using {.fn remove_ill_conditions()} to remove conditions with undefined predicates.",
                    ..error_details(details)))
    }

    res <- lapply(condition, function(cond) {
        if (length(cond) <= 0) {
            return(rep(1, nrow(x)))
        }

        do.call(f, x[cond])
    })

    res <- do.call(cbind, res)
    if (is.null(res)) {
        res <- matrix(1, ncol = 0, nrow = nrow(x))
    }

    res
}
