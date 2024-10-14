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
                        paste0("Column {.var ", names(cols)[i],
                               "} is of type {.cls ", typeof(cols[[i]]), "}."))
        }

        cli_abort(c("All columns in {.var x} must be either logical or double.",
                    ..error_details(errors)),
                  call = caller_env())
    }

    list(logicals = cols[logicals],
         doubles = cols[doubles],
         indices = c(indices[logicals], indices[doubles]))
}


