#' Search for association rules
#'
#' @description
#' `r lifecycle::badge("deprecated")`
#'
#' Association rules identify conditions (*antecedents*) under which
#' a specific feature (*consequent*) is present very often.
#'
#' \describe{
#'   \item{Scheme:}{`A => C`\cr\cr
#'     If condition `A` is satisfied, then the feature `C` is present very often.}
#'   \item{Example:}{`university_edu & middle_age & IT_industry => high_income`\cr\cr
#'     People in *middle age* with *university education* working in IT industry
#'     have very likely a *high income*.}
#' }
#'
#' Antecedent `A` is usually a set of predicates, and consequent `C` is a single
#' predicate.
#'
#' For the following explanations we need a mathematical function \eqn{supp(I)}, which
#' is defined for a set \eqn{I} of predicates as a relative frequency of rows satisfying
#' all predicates from \eqn{I}. For logical data, \eqn{supp(I)} equals to the relative
#' frequency of rows, for which all predicates \eqn{i_1, i_2, \ldots, i_n} from \eqn{I} are TRUE.
#' For numerical (double) input, \eqn{supp(I)} is computed as the mean (over all rows)
#' of truth degrees of the formula `i_1 AND i_2 AND ... AND i_n`, where
#' `AND` is a triangular norm selected by the `t_norm` argument.
#'
#' Association rules are characterized with the following quality measures.
#'
#' *Length* of a rule is the number of elements in the antecedent.
#'
#' *Coverage* of a rule is equal to \eqn{supp(A)}.
#'
#' *Consequent support* of a rule is equal to \eqn{supp(\{c\})}.
#'
#' *Support* of a rule is equal to \eqn{supp(A \cup \{c\})}.
#'
#' *Confidence* of a rule is the fraction \eqn{supp(A) / supp(A \cup \{c\})}.
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
#'      present together in a single condition. If `x` is prepared with
#'      [partition()], using the [var_names()] function on `x`'s column names
#'      is a convenient way to create the `disjoint` vector.
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
#' @param contingency_table a logical value indicating whether to provide a contingency
#'      table for each rule. If `TRUE`, the columns `pp`, `pn`, `np`, and `nn` are
#'      added to the output table. These columns contain the number of rows satisfying
#'      the antecedent and the consequent, the antecedent but not the consequent,
#'      the consequent but not the antecedent, and neither the antecedent nor the
#'      consequent, respectively.
#' @param measures a character vector specifying the additional quality measures to compute.
#'      If `NULL`, no additional measures are computed. Possible values are `"lift"`,
#'      `"conviction"`, `"added_value"`.
#'      See [https://mhahsler.github.io/arules/docs/measures](https://mhahsler.github.io/arules/docs/measures)
#'      for a description of the measures.
#' @param t_norm a t-norm used to compute conjunction of weights. It must be one of
#'      `"goedel"` (minimum t-norm), `"goguen"` (product t-norm), or `"lukas"`
#'      (Lukasiewicz t-norm).
#' @param threads the number of threads to use for parallel computation.
#' @param ... Further arguments, currently unused.
#' @returns A tibble with found patterns and computed quality measures.
#' @author Michal Burda
#' @seealso [partition()], [var_names()], [dig()]
#' @examples
#' d <- partition(mtcars, .breaks = 2)
#' dig_associations(d,
#'                  antecedent = !starts_with("mpg"),
#'                  consequent = starts_with("mpg"),
#'                  min_support = 0.3,
#'                  min_confidence = 0.8,
#'                  measures = c("lift", "conviction"))
#' @keywords internal
#' @export
dig_implications <- function(x,
                             antecedent = everything(),
                             consequent = everything(),
                             disjoint = var_names(colnames(x)),
                             min_length = 0L,
                             max_length = Inf,
                             min_coverage = 0,
                             min_support = 0,
                             min_confidence = 0,
                             contingency_table = FALSE,
                             measures = NULL,
                             t_norm = "goguen",
                             threads = 1,
                             ...) {
    lifecycle::deprecate_stop("1.4.0", "dig_implications()", with = "dig_associations()")
}
