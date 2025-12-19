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


#' @title Add additional interest measures for association rules
#'
#' @description
#' `r lifecycle::badge("experimental")`
#'
#' This function calculates various additional interest measures for
#' association rules based on their contingency table counts.
#'
#' @details
#' The input nugget object must contain the columns
#' `pp` (positive antecedent & positive consequent),
#' `pn` (positive antecedent & negative consequent),
#' `np` (negative antecedent & positive consequent), and
#' `nn` (negative antecedent & negative consequent), representing the counts
#' from the contingency table. These columns are automatically produced by
#' [dig_associations()].
#'
#' The supported interest measures that can be calculated include:
#' - Founded GUHA (General Unary Hypothesis Automaton) quantifiers:
#'   - `"fi"` - *Founded Implication*, which equals to the `"confidence"` measure
#'     calculated automatically by [dig_associations()].
#'   - `"dfi"` - *Double Founded Implication* computed as \eqn{pp / (pp + pn + np)}
#'   - `"fe"` - *Founded Equivalence* computed as \eqn{(pp + nn) / (pp + pn + np + nn)}
#' - GUHA quantifiers based on binomial tests - these measures require the
#'   additional parameter `p`, which represents the conditional probability of
#'   the consequent being true given that the antecedent is true under the null
#'   hypothesis. The measures are computed as one-sided p-values from the
#'   Clopper-Pearson confidence interval for the binomial proportion:
#'   - `"lci"` - *Lower Critical Implication* computed as
#'     \eqn{\sum_{i=pp}^{pp+pn} \frac{(pp+pn)!}{i!(pp+pn-i)!} p^i (1-p)^{pp+pn-i}}
#'   - `"uci"` - *Upper Critical Implication* computed as
#'     \eqn{\sum_{i=0}^{pp} \frac{(pp+pn)!}{i!(pp+pn-i)!} p^i (1-p)^{pp+pn-i}}
#'   - `"dlci"` - *Double Lower Critical Implication* computed as
#'     \eqn{\sum_{i=pp}^{pp+pn+np} \frac{(pp+pn+np)!}{i!(pp+pn+np-i)!} p^i (1-p)^{pp+pn+np-i}}
#'   - `"duci"` - *Double Upper Critical Implication* computed as
#'     \eqn{\sum_{i=0}^{pp} \frac{(pp+pn+np)!}{i!(pp+pn+np-i)!} p^i (1-p)^{pp+pn+np-i}}
#'   - `"lce"` - *Lower Critical Equivalence* computed as
#'     \eqn{\sum_{i=pp}^{pp+pn+np+nn} \frac{(pp+pn+np+nn)!}{i!(pp+pn+np+nn-i)!} p^i (1-p)^{pp+pn+np+nn-i}}
#'   - `"uce"` - *Upper Critical Equivalence* computed as
#'     \eqn{\sum_{i=0}^{pp} \frac{(pp+pn+np+nn)!}{i!(pp+pn+np+nn-i)!} p^i (1-p)^{pp+pn+np+nn-i}}
#'
#' - measures adopted from the `arules` package:
#'   `r .create_arules_measures_doc()`
#'
#' All the above measures are primarily intended for use with binary (logical)
#' data. While they can be computed for numerical data as well, their
#' interpretations may not be meaningful in that context - users should exercise
#' caution when applying these measures to non-binary data.
#'
#' Many measures are based on the contingency table counts, and some may be
#' undefined for certain combinations of counts (e.g., division by zero).
#' This issue can be mitigated by applying smoothing using the `smooth_counts`
#' argument.
#'
#' @param x A nugget of flavour `associations`, typically created with
#'    [dig_associations()].
#' @param measures A character vector specifying which interest measures to
#'    calculate. If `NULL` (the default), all supported measures are calculated.
#'    See the Details section for the list of supported measures.
#' @param smooth_counts A non-negative numeric value specifying the amount of
#'    Laplace smoothing to apply to the contingency table counts before
#'    calculating the interest measures. Default is `0` (no smoothing).
#'    Positive values add the specified amount to each of the counts
#'    (`pp`, `pn`, `np`, `nn`), which can help avoid issues with undefined measures
#'    due to zero counts. Use `smooth_counts = 1` for standard Laplace smoothing.
#'    Use `smooth_counts = 0.5` for Haldane-Anscombe smoothing, which is
#'    often used for odds ratio estimation and in chi-squared tests.
#' @param p A numeric value in the range `[0, 1]` representing the conditional
#'    probability of the consequent being true given that the antecedent is
#'    true. This parameter is used in the calculation of GUHA quantifiers
#'    `"lci"`, `"uci"`, `"dlci"`, `"duci"`, `"lce"`, and `"uce"`.
#'    The default value is `0.5`.
#' @param ... Currently unused.
#' @return An S3 object which is an instance of `associations` and `nugget`
#'    classes and which is a tibble containing all the columns of the input
#'    nugget `x`, plus additional columns for each of the requested interest
#'    measures.
#' @author Michal Burda
#' @seealso [dig_associations()]
#' @examples
#' d <- partition(mtcars, .breaks = 2)
#' rules <- dig_associations(d,
#'                           antecedent = !starts_with("mpg"),
#'                           consequent = starts_with("mpg"),
#'                           min_support = 0.3,
#'                           min_confidence = 0.8)
#' rules <- add_interest(rules,
#'                    measures = c("conviction", "leverage", "jaccard"))
#' @rdname add_interest
#' @method add_interest associations
#' @export
add_interest.associations <- function(x,
                                   measures = NULL,
                                   smooth_counts = 0,
                                   p = 0.5,
                                   ...) {
    .must_be_nugget(x, "associations")
    .must_have_numeric_column(x,
                              "pp",
                              arg_x = "x",
                              call = current_env())
    .must_have_numeric_column(x,
                              "pn",
                              arg_x = "x",
                              call = current_env())
    .must_have_numeric_column(x,
                              "np",
                              arg_x = "x",
                              call = current_env())
    .must_have_numeric_column(x,
                              "nn",
                              arg_x = "x",
                              call = current_env())

    supported_measures <- .get_supported_association_measures()
    .must_be_enum(measures,
                  names(supported_measures),
                  null = TRUE,
                  multi = TRUE)
    if (is.null(measures)) {
        measures <- names(supported_measures)
    }

    .must_be_double_scalar(smooth_counts)
    .must_be_greater_eq(smooth_counts, 0)

    .must_be_double_scalar(p)
    .must_be_in_range(p, c(0, 1))

    if (any(c(x$pp, x$pn, x$np, x$nn) < 0)) {
        cli_abort(c("{.arg x} contains negative counts in columns {.var pp}, {.var pn}, {.var np}, or {.var nn}.",
                    "x" = "All counts must be non-negative."),
                  call = current_env())
    }

    if (any(measures %in% colnames(x))) {
        cli_warn(c("Some of the selected measures are already present in {.arg x} and will be overwritten.",
                   "i" = "Measures: {.var {intersect(measures, colnames(x))}}."),
                 call = current_env())
    }

    n11 <- x$pp + smooth_counts
    n10 <- x$pn + smooth_counts
    n01 <- x$np + smooth_counts
    n00 <- x$nn + smooth_counts
    n1x <- n11 + n10
    n0x <- n01 + n00
    nx1 <- n11 + n01
    nx0 <- n10 + n00
    n1001 <- n10 + n01
    n1100 <- n11 + n00
    n <- n1x + n0x

    counts <- list(
        n11 = n11, n10 = n10, n01 = n01, n00 = n00,
        n1x = n1x, n0x = n0x, nx1 = nx1, nx0 = nx0,
        n1001 = n1001, n1100 = n1100,
        n = n
    )

    res <- lapply(measures, function(m) {
        func <- supported_measures[[m]]
        func(counts, p = p)
    })
    names(res) <- measures

    bind_cols(x, res)
}


.get_supported_association_measures <- function() {
    c(.arules_association_measures,
      .guha_association_measures)
}


.get_supported_association_measure_names <- function() {
    c(.arules_association_measure_names,
      .guha_association_measure_names)
}


.create_arules_measures_doc <- function() {
    measure_ids <- names(.arules_association_measures)
    measure_ids <- sort(measure_ids)
    measure_names <- .arules_association_measure_names[measure_ids]

    url_base <- "https://mhahsler.github.io/arules/docs/measures#"
    section_names <- gsub("_", "", measure_ids, fixed = TRUE)
    urls <- paste0(url_base, section_names)

    paste0("  - `\"", measure_ids, "\"` - *", measure_names, "*, ",
           "see [", urls, "](", urls, ") for details",
           collapse = "\n")
}
