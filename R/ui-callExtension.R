callExtension <- function(.extensions,
                          .id,
                          ...) {
    if (is.null(.extensions) || is.null(.extensions[[.id]])) {
        return(NULL)
    }

    ext <- .extensions[[.id]]
    if (is.function(ext)) {
        return(ext(...))
    } else {
        return(ext)
    }
}
