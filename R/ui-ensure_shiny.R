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


# Check that Shiny-related packages are installed
.ensure_shiny <- function() {
    required_packages <- c("shiny", "shinyjs", "shinyWidgets", "DT", "htmltools", "htmlwidgets", "jsonlite")
    missing_packages <- required_packages[!sapply(required_packages, requireNamespace, quietly = TRUE)]
    
    if (length(missing_packages) > 0) {
        install_cmd <- sprintf("install.packages(c(%s))", 
                              paste(shQuote(missing_packages, type = "cmd"), collapse = ", "))
        cli_abort(c(
            "Required packages are not installed.",
            "i" = paste("Missing packages:", paste(missing_packages, collapse = ", ")),
            "i" = paste("Install them with:", install_cmd)
        ))
    }
}
