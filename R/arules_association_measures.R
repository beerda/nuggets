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

#######################################################################
# This file contains code adapted from the 'arules' package licensed
# under GPL-2 or later.
#
# Version of original package:
#   arules 1.7-11
#
# Original file:
#   https://github.com/mhahsler/arules/blob/master/R/interestMeasures.R

# Original author:
#   Michael Hahsler, Christian Buchta, Bettina Gruen and Kurt Hornik
#
# Date of adaptation:
#   2025-10-25
#
# Changes made:
#   Functions for computation of interest measures stored in a list as
#   named elements and adapted to work with counts passed as a list.
#
# Original copyright header:
#   arules - Mining Association Rules and Frequent Itemsets
#   Copyright (C) 2011-2015 Michael Hahsler, Christian Buchta,
#             Bettina Gruen and Kurt Hornik
#
#   This program is free software; you can redistribute it and/or modify
#   it under the terms of the GNU General Public License as published by
#   the Free Software Foundation; either version 2 of the License, or
#   any later version.
#
#   This program is distributed in the hope that it will be useful,
#   but WITHOUT ANY WARRANTY; without even the implied warranty of
#   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#   GNU General Public License for more details.
#
#   You should have received a copy of the GNU General Public License along
#   with this program; if not, write to the Free Software Foundation, Inc.,
#   51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.
#######################################################################

.arules_association_measure_names <- c(
    cosine = "Cosine",
    conviction = "Conviction",
    gini = "Gini Index",
    rule_power_factor = "Rule Power Factor",
    odds_ratio = "Odds Ratio",
    relative_risk = "Relative Risk",
    phi = "Phi Correlation Coefficient",
    leverage = "Leverage",
    collective_strength = "Collective Strength",
    importance = "Importance",
    imbalance = "Imbalance Ratio",
    jaccard = "Jaccard Coefficient",
    kappa = "Kappa",
    lambda = "Lambda",
    mutual_information = "Mutual Information",
    maxconfidence = "Max Confidence",
    j_measure = "J-Measure",
    kulczynski = "Kulczynski",
    certainty = "Certainty Factor",
    added_value = "Added Value",
    ralambondrainy = "Ralambondrainy",
    sebag = "Sebag-Schoenauer",
    counterexample = "Example and Counter-Example Rate",
    confirmed_confidence = "Descriptive Confirmed Confidence",
    casual_support = "Casual Support",
    casual_confidence = "Casual Confidence",
    least_contradiction = "Least Contradiction",
    centered_confidence = "Centered Confidence",
    varying_liaison = "Varying Rates Liaison",
    yule_q = "Yule's Q",
    yule_y = "Yule's Y",
    lerman = "Lerman Similarity",
    implication_index = "Implication Index",
    doc = "Difference of Confidence"
#    chi_squared = "Chi-Squared Test"
)

