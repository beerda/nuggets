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


#' @title Find tautologies or "almost tautologies" in a dataset
#'
#' @description
#' This function finds tautologies (data-driven axioms) in a dataset, i.e.,
#' rules of the form `{a1 & a2 & ... & an} => {c}` where `a1`, `a2`, ..., `an`
#' are antecedents and `c` is a consequent that holds with very high confidence.
#' Such rules can serve as axioms for pruning further pattern searches: the
#' resulting list of rules can be passed directly to the `excluded` argument of
#' [dig()], [dig_associations()], or related functions via
#' `parse_condition(result$antecedent, result$consequent)`.
#'
#' The search is performed by iteratively searching for rules with increasing
#' length of the antecedent. Rules found in previous iterations are used as
#' axioms (the `excluded` argument) in the next iteration, so that rules whose
#' consequent can already be deduced from a shorter antecedent are not reported
#' again.
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
#' @param max_length The maximum length, i.e., the maximum number of predicates in the
#'      antecedent, of a rule to be generated. If equal to Inf, the maximum length
#'      is limited only by the number of available predicates.
#' @param min_coverage the minimum coverage of a rule in the dataset `x`.
#'      (See Description for the definition of *coverage*.)
#' @param min_support the minimum support of a rule in the dataset `x`.
#'      (See Description for the definition of *support*.)
#' @param min_confidence the minimum confidence of a rule in the dataset `x`.
#'      (See Description for the definition of *confidence*.)
#' @param contingency_table (Deprecated.)
#'      A logical value indicating whether to provide a contingency
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
#' @returns An S3 object which is an instance of `associations` and `nugget`
#'      classes and which is a tibble with found tautologies in the format equal
#'      to the output of [dig_associations()].
#' @author Michal Burda
#' @examples
#' d <- partition(mtcars, .breaks = 2)
#' dig_tautologies(d,
#'                 antecedent = everything(),
#'                 consequent = everything(),
#'                 max_length = 3,
#'                 min_confidence = 0.99)
#' @export
dig_tautologies <- function(x,
                            antecedent = everything(),
                            consequent = everything(),
                            disjoint = var_names(colnames(x)),
                            max_length = Inf,
                            min_coverage = 0,
                            min_support = 0,
                            min_confidence = 0,
                            contingency_table = deprecated(),
                            t_norm = "goguen",
                            max_results = Inf,
                            verbose = FALSE,
                            threads = 1) {
    .must_be_integerish_scalar(max_length)
    .must_be_greater_eq(max_length, 0)

    .must_be_integerish_scalar(max_results)
    .must_be_greater_eq(max_results, 1)

    antecedent <- enquo(antecedent)
    consequent <- enquo(consequent)
    tautologies <- list()
    result <- NULL
    len <- 0

    if (max_length == Inf) {
        cols <- .convert_data_to_list(x,
                                      error_context = list(arg_x = "x",
                                                           call = current_env()))
        ante_cols <- .extract_cols(cols,
                                        !!antecedent,
                                        allow_numeric = TRUE,
                                        allow_empty = TRUE,
                                        error_context = list(arg_selection = "antecedent",
                                                             call = current_env()))
        max_length <- sum(ante_cols$selected)
    }

    digattr <- NULL
    while (len <= max_length) {
        maxres <- max_results
        if (is.finite(max_results) && !is.null(result)) {
            maxres <- max_results - nrow(result)
        }

        res <- dig_associations(x = x,
                                antecedent = !!antecedent,
                                consequent = !!consequent,
                                disjoint = disjoint,
                                excluded = tautologies,
                                min_length = len,
                                max_length = len,
                                min_coverage = min_coverage,
                                min_support = min_support,
                                min_confidence = min_confidence,
                                contingency_table = contingency_table,
                                t_norm = t_norm,
                                max_results = maxres,
                                verbose = verbose,
                                threads = threads,
                                error_context = list(arg_x = "x",
                                                     arg_antecedent = "antecedent",
                                                     arg_consequent = "consequent",
                                                     arg_disjoint = "disjoint",
                                                     arg_excluded = "internal `tautologies`",
                                                     arg_min_length = "internal `len`",
                                                     arg_max_length = "internal `len`",
                                                     arg_min_coverage = "min_coverage",
                                                     arg_min_support = "min_support",
                                                     arg_min_confidence = "min_confidence",
                                                     arg_contingency_table = "contingency_table",
                                                     arg_t_norm = "t_norm",
                                                     arg_max_results = "internal `maxres`",
                                                     arg_verbose = "verbose",
                                                     arg_threads = "threads",
                                                     call = current_env()))

        if (is.null(digattr)) {
            digattr <- attributes(res)
        }

        if (nrow(res) > 0) {
            result <- rbind(result, res)
            tautologies <- c(tautologies, parse_condition(res$antecedent, res$consequent))
        }
        len <- len + 1
    }

    rownames(result) <- NULL

    nugget(result,
           flavour = "associations",
           call_function = "dig_tautologies",
           call_data = list(nrow = nrow(x),
                            ncol = ncol(x),
                            colnames = as.character(colnames(x))),
           call_args = list(x = deparse(substitute(x)),
                            antecedent = digattr$call_args$antecedent,
                            consequent = digattr$call_args$consequent,
                            disjoint = disjoint,
                            max_length = max_length,
                            min_coverage = min_coverage,
                            min_support = min_support,
                            min_confidence = min_confidence,
                            t_norm = t_norm,
                            max_results = max_results,
                            verbose = verbose,
                            threads = threads))
}
