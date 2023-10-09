#' Search for implicative rules
#'
#' @param x a matrix or data frame with data to search in. The matrix must be
#'      numeric (double) or logical. If `x` is a data frame then each column
#'      must be either numeric (double) or logical.
#' @param antecedent a tidyselect expression (see
#'      [tidyselect syntax](https://tidyselect.r-lib.org/articles/syntax.html))
#'      specifying the columns to use in the antecedent (left) part of the rules
#' @param consequent a tidyselect expression (see
#'      [tidyselect syntax](https://tidyselect.r-lib.org/articles/syntax.html))
#'      specifying the columns to use in the consequent (right) part of the rules
#' @param disjoint an atomic vector of size equal to the number of columns of `x`
#'      that specifies the groups of predicates: if some elements of the `disjoint`
#'      vector are equal, then the corresponding columns of `x` will NOT be
#'      present together in a single condition.
#' @param min_length the minimum size (the minimum number of predicates) of the
#'      condition to be generated (must be greater or equal to 0). If 0, the empty
#'      condition is generated in the first place.
#' @param max_length The maximum size (the maximum number of predicates) of the
#'      condition to be generated. If equal to Inf, the maximum length of conditions
#'      is limited only by the number of available predicates.
#' @param min_support the minimum support of a condition to trigger the callback
#'      function for it. The support of the condition is the relative frequency
#'      of the condition in the dataset `x`. For logical data, it equals to the
#'      relative frequency of rows such that all condition predicates are TRUE on it.
#'      For numerical (double) input, the support is computed as the mean (over all
#'      rows) of multiplications of predicate values.
#' @param min_confidence the minimum confidence of rules to return. The confidence
#'      of a rule is computed as: supp(antecedent) / supp(antecedent AND consequent).
#' @param ... Further arguments, currently unused.
#' @returns A tibble with found rules.
#' @author Michal Burda
#' @seealso [dig()]
#' @export
dig_implications <- function(x,
                             antecedent = everything(),
                             consequent = everything(),
                             disjoint = NULL,
                             min_length = 0,
                             max_length = Inf,
                             min_support = 0.02,
                             min_confidence = 0.7,
                             ...) {
    .must_be_double_scalar(min_confidence)
    .must_be_in_range(min_confidence, c(0, 1))

    antecedent <- enquo(antecedent)
    consequent <- enquo(consequent)

    f1 <- function(condition, support) {
        res <- support
        names(res) <- colnames(x)[condition]

        res
    }

    conseq_supports <- dig(x = x,
                           f = f1,
                           condition = !!consequent,
                           min_length = 1,
                           max_length = 1,
                           min_support = 0.0)
    conseq_supports <- unlist(conseq_supports)

    f2 <- function(condition, support, foci_supports) {
        ante <- paste(names(condition), collapse = " & ")
        conf <- foci_supports / support
        sel <- !is.na(conf) & conf >= min_confidence
        selnames <- names(foci_supports)[sel]
        conf <- conf[sel]
        supp <- foci_supports[sel]

        lapply(seq_along(conf), function(i) {
          list(antecedent = ante,
               consequent = names(conf)[[i]],
               support = supp[[i]],
               confidence = conf[[i]],
               coverage = support,
               lift = supp[[i]] / (support * conseq_supports[selnames[[i]]]))
        })
    }

    res <- dig(x = x,
               f = f2,
               condition = !!antecedent,
               focus = !!consequent,
               disjoint = disjoint,
               min_length = min_length,
               max_length = max_length,
               min_support = min_support)

    res <- unlist(res, recursive = FALSE)
    res <- lapply(res, as.data.frame)
    res <- do.call(rbind, res)

    as_tibble(res)
}
