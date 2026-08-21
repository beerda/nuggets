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


#' @title Convert arules::rules to nugget
#' @description
#' Convert an object of class `rules` from the \pkg{arules} package to
#' a nugget.
#' @details
#' The `rules` class is used in the \pkg{arules} package to represent
#' association rules. It contains association rules along with various statistics
#' such as support, confidence, and lift. Object of class `rules` can be
#' created using the [arules::apriori()] or [arules::eclat()] functions
#' and [arules::ruleInduction()] function.
#'
#' The resulting nugget object can be used for further analysis and exploration
#' using the functions provided by the \pkg{nuggets} package.
#'
#' @param x An object of class `rules` from the \pkg{arules} package.
#' @param ... Additional arguments (not used).
#' @return A nugget object containing the rules and associated statistics.
#'
#' @rdname as_nugget
#' @method as_nugget rules
#' @examples
#' # Prepare data
#' d <- partition(mtcars, .breaks = 2)
#'
#' # Use arules::apriori() to search for association rules
#' fit1 <- arules::apriori(d,
#'                         parameter = list(minlen = 1,
#'                                          maxlen = 6,
#'                                          supp = 0.001,
#'                                          conf = 0.5))
#'
#' # Convert the rules to a nugget
#' rules1 <- as_nugget(fit1)
#'
#' # Test whether we have the nugget
#' is_nugget(rules1)
#'
#' # Explore the results from arules interactively
#' \dontrun{
#' explore(rules1)
#' }
#'
#' # Use arules::eclat() to search for association rules
#' fit2 <- arules::eclat(d,
#'                       parameter = list(minlen = 1,
#'                                        maxlen = 6,
#'                                        supp=0.001))
#' fit2 <- arules::ruleInduction(fit2, confidence = 0.5)
#'
#' # Convert the rules to a nugget
#' rules2 <- as_nugget(fit2)
#'
#' # Test whether we have the nugget
#' is_nugget(rules2)
#'
#' # Explore the results from arules interactively
#' \dontrun{
#' explore(rules2)
#' }
#' @export
as_nugget.rules <- function(x, ...) {
    if (!methods::is(x, "rules")) {
        cli_abort(c("{.arg x} is not of class {.cls rules}.",
                    "i" = "Use {.fn as_nugget} on an object of class {.cls rules} from the {.pkg arules} package."))
    }

    if (!requireNamespace("arules", quietly = TRUE)) {
        cli_abort(c("Package {.pkg arules} is required to convert rules to a nugget.",
                    "x" = "The {.pkg arules} package is not installed.",
                    "i" = "Install it with: {.run install.packages('arules')}"))
    }

    df <- arules::DATAFRAME(x, separate = TRUE)
    colnames(df)[1:2] <- c("antecedent", "consequent")
    df$antecedent <- as.character(df$antecedent)
    df$consequent <- as.character(df$consequent)

    n <- x@info$ntransactions

    if (!"conseq_support" %in% colnames(df)) {
        df$conseq_support <- arules::interestMeasure(x, measure = "rhsSupport")
    }
    if (!"coverage" %in% colnames(df)) {
        df$coverage <- arules::interestMeasure(x, measure = "coverage")
    }
    if (!"count" %in% colnames(df)) {
        df$count <- round(df$support * n)
    }
    if (!"antecedent_length" %in% colnames(df)) {
        df$antecedent_length <- arules::size(arules::lhs(x))
    }

    pX <- round(df$coverage * n)
    Xp <- round(df$conseq_support * n)
    nX <- n - pX

    if (!"pp" %in% colnames(df)) {
        df$pp <- df$count
    }
    if (!"pn" %in% colnames(df)) {
        df$pn <- pX - df$pp
    }
    if (!"np" %in% colnames(df)) {
        df$np <- Xp - df$pp
    }
    if (!"nn" %in% colnames(df)) {
        df$nn <- n - df$pp - df$pn - df$np
    }

    required_columns <- c("antecedent", "consequent", "support", "confidence",
                          "coverage", "conseq_support", "lift", "count",
                          "antecedent_length", "pp", "pn", "np", "nn")
    intersect_columns <- intersect(required_columns, colnames(df))
    remaining_columns <- setdiff(colnames(df), intersect_columns)

    df <- df[, c(intersect_columns, remaining_columns)]

    call <- parse(text = x@info$call)[[1]]
    call_function <- as.character(call)[1]
    call_args <- as.list(call)[-1]
    call_args <- lapply(call_args, deparse)

    items <- unique(c(x@lhs@itemInfo$labels,
                      x@rhs@itemInfo$labels))

    nugget(as_tibble(df),
           flavour = "associations",
           call_function = call_function,
           call_data = list(nrow = x@info$ntransactions,
                            ncol = length(items),
                            colnames = items),
           call_args = call_args)
}

