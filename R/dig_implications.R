#' Search for implicative rules
#'
#' Implicative rule is a rule of the form \eqn{A \Rightarrow c}{A => c},
#' where \eqn{A} (*antecedent*) is a set of predicates and \eqn{c} (*consequent*) is a predicate.
#'
#' For the following explanations we need a mathematical function \eqn{supp(I)}, which
#' is defined for a set \eqn{I} of predicates as a relative frequency of rows satisfying
#' all predicates from \eqn{I}. For logical data, \eqn{supp(I)} equals to the relative
#' frequency of rows, for which all predicates \eqn{i_1, i_2, \ldots, i_n} from \eqn{I} are TRUE.
#' For numerical (double) input, \eqn{supp(I)} is computed as the mean (over all rows)
#' of truth degrees of the formula `i_1 AND i_2 AND ... AND i_n`, where
#' `AND` is a triangular norm selected by the `t_norm` argument.
#'
#' Implicative rules are characterized with the following quality measures.
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
#' @param contingency_table a logical value indicating whether to provide a contingency
#'      table for each rule. If `TRUE`, the columns `pp`, `pn`, `np`, and `nn` are
#'      added to the output table. These columns contain the number of rows satisfying
#'      the antecedent and the consequent, the antecedent but not the consequent,
#'      the consequent but not the antecedent, and neither the antecedent nor the
#'      consequent, respectively.
#' @param measures a character vector specifying the additional quality measures to compute.
#'      If `NULL`, no additional measures are computed. Possible values are `"lift"`,
#'      `"added_value"`.
#'      See [https://mhahsler.github.io/arules/docs/measures](https://mhahsler.github.io/arules/docs/measures)
#'      for a description of the measures.
#' @param t_norm a t-norm used to compute conjunction of weights. It must be one of
#'      `"goedel"` (minimum t-norm), `"goguen"` (product t-norm), or `"lukas"`
#'      (Lukasiewicz t-norm).
#' @param threads the number of threads to use for parallel computation.
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
                             contingency_table = FALSE,
                             measures = NULL,
                             t_norm = "goguen",
                             threads = 1,
                             ...) {
    .must_be_double_scalar(min_coverage)
    .must_be_in_range(min_coverage, c(0, 1))

    .must_be_double_scalar(min_support)
    .must_be_in_range(min_support, c(0, 1))

    .must_be_double_scalar(min_confidence)
    .must_be_in_range(min_confidence, c(0, 1))

    .must_be_flag(contingency_table)
    .must_be_enum(measures,
                  values = c("lift", "added_value"),
                  null = TRUE,
                  multi = TRUE)

    min_coverage <- max(min_coverage, min_support)
    n <- nrow(x)

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
                           min_support = 0.0,
                           threads = threads)
    conseq_supports <- unlist(conseq_supports)

    f2 <- function(condition, support, pp) {
        conf <- pp / support

        sel <-!is.na(pp) & !is.na(conf) & conf >= min_confidence

        selnames <- names(pp)[sel]
        conf <- conf[sel]
        supp <- pp[sel]
        ante <- format_condition(names(condition))
        cons <- unlist(lapply(names(conf), format_condition))

        if (length(conf) <= 0) {
            return(NULL)
        }

        data.frame(antecedent = ante,
                   consequent = cons,
                   support = supp,
                   confidence = conf,
                   coverage = support,
                   conseq_support = conseq_supports[selnames],
                   count = as.integer(round(supp * n)))
    }

    f3 <- function(condition, support, pp, pn, np, nn) {
        res <- f2(condition, support, pp)
        res$pp <- pp
        res$pn <- pn
        res$np <- np
        res$nn <- nn

        res
    }

    f <- ifelse(contingency_table, f3, f2)

    res <- dig(x = x,
               f = f,
               condition = !!antecedent,
               focus = !!consequent,
               disjoint = disjoint,
               min_length = min_length,
               max_length = max_length,
               min_support = min_coverage,
               min_focus_support = min_support,
               filter_empty_foci = TRUE,
               t_norm = t_norm,
               threads = threads,
               ...)

    res <- do.call(rbind, res)

    if ("lift" %in% measures) {
        res$lift <- res$support / (res$coverage * res$conseq_support)
    }
    if ("added_value" %in% measures) {
        res$added_value <- res$confidence - res$conseq_support
    }

    as_tibble(res)
}
