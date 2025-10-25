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


# Run expr and handle errors, warnings and messages.
#
# @return a list with two elements: result, comment. If expr results with error,
#       the result element is set to NULL. Comment contains all output, warnings
#       and messages
# @author Michal Burda
.quietly <- function(expr, name = NULL) {
    f <- function()  expr
    f2 <- quietly(safely(f))
    res <- f2()

    comment <- NULL
    if (nchar(res$output) > 0) {
        comment <- paste("output:", str_trim(res$output))
    }
    if (length(res$messages) > 0) {
        comment <- c(comment, paste("message:", str_trim(res$messages)))
    }
    if (length(res$warnings) > 0) {
        comment <- c(comment, paste("warning:", str_trim(res$warnings)))
    }
    if (!is.null(res$result$error)) {
        comment <- c(comment, paste("error:", str_trim(res$result$error$message)))
    }
    comment <- paste0(comment, collapse = "\n")

    list(result = res$result$result,
         comment = comment)
}
