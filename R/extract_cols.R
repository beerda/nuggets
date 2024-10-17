.extract_cols_and_check <- function(cols,
                                    selection,
                                    varname,
                                    numeric_allowed) {
    .must_be_list(cols)

    selection <- enquo(selection)
    indices <- eval_select(selection, cols)
    cols <- cols[indices]
    logicals <- vapply(cols, is.logical, logical(1))
    doubles <- vapply(cols, is_degree, logical(1))

    test <- logicals
    msg <- ""
    if (numeric_allowed) {
        test <- test | doubles
        msg <- " or numeric from the interval [0,1]"
    }

    if (!all(test)) {
        errors <- c()
        for (i in which(!test)) {
            intmsg <- ifelse(typeof(cols[[i]]) == "integer",
                             " with values less than 0 or greater than 1",
                             "")
            errors <- c(errors,
                        paste0("Column {.var ", names(cols)[i],
                               "} is of type {.cls ", typeof(cols[[i]]), "}{intmsg}."))
        }

        cli_abort(c("All columns selected by {.var {varname}} must be logical{msg}.",
                    ..error_details(errors)),
                  call = caller_env())
    }

    list(logicals = cols[logicals],
         doubles = cols[doubles],
         indices = c(indices[logicals], indices[doubles]))
}


