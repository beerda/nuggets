.extract_cols <- function(cols, selection) {
    .must_be_list(cols)

    selection <- enquo(selection)
    indices <- eval_select(selection, cols)
    cols <- cols[indices]
    logicals <- vapply(cols, is.logical, logical(1))
    doubles <- vapply(cols, is.double, logical(1))

    if (!all(logicals | doubles)) {
        errors <- c()
        for (i in which(!(logicals | doubles))) {
            errors <- c(errors,
                        "x" = paste0("Column {.var ",
                                     names(cols)[i],
                                     "} is of type {.cls ",
                                     typeof(cols[[i]]),
                                     "}."))
        }
        len <- length(errors)
        if (len > 5) {
            length(errors) <- 4
            len <- len - length(errors)
            errors <- c(errors, paste0("... and ", len, " more problems."))
        }
        cli_abort(c("All columns in {.var x} must be either logical or double.",
                    errors),
                  call = caller_env())
    }

    list(logicals = cols[logicals],
         doubles = cols[doubles],
         indices = c(indices[logicals], indices[doubles]))
}