.arules_association_measures <- list(
    cosine = function(counts, ...)
        with(counts, n11 / sqrt(n1x * nx1)),

    conviction = function(counts, ...)
        with(counts, n1x * nx0 / (n * n10)),

    gini = function(counts, ...)
        with(counts,
             n1x / n * ((n11 / n1x)^2 + (n10 / n1x)^2) -
                 (nx1 / n)^2 + n0x / n * ((n01 / n0x)^2 + (n00 / n0x)^2) - (nx0 / n)^2
    ),

    rule_power_factor = function(counts, ...)
        with(counts, n11 * n11 / n1x / n),

    odds_ratio = function(counts, ...)
        with(counts, n11 * n00 / (n10 * n01)),

    relative_risk = function(counts, ...)
        with(counts, (n11 / n1x) / (n01 / n0x)),

    phi = function(counts, ...)
        with(counts, (n * n11 - n1x * nx1) / sqrt(n1x * nx1 * n0x * nx0)),

    leverage = function(counts, ...)
        with(counts, n11 / n - (n1x * nx1 / n^2)),

    collective_strength = function(counts, ...)
        with(counts,
             n11 * n00 / (n1x * nx1 + n0x + nx0) *
                 (n^2 - n1x * nx1 - n0x * nx0) / (n - n11 - n00)),

    importance = function(counts, ...)
        with(counts,
             log(((n11 + 1) * (n0x + 2)) / ((n01 + 1) * (n1x + 2)), base = 10)
    ),

    imbalance = function(counts, ...)
        with(counts, abs(n1x - nx1) / (n1x + nx1 - n11)),

    jaccard = function(counts, ...)
        with(counts, n11 / (n1x + nx1 - n11)),

    kappa = function(counts, ...)
        with(counts,
             (n * n11 + n * n00 - n1x * nx1 - n0x * nx0) /
                 (n^2 - n1x * nx1 - n0x * nx0)
    ),

    lambda = function(counts, ...)
        with(counts, {
            max_x0x1 <- apply(cbind(nx1, nx0), 1, max)
            aaa <- apply(cbind(n11, n10), 1, max)
            bbb <- apply(cbind(n01, n00), 1, max)
            (aaa + bbb - max_x0x1) / (n - max_x0x1)
        }),

    mutual_information = function(counts, ...)
        with(counts,
             (
                 n00 / n * log(n * n00 / (n0x * nx0)) +
                 n01 / n * log(n * n01 / (n0x * nx1)) +
                 n10 / n * log(n * n10 / (n1x * nx0)) +
                 n11 / n * log(n * n11 / (n1x * nx1))
             ) /
             pmin(
                -1 * (n0x / n * log(n0x / n) + n1x / n * log(n1x / n)),
                -1 * (nx0 / n * log(nx0 / n) + nx1 / n * log(nx1 / n))
             )),

    maxconfidence = function(counts, ...)
        with(counts, pmax(n11 / n1x, n11 / nx1)),

    j_measure = function(counts, ...)
        with(counts,
             n11 / n * log(n * n11 / (n1x * nx1)) +
                 n10 / n * log(n * n10 / (n1x * nx0))),

    kulczynski = function(counts, ...)
        with(counts, (n11 / n1x + n11 / nx1) / 2),

    certainty = function(counts, ...)
        with(counts, (n11 / n1x - nx1 / n) / (1 - nx1 / n)),

    added_value = function(counts, ...)
        with(counts, n11 / n1x - nx1 / n),

    ralambondrainy = function(counts, ...)
        with(counts, n10 / n),

    sebag = function(counts, ...)
        with(counts, (n1x - n10) / n10),

    counterexample = function(counts, ...)
        with(counts, (n11 - n10) / n11),

    confirmed_confidence = function(counts, ...)
        with(counts, (n11 - n10) / n1x),

    casual_support = function(counts, ...)
        with(counts, (n1x + nx1 - 2 * n10) / n),

    casual_confidence = function(counts, ...)
        with(counts, 1 - n10 / n * (1 / n1x + 1 / nx1)),

    least_contradiction = function(counts, ...)
        with(counts, (n1x - n10) / nx1),

    centered_confidence = function(counts, ...)
        with(counts, nx0 / n - n10 / n1x),

    varying_liaison = function(counts, ...)
        with(counts, (n1x - n10) / (n1x * nx1 / n) - 1),

    yule_q = function(counts, ...)
        with(counts, {
            OR <- n11 * n00 / (n10 * n01)
            (OR - 1) / (OR + 1)
        }),

    yule_y = function(counts, ...)
        with(counts, {
            OR <- n11 * n00 / (n10 * n01)
            (sqrt(OR) - 1) / (sqrt(OR) + 1)
        }),

    lerman = function(counts, ...)
        with(counts, (n11 - n1x * nx1 / n) / sqrt(n1x * nx1 / n)),

    implication_index = function(counts, ...)
        with(counts, (n10 - n1x * nx0 / n) / sqrt(n1x * nx0 / n)),

    doc = function(counts, ...)
        with(counts, (n11 / n1x) - (n01 / n0x))

#    chi_squared = function(counts, significance = FALSE, complement = FALSE) with(counts, {
#        len <- length(n11)
#        chi2 <- numeric(len)
#
#        for (i in seq_len(len)) {
#            fo <- matrix(c(n00[i], n01[i], n10[i], n11[i]), ncol = 2)
#            suppressWarnings(chi2[i] <- stats::chisq.test(fo, correct = FALSE)$statistic)
#        }
#
#        if (!significance) {
#            chi2
#        } else {
#            stats::pchisq(q = chi2, df = 1, lower.tail = !complement)
#        }
#    })
)
