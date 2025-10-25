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


infoBox <- function(...,
                    status = c("info", "success", "danger", "warning"),
                    dismissible = FALSE) {
    status <- match.arg(status)
    ico <- switch(status,
                  info = "circle-info",
                  success = "circle-check",
                  danger = "circle-xmark",
                  warning = "triangle-exclamation")

    alert(status = match.arg(status),
          dismissible = dismissible,
          div(class = "info-box", icon(ico), span(...)))
}
