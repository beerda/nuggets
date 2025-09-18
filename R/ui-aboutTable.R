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
