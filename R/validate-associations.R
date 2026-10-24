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


#' @title Recompute association-rule characteristics on new data
#'
#' @description
#' `r lifecycle::badge("experimental")`
#'
#' Recomputes the characteristics of association rules on `data`. Only the
#' rules in `x` are evaluated; no additional antecedent-consequent combinations
#' are returned. The returned rules retain the order of `x`.
#'
#' @details
#' The original search thresholds are ignored so that every rule in `x` is
#' evaluated. The original `weights`, `disjoint`, and `t_norm` settings are
#' reused. Therefore, `data` must contain every predicate used by the rules
#' and the original weights column, if one was used.
#'
#' @param x A nugget of flavour `"associations"` containing the rules to
#'   evaluate. Typically created with [dig_associations()].
#' @param data A matrix or data frame with the new data. The matrix must be
#'   numeric (double) or logical. If `data` is a data frame, each column must
#'   be numeric (double) or logical.
#' @param ... Further arguments, currently not used.
#'
#' @return A nugget of flavour `"associations"` with the rules from `x` and
#'   their characteristics recomputed on `data`.
#'
#' @seealso [dig_associations()] for finding association rules, and
#'   [is_from()] for checking whether a nugget was created from a data set.
#'
#' @examples
#' d <- data.frame(
#'     a = c(TRUE, TRUE, FALSE, FALSE),
#'     b = c(FALSE, TRUE, TRUE, FALSE),
#'     c = c(TRUE, TRUE, FALSE, FALSE)
#' )
#' rules <- dig_associations(d, a:b, c, min_support = 0)
#'
#' new_d <- d[c(1, 3, 4), ]
#' validate(rules, new_d)
#'
#' @rdname validate
#' @method validate associations
#' @export
validate.associations <- function(x,
                                  data,
                                  ...) {
    .must_be_nugget(x, "associations")
    .must_have_character_column(x, "antecedent")
    .must_have_character_column(x, "consequent")
    .must_be_matrix_or_data_frame(data)

    parsed_ante <- parse_condition(x$antecedent)
    parsed_cons <- parse_condition(x$consequent)
    ante <- unique(unlist(parsed_ante))
    cons <- unique(unlist(parsed_cons))
    aa <- attributes(x)
    required_columns <- unique(c(ante, cons, aa$call_args$weights))
    missing_columns <- setdiff(required_columns, colnames(data))

    if (length(missing_columns) > 0) {
        cli_abort(c("`data` must contain every predicate and weights column used by `x`.",
                    "x" = "`data` is missing: {.field {missing_columns}}."),
                  call = current_env())
    }

    if (nrow(x) == 0) {
        return(nugget(x,
                      flavour = "associations",
                      call_function = "dig_associations",
                      call_data = list(nrow = nrow(data),
                                       ncol = ncol(data),
                                       colnames = as.character(colnames(data))),
                      call_args = aa$call_args))
    }

    res <- dig_associations(x = data,
                            antecedent = all_of(ante),
                            consequent = all_of(cons),
                            weights = aa$call_args$weights,
                            disjoint = aa$call_args$disjoint,
                            exact = parsed_ante,
                            min_length = 0,
                            max_length = max(lengths(parsed_ante)),
                            min_coverage = 0,
                            min_support = 0,
                            min_confidence = 0,
                            t_norm = aa$call_args$t_norm,
                            max_results = Inf,
                            error_context = list(arg_x = "data",
                                                 arg_antecedent = "internal `ante`",
                                                 arg_consequent = "internal `cons`",
                                                 arg_weights = "attributes(x)$call_args$weights",
                                                 arg_disjoint = "attributes(x)$call_args$disjoint",
                                                 arg_t_norm = "attributes(x)$call_args$t_norm",
                                                 call = current_env()))

    rule_ids <- paste(x$antecedent, x$consequent, sep = "\r")
    res_ids <- paste(res$antecedent, res$consequent, sep = "\r")
    res[match(rule_ids, res_ids), , drop = FALSE]
}
