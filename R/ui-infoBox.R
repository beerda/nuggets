infoBox <- function(...) {
    text <- paste(..., sep = "")
    div(class = "info-box",
        icon("info-circle", class = "info-icon"),
        span(text, class = "info-text")
    )
}
