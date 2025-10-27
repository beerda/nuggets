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


.founded_impl <- function(a, b) a / (a + b)
.lower_crit_impl <- function(a, b, p) pbinom(b, size = a + b, prob = 1 - p)
.upper_crit_impl <- function(a, b, p) pbinom(a, size = a + b, prob = p)

.guha_association_measure_names <- c(
    fi = "Founded Implication",
    dfi = "Double Founded Implication",
    fe = "Founded Equivalence",
    lci = "Lower Critical Implication",
    dlci = "Double Lower Critical Implication",
    lce = "Lower Critical Equivalence",
    uci = "Upper Critical Implication",
    duci = "Double Upper Critical Implication",
    uce = "Upper Critical Equivalence"
)

.guha_association_measures <- list(
    fi = function(counts, ...)
        with(counts, .founded_impl(n11, n10)),

    dfi = function(counts, ...)
        with(counts, .founded_impl(n11, n1001)),

    fe = function(counts, ...)
        with(counts, .founded_impl(n1100, n1001)),

    lci = function(counts, p, ...)
        with(counts, .lower_crit_impl(n11, n10, p)),

    dlci = function(counts, p, ...)
        with(counts, .lower_crit_impl(n11, n1001, p)),

    lce = function(counts, p, ...)
        with(counts, .lower_crit_impl(n1100, n1001, p)),

    uci = function(counts, p, ...)
        with(counts, .upper_crit_impl(n11, n10, p)),

    duci = function(counts, p, ...)
        with(counts, .upper_crit_impl(n11, n1001, p)),

    uce = function(counts, p, ...)
        with(counts, .upper_crit_impl(n1100, n1001, p))
)
