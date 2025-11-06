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


aboutTable <- function(pkg) {
    descr <- packageDescription(pkg)

    author <- descr[["Authors@R"]]
    author <- eval(parse(text = author))
    author <- format(author, style = "md")
    author <- shiny::markdown(author)

    url <- descr[["URL"]]
    url <- gsub(", ", "<br>\n", url)
    url <- shiny::markdown(url)

    cita <- citation(pkg)
    citext <- format(cita, style = "text")
    citbib <- format(cita, style = "bibtex")

    htmltools::tags$div(
        htmltools::tags$table(class = "info-table left", width = "100%",
            htmltools::tags$tr(htmltools::tags$td("Package:"), htmltools::tags$td(descr$Package)),
            htmltools::tags$tr(htmltools::tags$td("Version:"), htmltools::tags$td(descr$Version)),
            htmltools::tags$tr(htmltools::tags$td("Date:"), htmltools::tags$td(descr$Date)),
            htmltools::tags$tr(htmltools::tags$td("Author:"), htmltools::tags$td(author)),
            htmltools::tags$tr(htmltools::tags$td("License:"), htmltools::tags$td(descr$License)),
            htmltools::tags$tr(htmltools::tags$td("URL:"), htmltools::tags$td(url)),
            htmltools::tags$tr(htmltools::tags$td("Bug reports:"), htmltools::tags$td(shiny::markdown(descr$BugReports))),
            htmltools::tags$tr(htmltools::tags$td("Cite:"),
                        htmltools::tags$td(shiny::markdown(citext),
                            htmltools::tags$div(style = "font-family: monospace; white-space: pre-wrap;", citbib)
                        ))
        ),
    )
}
