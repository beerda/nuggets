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


#' Plot a mosaic plot for a contingency table
#'
#' This function creates a mosaic plot for a contingency table defined by the
#' counts of true positives, false positives, false negatives, and true negatives.
#' The plot visually represents the distribution of these counts in a 2x2 grid.
#' The area of each rectangle in the plot corresponds to the count of the respective category.
#' Vertical and horizontal lines are added to the plot to indicate the expected
#' proportions of the counts under the assumption of independence between the antecedent
#' and the consequent.
#'
#' @return A ggplot object representing the mosaic plot of the contingency table.
#' @author Michal Burda
#' @rdname plot_contingency
#' @export
plot_contingency <- function(...) {
    UseMethod("plot_contingency")
}

