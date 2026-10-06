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


#' @title Check if a nugget is originated from a given data frame or matrix
#'
#' @description
#' Check if a nugget was created from a given data frame or matrix. This is
#' useful for ensuring that the nugget is compatible with the data.
#'
#' @param x A nugget object.
#' @param data A data frame or matrix.
#' @return A logical value indicating whether the nugget is originated from
#'     the given data.
#'
#' @seealso [nugget()] for creating nuggets, and [is_nugget()] for checking
#'     if an object is a nugget, [dig()] for digging nuggets
#' @author Michal Burda
#' @export
is_from <- function(x, data) {
    .must_be_nugget(x)
    .must_be_matrix_or_data_frame(data)

    call_data <- attr(x, "call_data")

    !is.null(call_data) &&
        is.list(call_data) &&
        !is.null(call_data$nrow) &&
        !is.null(call_data$ncol) &&
        !is.null(call_data$colnames) &&
        identical(nrow(data), call_data$nrow) &&
        identical(ncol(data), call_data$ncol) &&
        identical(colnames(data), call_data$colnames)
}
