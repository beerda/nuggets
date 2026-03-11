#######################################################################
# nuggets: An R framework for exploration of patterns in data
# Copyright (C) 2025 Michal Burda
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program. If not, see <https://www.gnu.org/licenses/>.
#######################################################################


#' @title Search for association rules
#'
#' @description
#' `r lifecycle::badge("experimental")`
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
#' *Lift* of a rule is the ratio of its support to the expected support
#' assuming antecedent and consequent are independent, i.e.,
#' \eqn{supp(A \cup \{c\}) / (supp(A) * supp(\{c\}))}.
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
#' @param excluded NULL or a list of character vectors, where each character vector
#'      contains the names of columns that must not appear together in a single
#'      antecedent.
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
#' @param contingency_table (Deprecated. Contingency table is always added to the
#'      result.) A logical value indicating whether to provide a contingency
#'      table for each rule. If `TRUE`, the columns `pp`, `pn`, `np`, and `nn` are
#'      added to the output table. These columns contain the number of rows satisfying
#'      the antecedent and the consequent, the antecedent but not the consequent,
#'      the consequent but not the antecedent, and neither the antecedent nor the
#'      consequent, respectively.
#' @param t_norm a t-norm used to compute conjunction of weights. It must be one of
#'      `"goedel"` (minimum t-norm), `"goguen"` (product t-norm), or `"lukas"`
#'      (Łukasiewicz t-norm).
#' @param max_results the maximum number of generated conditions to execute the
#'      callback function on. If the number of found conditions exceeds
#'      `max_results`, the function stops generating new conditions and returns
#'      the results. To avoid long computations during the search, it is recommended
#'      to set `max_results` to a reasonable positive value. Setting `max_results`
#'      to `Inf` will generate all possible conditions.
#' @param verbose a logical value indicating whether to print progress messages.
#' @param threads the number of threads to use for parallel computation.
#' @param error_context a named list providing context for error messages.
#'      This is mainly useful when `dig_associations()` is called from another
#'      function and you want error messages to refer to the argument names
#'      of that calling function. The list must contain the following elements:
#'      \itemize{
#'          \item `arg_x` - name of the argument `x`
#'          \item `arg_antecedent` - name of the argument `antecedent`
#'          \item `arg_consequent` - name of the argument `consequent`
#'          \item `arg_disjoint` - name of the argument `disjoint`
#'          \item `arg_excluded` - name of the argument `excluded`
#'          \item `arg_min_length` - name of the argument `min_length`
#'          \item `arg_max_length` - name of the argument `max_length`
#'          \item `arg_min_coverage` - name of the argument `min_coverage`
#'          \item `arg_min_support` - name of the argument `min_support`
#'          \item `arg_min_confidence` - name of the argument `min_confidence`
#'          \item `arg_contingency_table` - name of the argument `contingency_table`
#'          \item `arg_t_norm` - name of the argument `t_norm`
#'          \item `arg_max_results` - name of the argument `max_results`
#'          \item `arg_verbose` - name of the argument `verbose`
#'          \item `arg_threads` - name of the argument `threads`
#'      }
#' @returns An S3 object, which is an instance of `associations` and `nugget`
#'     classes, and which is a tibble with found patterns and computed quality measures.
#' @author Michal Burda
#' @seealso [partition()], [var_names()], [dig()]
#' @examples
#' d <- partition(mtcars, .breaks = 2)
#' dig_associations(d,
#'                  antecedent = !starts_with("mpg"),
#'                  consequent = starts_with("mpg"),
#'                  min_support = 0.3,
#'                  min_confidence = 0.8)
#' @export
dig_associations <- function(x,
                             antecedent = everything(),
                             consequent = everything(),
                             disjoint = var_names(colnames(x)),
                             excluded = NULL,
                             min_length = 0L,
                             max_length = Inf,
                             min_coverage = 0,
                             min_support = 0,
                             min_confidence = 0,
                             contingency_table = deprecated(),
                             t_norm = "goguen",
                             max_results = Inf,
                             verbose = FALSE,
                             threads = 1,
                             error_context = list(arg_x = "x",
                                                  arg_antecedent = "antecedent",
                                                  arg_consequent = "consequent",
                                                  arg_disjoint = "disjoint",
                                                  arg_excluded = "excluded",
                                                  arg_min_length = "min_length",
                                                  arg_max_length = "max_length",
                                                  arg_min_coverage = "min_coverage",
                                                  arg_min_support = "min_support",
                                                  arg_min_confidence = "min_confidence",
                                                  arg_contingency_table = "contingency_table",
                                                  arg_t_norm = "t_norm",
                                                  arg_max_results = "max_results",
                                                  arg_verbose = "verbose",
                                                  arg_threads = "threads",
                                                  call = current_env())) {
    .must_be_double_scalar(min_coverage,
                           arg = error_context$arg_min_coverage,
                           call = error_context$call)
    .must_be_in_range(min_coverage, c(0, 1),
                      arg = error_context$arg_min_coverage,
                      call = error_context$call)

    .must_be_double_scalar(min_support,
                           arg = error_context$arg_min_support,
                           call = error_context$call)
    .must_be_in_range(min_support, c(0, 1),
                      arg = error_context$arg_min_support,
                      call = error_context$call)

    .must_be_double_scalar(min_confidence,
                           arg = error_context$arg_min_confidence,
                           call = error_context$call)
    .must_be_in_range(min_confidence, c(0, 1),
                      arg = error_context$arg_min_confidence,
                      call = error_context$call)

    if (lifecycle::is_present(contingency_table)) {
        deprecate_warn(when = "2.2.0",
                       what = "nuggets::dig_associations(contingency_table)",
                       details = "The `contingency_table` argument is deprecated and will be removed in future versions. dig_associations() works as 'contingency_table = TRUE' would be specified by default.")
    } else {
        contingency_table <- TRUE
    }
    .must_be_flag(contingency_table,
                  arg = error_context$arg_contingency_table,
                  call = error_context$call)

    .must_be_flag(verbose,
                  arg = error_context$arg_verbose,
                  call = error_context$call)

    .must_be_integerish_scalar(max_results,
                               arg = error_context$arg_max_results,
                               call = error_context$call)
    .must_be_greater_eq(max_results, 1,
                        arg = error_context$arg_max_results,
                        call = error_context$call)

    orig_min_coverage <- min_coverage
    min_coverage <- max(min_coverage, min_support)
    n <- nrow(x)

    antecedent <- enquo(antecedent)
    consequent <- enquo(consequent)

    res <- .dig(x = x,
                xname = deparse(substitute(x)),
                call_function = "dig_associations",
                callback = NULL,
                callback_arguments = "",
                condition = !!antecedent,
                focus = !!consequent,
                disjoint = disjoint,
                excluded = excluded,
                min_length = min_length,
                max_length = max_length,
                min_support = min_coverage,
                min_focus_support = min_support,
                min_conditional_focus_support = min_confidence,
                max_support = 1.0,
                filter_empty_foci = TRUE,
                t_norm = t_norm,
                max_results = max_results,
                verbose = verbose,
                threads = threads,
                error_context = list(arg_x = error_context$arg_x,
                                     arg_condition = error_context$arg_antecedent,
                                     arg_focus = error_context$arg_consequent,
                                     arg_disjoint = error_context$arg_disjoint,
                                     arg_excluded = error_context$arg_excluded,
                                     arg_min_length = error_context$arg_min_length,
                                     arg_max_length = error_context$arg_max_length,
                                     arg_min_support = error_context$arg_min_coverage,
                                     arg_min_focus_support = error_context$arg_min_support,
                                     arg_min_conditional_focus_support = error_context$arg_min_confidence,
                                     arg_t_norm = error_context$arg_t_norm,
                                     arg_max_results = error_context$arg_max_results,
                                     arg_verbose = error_context$arg_verbose,
                                     arg_threads = error_context$arg_threads,
                                     call = error_context$call))

    digattr <- attributes(res)
    res <- as_tibble(res)

    if (nrow(res) > 0) {
        if (is.finite(max_results) && nrow(res) > max_results) {
            res <- res[seq_len(max_results), , drop = FALSE]
        }
    }

    nugget(res,
           flavour = "associations",
           call_function = "dig_associations",
           call_data = list(nrow = nrow(x),
                            ncol = ncol(x),
                            colnames = as.character(colnames(x))),
           call_args = list(x = deparse(substitute(x)),
                            antecedent = digattr$call_args$condition,
                            consequent = digattr$call_args$focus,
                            disjoint = disjoint,
                            excluded = excluded,
                            min_length = min_length,
                            max_length = max_length,
                            min_coverage = orig_min_coverage,
                            min_support = min_support,
                            min_confidence = min_confidence,
                            contingency_table = contingency_table,
                            t_norm = t_norm,
                            max_results = max_results,
                            verbose = verbose,
                            threads = threads))
}
