infoBox <- function(...,
                    status = c("info", "success", "danger", "warning"),
                    dismissible = FALSE) {
    status <- match.arg(status)
    ico <- switch(status,
                  info = "info-circle",
                  success = "check-circle",
                  danger = "times-circle",
                  warning = "exclamation-triangle")

    alert(status = match.arg(status),
          dismissible = dismissible,
          div(class = "info-box", icon(ico), span(...)))
}
