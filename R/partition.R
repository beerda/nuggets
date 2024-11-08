#'
#' @return
#' @author Michal Burda
#' @export
partition <- function(.data,
                      .what = everything(),
                      ...,
                      .breaks = NULL,
                      .labels = NULL,
                      .na = TRUE,
                      .keep = FALSE,
                      .method = "crisp",
                      .right = TRUE) {
    .must_be_data_frame(.data)
    .must_be_numeric_vector(.breaks, null = TRUE)
    .must_be_character_vector(.labels, null = TRUE)
    .must_be_flag(.na)
    .must_be_flag(.keep)
    .must_be_enum(.method, c("crisp"))
    .must_be_flag(.right)

    sel <- enquos(.what, ...)
    sel <- lapply(sel, eval_select, .data)
    sel <- unlist(sel)
    emptydf <- as_tibble(data.frame(matrix(NA, nrow = nrow(.data), ncol = 0)))

    if (!is.null(.breaks)) {
        .breaks <- sort(.breaks)
    }

    res <- lapply(seq_along(sel), function(i) {
        colname <- names(sel)[i]
        colindex <- sel[i]
        res <- emptydf
        x <- .data[[colindex]]
        call <- current_env()

        if (is.logical(x)) {
            res <- tibble(a = !is.na(x) & x,
                          b = !is.na(x) & !x)
            colnames(res) <- paste0(colname, "=", c("T", "F"))

        } else if (is.factor(x)) {
            res <- .partition_factor(x, colname)

        } else if (is.numeric(x)) {
            if (is.null(.breaks)) {
                cli_abort(c("{.var .breaks} must not be NULL in order to partition numeric column {.var {colname}}."),
                          call = call)
            }

            if (.method == "crisp") {
                res <- .partition_crisp(x, colname, .breaks, .labels, .right, call)

            } else if (.method == "triangle") {
                br <- .determine_fuzzy_breaks(x, colname, .breaks, call)
            }

        } else {
            cli_abort(c("Unable to partition column {.var {colname}}.",
                       "i"="Column selected for partitioning must be a factor, logical, or numeric.",
                       "x"="The column {.var {colname}} is a {.cls {class(x)}}."),
                      call = call)
        }

        if (.na) {
            nas <- is.na(x)
            if (any(nas)) {
                res[paste0(colname, "=NA")] <- nas
            }
        }

        if (.keep) {
            res <- cbind(.data[colindex], res)
        }

        res
    })

    res <- do.call(cbind, res)

    as_tibble(res)
}


.partition_factor <- function(x, colname) {
    res <- lapply(levels(x), function(lev) !is.na(x) & x == lev)
    names(res) <- paste0(colname, "=", levels(x))

    as_tibble(res)
}


.partition_crisp <- function(x, colname, breaks, labels, right, call) {
    if (length(breaks) == 1) {
        if (breaks <= 1 || !is_integerish(breaks)) {
            cli_abort(c("If {.var .breaks} is a single value, it must be a natural number greater than 1.",
                        "i"="You've supplied {breaks}."),
                      call = call)
        }
        br <- .determine_crisp_breaks(x, breaks)
    } else {
        br <- breaks
    }

    if (is.null(labels)) {
        lb <- .determine_crisp_labels(br, right)
    } else {
        if (length(labels) != length(br) - 1) {
            if (length(breaks) == 1) {
                cli_abort(c("If {.var .breaks} is scalar, the length of {.var .labels} must be equal to the value of {.var .breaks}.",
                            "i"="The length of {.var .labels} is {length(labels)}.",
                            "i"="{.var .breaks} is {breaks}."),
                          call = call)
            } else {
                cli_abort(c("If {.var .breaks} is non-scalar, the length of {.var .labels} must be equal to the length of {.var .breaks} - 1.",
                            "i"="The length of {.var .labels} is {length(labels)}.",
                            "i"="The length of {.var .breaks} is {length(breaks)}."),
                          call = call)
            }
        }
        lb <- labels
    }

    xx <- cut(x, breaks = br, labels = lb, right = right)

    .partition_factor(xx, colname)
}


.partition_fuzzy <- function(x, colname, breaks, labels, right, call) {

}


.determine_crisp_breaks <- function(x, breaks) {
    breaks <- seq(from = min(x, na.rm = TRUE), to = max(x, na.rm = TRUE), length.out = breaks + 1)

    c(-Inf, breaks[c(-1, -length(breaks))], Inf)
}


.determine_crisp_labels <- function(breaks, right) {
    l <- signif(breaks[-length(breaks)], 3)
    r <- signif(breaks[-1], 3)
    ll <- ifelse(right, "(", "[")
    rr <- ifelse(right, "]", ")")

    paste0(ll, l, ";", r, rr)
}
