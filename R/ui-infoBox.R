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
