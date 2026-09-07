#######################################################################
# nuggets: An R framework for exploration of patterns in data
# Copyright (C) 2026 Michal Burda
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


#' @title Search for itemsets
#'
#' @description
#' `r lifecycle::badge("experimental")`
#'
#' `dig_itemsets()` searches for itemsets (sets of predicates) in `x`.
#' The support of an itemset is the relative frequency of rows satisfying all
#' predicates in the set.
#'
#' @param x a matrix or data frame with data to search in. The matrix must be
#'      numeric (double) or logical. If `x` is a data frame then each column
#'      must be either numeric (double) or logical.
#' @param items a tidyselect expression (see
#'      [tidyselect syntax](https://tidyselect.r-lib.org/articles/syntax.html))
#'      specifying the columns to use as item candidates.
#' @param disjoint an atomic vector of size equal to the number of columns of `x`
#'      that specifies the groups of predicates: if some elements of the `disjoint`
#'      vector are equal, then the corresponding columns of `x` will NOT be
#'      present together in a single condition. If `x` is prepared with
#'      [partition()], using the [var_names()] function on `x`'s column names
#'      is a convenient way to create the `disjoint` vector.
#' @param excluded `NULL` or a list of character vectors, each representing a
#'      known implication (axiom). In each vector, all but the last element
#'      form the antecedent and the last element is the consequent.
#' @param min_length the minimum length, i.e., the minimum number of predicates
#'      in an itemset. Value must be greater or equal to 0.
#' @param max_length The maximum length, i.e., the maximum number of predicates
#'      in an itemset. If equal to Inf, the maximum length is limited only by the
#'      number of available predicates.
#' @param min_support the minimum support of an itemset in the dataset `x`.
#' @param t_norm a t-norm used to compute conjunction of weights. It must be one of
#'      `"goedel"` (minimum t-norm), `"goguen"` (product t-norm), or `"lukas"`
#'      (Łukasiewicz t-norm).
#' @param max_results the maximum number of generated itemsets. If the number of
#'      found itemsets exceeds `max_results`, only the first `max_results`
#'      itemsets are returned.
#' @param verbose a logical value indicating whether to print progress messages.
#' @param error_context a named list providing context for error messages.
#' @return An S3 object, which is an instance of `itemsets` and `nugget`
#'     classes, and which is a tibble with found itemsets and basic quality
#'     measures.
#' @seealso [partition()], [var_names()], [dig()]
#' @examples
#' d <- partition(mtcars, .breaks = 2)
#' dig_itemsets(d, items = everything(), min_support = 0.3)
#' @export
dig_itemsets <- function(x,
                         items = everything(),
                         disjoint = var_names(colnames(x)),
                         excluded = NULL,
                         min_length = 0L,
                         max_length = Inf,
                         min_support = 0,
                         t_norm = "goguen",
                         max_results = Inf,
                         verbose = FALSE,
                         error_context = list(arg_x = "x",
                                              arg_items = "items",
                                              arg_disjoint = "disjoint",
                                              arg_excluded = "excluded",
                                              arg_min_length = "min_length",
                                              arg_max_length = "max_length",
                                              arg_min_support = "min_support",
                                              arg_t_norm = "t_norm",
                                              arg_max_results = "max_results",
                                              arg_verbose = "verbose",
                                              arg_threads = "threads",
                                              call = current_env())) {
    .must_be_double_scalar(min_support,
                           arg = error_context$arg_min_support,
                           call = error_context$call)
    .must_be_in_range(min_support, c(0, 1),
                      arg = error_context$arg_min_support,
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

    items <- enquo(items)

    res <- .dig(x = x,
                internal_function = dig_itemsets_,
                xname = deparse(substitute(x)),
                call_function = "dig_itemsets",
                callback = NULL,
                callback_arguments = "",
                condition = !!items,
                focus = c(),
                disjoint = disjoint,
                excluded = excluded,
                min_length = min_length,
                max_length = max_length,
                min_support = min_support,
                min_focus_support = 0,
                min_conditional_focus_support = 0,
                max_support = 1.0,
                filter_empty_foci = FALSE,
                t_norm = t_norm,
                max_results = max_results,
                verbose = verbose,
                threads = 1L,
                error_context = list(arg_x = error_context$arg_x,
                                     arg_condition = error_context$arg_items,
                                     arg_focus = "",
                                     arg_disjoint = error_context$arg_disjoint,
                                     arg_excluded = error_context$arg_excluded,
                                     arg_min_length = error_context$arg_min_length,
                                     arg_max_length = error_context$arg_max_length,
                                     arg_min_support = error_context$arg_min_support,
                                     arg_min_focus_support = "",
                                     arg_min_conditional_focus_support = "",
                                     arg_max_support = "",
                                     arg_filter_empty_foci = "",
                                     arg_t_norm = error_context$arg_t_norm,
                                     arg_max_results = error_context$arg_max_results,
                                     arg_verbose = error_context$arg_verbose,
                                     arg_threads = "",
                                     call = error_context$call))

    digattr <- attributes(res)
    res <- as_tibble(res)

    if (nrow(res) > 0) {
        if (is.finite(max_results) && nrow(res) > max_results) {
            res <- res[seq_len(max_results), , drop = FALSE]
        }
    }

    nugget(res,
           flavour = "itemsets",
           call_function = "dig_itemsets",
           call_data = list(nrow = nrow(x),
                            ncol = ncol(x),
                            colnames = as.character(colnames(x))),
           call_args = list(x = deparse(substitute(x)),
                            items = digattr$call_args$condition,
                            disjoint = disjoint,
                            excluded = excluded,
                            min_length = min_length,
                            max_length = max_length,
                            min_support = min_support,
                            t_norm = t_norm,
                            max_results = max_results,
                            verbose = verbose))
}
