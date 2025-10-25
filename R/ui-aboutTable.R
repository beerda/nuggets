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
    author <- markdown(author)

    url <- descr[["URL"]]
    url <- gsub(", ", "<br>\n", url)
    url <- markdown(url)

    cita <- citation(pkg)
    citext <- format(cita, style = "text")
    citbib <- format(cita, style = "bibtex")

    tags$div(
        tags$table(class = "info-table left", width = "100%",
            tags$tr(tags$td("Package:"), tags$td(descr$Package)),
            tags$tr(tags$td("Version:"), tags$td(descr$Version)),
            tags$tr(tags$td("Date:"), tags$td(descr$Date)),
            tags$tr(tags$td("Author:"), tags$td(author)),
            tags$tr(tags$td("License:"), tags$td(descr$License)),
            tags$tr(tags$td("URL:"), tags$td(url)),
            tags$tr(tags$td("Bug reports:"), tags$td(markdown(descr$BugReports))),
            tags$tr(tags$td("Cite:"),
                        tags$td(markdown(citext),
                            tags$div(style = "font-family: monospace; white-space: pre-wrap;", citbib)
                        ))
        ),
    )
}
