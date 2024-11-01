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
            br <- .determine_breaks(x, colname, .breaks, call)
            lb <- .determine_crisp_labels(br, .labels, .right, call)
            if (.method == "crisp") {
                xx <- cut(x, breaks = br, labels = lb, right = .right)
                res <- .partition_factor(xx, colname)
            }
        } else {
            cli_abort(c("Unable to partition column {.var {colname}}.",
                       "i"="Column to partition must be a factor, logical, or numeric.",
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


.determine_breaks <- function(x, colname, breaks, call) {
    if (is.null(breaks)) {
        cli_abort(c("{.var .breaks} must not be NULL in order to partition numeric column {.var {colname}}."),
                  call = call)

    } else if (length(breaks) == 1) {
        if (breaks <= 1 || !is_integerish(breaks)) {
            cli_abort(c("If {.var .breaks} is a single value, it must be a natural number greater than 1.",
                        "i"="You've supplied {breaks}."),
                      call = call)
        }
        br <- seq(from = min(x, na.rm = TRUE), to = max(x, na.rm = TRUE), length.out = breaks + 1)
        br <- c(-Inf, br[c(-1, -length(br))], Inf)

    } else {
        br <- sort(breaks)
    }

    br
}


.determine_crisp_labels <- function(breaks, labels, right, call) {
    if (is.null(labels)) {
        l <- signif(breaks[-length(breaks)], 3)
        r <- signif(breaks[-1], 3)
        ll <- ifelse(right, "(", "[")
        rr <- ifelse(right, "]", ")")
        ll <- ifelse(is.finite(l), ll, "(")
        rr <- ifelse(is.finite(r), rr, ")")
        labels <- paste0(ll, l, ";", r, rr)
    } else {
        if (length(labels) != length(breaks) - 1) {
            cli_abort(c("The length of {.var .labels} must be equal to the length of {.var .breaks} - 1.",
                        "i"="THe length of {.var .labels} is {length(labels)}.",
                        "i"="THe length of {.var .breaks} is {length(breaks)}."),
                      call = call)
        }
    }

    labels
}
