#' @export
#' @author Michal Burda
dichotomize <- function(.data, ..., .keep = FALSE) {
    .must_be_data_frame(.data)
    .must_be_flag(.keep)

    sel <- enquos(...)
    sel <- lapply(sel, eval_select, .data)
    sel <- unlist(sel)
    emptydf <- data.frame(matrix(, nrow = nrow(.data), ncol = 0))
    call <- current_env()

    res <- lapply(seq_along(sel), function(i) {
        colname <- names(sel)[i]
        colindex <- sel[i]
        res <- emptydf
        x <- .data[[colindex]]

        if (is.logical(x)) {
            res <- data.frame(a=x, b=!x)
            colnames(res) <- paste0(colname, "=", c("T", "F"))
        } else if (is.factor(x)) {
            res <- lapply(levels(x), function(lev) x == lev)
            names(res) <- paste0(colname, "=", levels(x))
            res <- as.data.frame(res)
        } else {
            cli_abort(c("Unable to dichotomize the column {.var {colname}}.",
                       "i"="Column to dichotomize must be a factor or logical.",
                       "x"="The column {.var {colname}} is a {.cls {class(x)}}."),
                      call = call)
        }

        if (.keep) {
            res <- cbind(.data[colindex], res)
        }

        res
    })

    do.call(cbind, res)
}
