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


#' @title Generate all permutations of a vector
#'
#' @description
#' This function generates all possible permutations of the elements in a given
#' vector `x`. The result is returned as a matrix, where each row represents a
#' unique permutation of the input vector.
#'
#' @param x A vector of elements to permute. The elements can be of any type, but
#'     they should be unique for meaningful permutations.
#'
#' @return A matrix where each row is a unique permutation of the input vector `x`.
#'
#' @seealso [utils::combn()] for combinations of elements.
#' @author Michal Burda
#'
#' @examples
#' permute(c(1, 2, 3))
#' permute(c("a", "b", "c"))
#'
#' @export
permute <- function(x) {
    .must_be_vector(x, null = TRUE)

    if (length(x) == 0) {
        return(matrix(nrow = 0, ncol = 0))
    }
    if (length(x) == 1) {
        return(matrix(x, ncol = 1))
    }

    res <- matrix(nrow = 0, ncol = length(x))
    for (i in seq_along(x)) {
        res <- rbind(res, cbind(x[i], Recall(x[-i])))
    }

    res
}
