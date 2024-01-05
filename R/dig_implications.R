#' Search for implicative rules
#'
#' Implicative rule is a rule of the form $A \Rightarrow c$, where $A$
#' (*antecedent*) is a set of predicates and $c$ (*consequent*) is a predicate.
#'
#' For the following explanations we need a mathematical function $supp(I)$, which
#' is defined for a set $I$ of predicates as a relative frequency of rows satisfying
#' all predicates from $I$. For logical data, $supp(I)$ equals to the relative
#' frequency of rows, for which all predicates $i_1$, $i_2$, ..., $i_n$ from $I$ are TRUE.
#' For numerical (double) input, $supp(I)$ is computed as the mean (over all rows)
#' of truth degrees of the formula `i_1 AND i_2 AND ... AND i_n`, where
#' $AND$ is a triangular norm selected by the `t_norm` argument.
#'
#' Implicative rules are characterized with the following quality measures.
#'
#' *Length* of a rule is the number of elements in the antecedent.
#'
#' *Coverage* of a rule is equal to $supp(A)$.
#'
#' *Support* of a rule is equal to $supp(A \cup \{c\})$.
#'
#' *Confidence* of a rule is the fraction $supp(A) / supp(A \cup \{c\})$.
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
#' @param min_length the minimum length, i.e., the minimum number of predicates in the
#'      antecedent, of a rule to be generated. Value must be greater or equal to 0.
#'       If 0, rules with empty antecedent are generated in the first place.
#' @param max_length The maximum length, i.e., the maximum number of predicates in the
#'      antecedent, of a rule to be generated. If equal to Inf, the maximum length
#'      is limited only by the number of available predicates.
#' @param min_coverage the minimum coverage of a rule in the dataset `x`.
#'      (See Description for the definition of *coverage*.)
#' @param min_support the minimum support of a rule in the dataset `x`.
#'      (See Description for the definition of *support*.)
#' @param min_confidence the minimum confidence of a rule in the dataset `x`.
#'      (See Description for the definition of *confidence*.)
#' @param t_norm a t-norm used to compute conjunction of weights. It must be one of
#'      `"goedel"` (minimum t-norm), `"goguen"` (product t-norm), or `"lukas"`
#'      (Lukasiewicz t-norm).
#' @param ... Further arguments, currently unused.
#' @returns A tibble with found rules and computed quality measures.
#' @author Michal Burda
#' @seealso [dig()]
#' @export
dig_implications <- function(x,
                             antecedent = everything(),
                             consequent = everything(),
                             disjoint = NULL,
                             min_length = 0L,
                             max_length = Inf,
                             min_coverage = 0,
                             min_support = 0,
                             min_confidence = 0,
                             t_norm = "goguen",
                             ...) {
    .must_be_double_scalar(min_coverage)
    .must_be_in_range(min_coverage, c(0, 1))

    .must_be_double_scalar(min_support)
    .must_be_in_range(min_support, c(0, 1))

    .must_be_double_scalar(min_confidence)
    .must_be_in_range(min_confidence, c(0, 1))

    min_coverage = max(min_coverage, min_support)

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

    f2 <- function(condition, sum, support, foci_supports) {
        conf <- foci_supports / support

        selSupp <-!is.na(foci_supports) & foci_supports >= min_support
        selConf <- !is.na(conf) & conf >= min_confidence
        sel <- selSupp & selConf

        selnames <- names(foci_supports)[sel]
        conf <- conf[sel]
        supp <- foci_supports[sel]
        lift <- supp / (support * conseq_supports[selnames])
        ante <- format_condition(names(condition))
        cons <- lapply(names(conf), format_condition)

        lapply(seq_along(conf), function(i) {
          list(antecedent = ante,
               consequent = cons[[i]],
               support = supp[[i]],
               confidence = conf[[i]],
               coverage = support,
               lift = lift[[i]],
               count = sum)
        })
    }

    res <- dig(x = x,
               f = f2,
               condition = !!antecedent,
               focus = !!consequent,
               disjoint = disjoint,
               min_length = min_length,
               max_length = max_length,
               min_support = min_coverage,
               t_norm = t_norm,
               ...)

    res <- unlist(res, recursive = FALSE)
    res <- lapply(res, as.data.frame)
    res <- do.call(rbind, res)

    as_tibble(res)
}
