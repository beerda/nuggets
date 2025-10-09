#' Convert columns of a data frame to Boolean or fuzzy sets
#' (triangular, trapezoidal, or raised-cosine)
#'
#' Transform selected columns of a data frame into either dummy logical
#' variables or membership degrees of fuzzy sets, while leaving all remaining
#' columns unchanged. Each transformed column typically produces multiple new
#' columns in the output.
#'
#' These transformations are most often used as a preprocessing step before
#' calling [dig()] or one of its derivatives, such as
#' [dig_correlations()], [dig_paired_baseline_contrasts()],
#' or [dig_associations()].
#'
#' The transformation depends on the column type:
#' - **logical** column `x` is expanded into two logical columns:
#'   `x=TRUE` and `x=FALSE`;
#' - **factor** column `x` with levels `l1`, `l2`, `l3` becomes three
#'   logical columns: `x=l1`, `x=l2`, and `x=l3`;
#' - **numeric** column `x` is transformed according to `.method`:
#'   - `.method = "dummy"`: the column is treated as a factor with one level
#'     for each unique value, then expanded to dummy columns. This produces
#'     one logical column per unique value;
#'   - `.method = "crisp"`: the column is discretized into intervals (defined
#'     by `.breaks`) and then expanded to dummy columns representing these
#'     intervals;
#'   - `.method = "triangle"` or `.method = "raisedcos"`: the column is
#'     converted into one or more fuzzy sets. Each new column contains values
#'     in \eqn{[0,1]} representing degrees of membership to the fuzzy set
#'     (triangular or raised-cosine shaped).
#'
#' Details of numeric transformations are controlled by `.breaks`, `.labels`,
#' `.right`, `.span`, and `.inc`.
#'
#' @details
#' * Crisp partitioning is recommended for efficiency and works best when
#'   sharp category boundaries are meaningful for the analysis.
#' * Fuzzy partitioning is useful when attributes change gradually or when
#'   uncertainty should be modeled explicitly. It allows smooth transitions
#'   between categories and may yield more interpretable patterns, but is
#'   more computationally demanding.
#'
#' @section Crisp transformation of numeric data:
#'
#' For `.method = "crisp"`, numeric columns are converted into sets of dummy
#' logical variables, each representing one interval of values defined by
#' `.breaks`.
#'
#' * If `.breaks` is an integer, it specifies the number of equal-width
#'   intervals into which the column range is divided. The first and last
#'   intervals extend to infinity.
#' * If `.breaks` is a numeric vector, it specifies interval boundaries
#'   directly. Infinite values are allowed.
#'
#' With `.span = 1` and `.inc = 1`, the intervals are consecutive and
#' non-overlapping. For example, with
#' `.breaks = c(1, 3, 5, 7, 9, 11)` and `.right = TRUE`,
#' the intervals are \eqn{(1;3]}, \eqn{(3;5]}, \eqn{(5;7]}, \eqn{(7;9]},
#' and \eqn{(9;11]}. If `.right = FALSE`, the intervals are left-closed:
#' \eqn{[1;3)}, \eqn{[3;5)}, etc.
#'
#' Larger `.span` values make intervals overlap. For example, with
#' `.span = 2`, `.inc = 1`, and `.right = TRUE`, the intervals are
#' \eqn{(1;5]}, \eqn{(3;7]}, \eqn{(5;9]}, and \eqn{(7;11]}.
#'
#' The `.inc` argument modifies how far the window shifts along `.breaks`.
#' For example:
#' * `.span = 1`, `.inc = 2` → \eqn{(1;3]}, \eqn{(5;7]}, \eqn{(9;11]}.
#' * `.span = 2`, `.inc = 3` → \eqn{(1;5]}, \eqn{(9;11]}.
#'
#' @section Fuzzy transformation of numeric data:
#'
#' For `.method = "triangle"` or `.method = "raisedcos"`, numeric columns are
#' converted into fuzzy membership degrees \eqn{[0,1]}.
#'
#' * If `.breaks` is an integer, it specifies the number of fuzzy sets to
#'   generate (breakpoints are chosen automatically).
#' * If `.breaks` is a numeric vector, it directly defines the fuzzy set
#'   boundaries. Infinite values are allowed, which produces fuzzy sets with
#'   open ends.
#'
#' With `.span = 1`, each fuzzy set is defined by three consecutive breaks:
#' membership is 0 outside the outer breaks, increases to 1 at the middle
#' break, and then decreases back to 0. This yields triangular or raised-cosine
#' sets.
#'
#' With `.span > 1`, fuzzy sets are defined by four breaks: the degree
#' increases between the first two, stays 1 between the middle two, and
#' decreases between the last two. This produces trapezoidal fuzzy sets, with
#' linear borders if `.method = "triangle"`, or cosine-shaped borders if
#' `.method = "raisedcos"`.
#'
#' As with crisp sets, `.inc` determines how far the break window shifts when
#' creating the next fuzzy set. For example:
#' * `.span = 1`, `.inc = 1` → \eqn{(1;3;5)}, \eqn{(3;5;7)}, \eqn{(5;7;9)}, \eqn{(7;9;11)}.
#' * `.span = 2`, `.inc = 1` → \eqn{(1;3;5;7)}, \eqn{(3;5;7;9)}, \eqn{(5;7;9;11)}.
#' * `.span = 1`, `.inc = 3` → \eqn{(1;3;5)}, \eqn{(7;9;11)}.
#'
#' See the examples for further details.
#'
#' @param .data A data frame to be processed.
#' @param .what A tidyselect expression (see
#'   [tidyselect syntax](https://tidyselect.r-lib.org/articles/syntax.html))
#'   selecting the columns to transform.
#' @param ... Additional tidyselect expressions selecting more columns.
#' @param .breaks Ignored if `.method = "dummy"`. For other methods, either
#'   an integer scalar (number of intervals/sets) or a numeric vector of
#'   breakpoints.
#' @param .labels Optional character vector with labels used for new column
#'   names. If `NULL`, labels are generated automatically.
#' @param .na If `TRUE`, an extra logical column is created for each source
#'   column that contains `NA` values (e.g. `x=NA`).
#' @param .keep If `TRUE`, keep the original columns in the output.
#' @param .method Transformation method for numeric columns: `"dummy"`,
#'   `"crisp"`, `"triangle"`, or `"raisedcos"`.
#' @param .style Specifies how intervals are determined when `.breaks` is
#'   an integer. The determination of breaks is done by the
#'   [classInt::classIntervals()] function from the `classInt` package, which
#'   calls various functions to compute intervals. Additional parameters for
#'   these functions may be passed via `.style_params`. Possible values are:
#'   `"equal"` (equal-width intervals), `"quantile"` (equal-frequency
#'   intervals, see [quantile()]), `"kmeans"` (intervals determined by 1D
#'   k-means clustering, see [kmeans()]), `"sd"` (intervals based on standard
#'   deviations from the mean), `"hclust"` (intervals based on hierarchical
#'   clustering, see [hclust()]), `"bclust"` (intervals based on model-based
#'   clustering, see [e1071::bclust()]), `"fisher"` (Fisher-Jenks optimal
#'   partitioning), `"jenks"` (Jenks natural breaks), `"dpih"` (data-precision
#'   interval halving, see [KernSmooth::dpih()]), `"headtails"` (head/tails
#'   breaks), `"maximum"` (maximum breaks), and `"box"` (hinges
#'   of a boxplot). The default is `"equal"`. See [classInt::classIntervals()]
#'   for more details. Argument is recognized only if `.method = "crisp"` and
#'   ignored if `.breaks` is a vector.
#' @param .style_params A list of additional parameters passed to underlying
#'   function that determines intervals (via [classInt::classIntervals()])
#'   when `.method = "crisp"` and `.breaks` is an integer. The function called
#'   is determined by `.style`. See the description of `.style` and the
#'   documentation of [classInt::classIntervals()] for possible parameters.
#' @param .right For `"crisp"`, whether intervals are right-closed and
#'   left-open (`TRUE`), or left-closed and right-open (`FALSE`).
#' @param .span Number of consecutive breaks forming a set. For `"crisp"`,
#'   controls interval width. For `"triangle"`/`"raisedcos"`, `.span = 1`
#'   produces triangular sets, `.span = 2` trapezoidal sets.
#' @param .inc Step size for shifting breaks when generating successive sets.
#'   With `.inc = 1`, all possible sets are created; larger values skip sets.
#'
#' @return A tibble with `.data` transformed into Boolean or fuzzy predicates.
#' @author Michal Burda
#'
#' @examples
#' # Transform logical columns and factors
#' d <- data.frame(a = c(TRUE, TRUE, FALSE),
#'                 b = factor(c("A", "B", "A")),
#'                 c = c(1, 2, 3))
#' partition(d, a, b, c, .method = "dummy")
#'
#' # Crisp transformation of numeric data
#' partition(CO2, conc:uptake, .method = "crisp", .breaks = 3)
#'
#' # Triangular fuzzy sets
#' partition(CO2, conc:uptake, .method = "triangle", .breaks = 3)
#'
#' # Raised-cosine fuzzy sets
#' partition(CO2, conc:uptake, .method = "raisedcos", .breaks = 3)
#'
#' # Trapezoidal fuzzy sets, overlapping to satisfy the Ruspini condition
#' partition(CO2, conc:uptake, .method = "triangle", .breaks = 3,
#'           .span = 2, .inc = 2)
#'
#' # Complex transformation with different settings per column
#' CO2 |>
#'   partition(Plant:Treatment) |>
#'   partition(conc,
#'             .method = "raisedcos",
#'             .breaks = c(-Inf, 95, 175, 350, 675, 1000, Inf)) |>
#'   partition(uptake,
#'             .method = "triangle",
#'             .breaks = c(-Inf, 7.7, 28.3, 45.5, Inf),
#'             .labels = c("low", "medium", "high"))
#'
#' @export
partition <- function(.data,
                      .what = everything(),
                      ...,
                      .breaks = NULL,
                      .labels = NULL,
                      .na = TRUE,
                      .keep = FALSE,
                      .method = "crisp",
                      .style = "equal",
                      .style_params = list(),
                      .right = TRUE,
                      .span = 1,
                      .inc = 1) {
    .must_be_data_frame(.data)
    .must_be_numeric_vector(.breaks, null = TRUE)
    .must_be_character_vector(.labels, null = TRUE)
    .must_be_flag(.na)
    .must_be_flag(.keep)
    .must_be_enum(.method, c("dummy", "crisp", "triangle", "raisedcos"))
    .must_be_enum(.style, c("equal", "quantile", "kmeans", "sd", "hclust", "bclust",
                            "fisher", "jenks", "dpih", "headtails", "maximum", "box"))
    .must_be_list(.style_params)
    .must_be_flag(.right)
    .must_be_integerish_scalar(.span)
    .must_be_greater_eq(.span, 1)
    .must_be_integerish_scalar(.inc)
    .must_be_greater_eq(.inc, 1)

    if (.style != "equal" && .method != "crisp") {
        cli_abort(c("The {.arg .style} argument is only applicable when {.arg .method} is {.val crisp}.",
                    "i" = "You've supplied {.arg .style} = {.val {.style}} and {.arg .method} = {.val {.method}}."),
                  call = current_env())
    }

    emptydf <- as_tibble(data.frame(matrix(NA, nrow = nrow(.data), ncol = 0)))
    call <- current_env()

    if (!is.null(.breaks)) {
        .breaks <- sort(.breaks)
    }

    sel <- enquos(.what, ...)
    sel <- lapply(sel,
                  eval_select,
                  data = .data,
                  allow_rename = FALSE,
                  allow_empty = TRUE,
                  error_call = current_env())
    sel <- unlist(sel)
    names(sel) <- .sanitize_predicate_name(names(sel))

    if (length(sel) <= 0) {
        return(as_tibble(.data))
    }

    res <- lapply(seq_along(sel), function(i) {
        colname <- names(sel)[i]
        colindex <- sel[i]
        res <- emptydf
        x <- .data[[colindex]]

        if (all(is.na(x))) {
            cli_abort(c("Unable to partition column {.var {colname}}.",
                       "i"="Column selected for partitioning must contain some non-NA values.",
                       "x"="Column {.var {colname}} is empty or all values are NA."),
                      call = call)

        } else if (is.logical(x)) {
            res <- tibble(a = !is.na(x) & x,
                          b = !is.na(x) & !x)
            colnames(res) <- paste0(colname, "=", c("T", "F"))

        } else if (is.factor(x)) {
            res <- .partition_factor(x, colname)

        } else if (is.numeric(x)) {
            if (.method == "dummy") {
                res <- .partition_factor(as.factor(x), colname)

            } else if (is.null(.breaks)) {
                cli_abort(c("{.arg .breaks} must not be NULL in order to partition numeric column {.var {colname}}."),
                          call = call)

            } else if (.method == "crisp") {
                pp <- .prepare_crisp(x, colname, .breaks, .labels,
                                     .style, .style_params,
                                     .right, .span, .inc, call)
                f <- if (.right) {
                    function(x, br)  !is.na(x) & x > br[1] & x <= br[length(br)]
                } else {
                    function(x, br)  !is.na(x) & x >= br[1] & x < br[length(br)]
                }
                res <- .partition_numeric(x, pp, colname, f)

            } else {
                pp <- .prepare_fuzzy(x, colname, .breaks, .labels, .span, .inc, call)
                f <- if (.method == "triangle") triangle_ else raisedcos_
                res <- .partition_numeric(x, pp, colname, f)
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

        res
    })

    res <- do.call(cbind, res)
    keeped <- if (.keep) .data else .data[-sel]
    res <- cbind(keeped, res)

    as_tibble(res)
}


.partition_factor <- function(x, colname) {
    res <- lapply(levels(x), function(lev) !is.na(x) & x == lev)
    names(res) <- paste0(colname, "=", .sanitize_predicate_name(levels(x)))

    as_tibble(res)
}


.prepare_crisp <- function(x, colname, breaks, labels,
                           style, style_params,
                           right, span, inc, call) {
    if (length(breaks) == 1) {
        .check_scalar_breaks(breaks, call)
        br <- .determine_crisp_breaks(x, breaks, style, style_params, right, span, inc)
    } else {
        n <- (length(breaks) - span - 1) / inc + 1
        req <- span + (ceiling(n) - 1) * inc + 1
        if (!is_integerish(n) || n <= 0) {
            cli_abort(c("If {.arg .breaks} is non-scalar, the length of the vector must be equal to {.arg .span} + (n - 1) * {inc} + 1 for some natural number n.",
                        "i"="The length of {.arg .breaks} is {length(breaks)}.",
                        "i"="The value of {.arg .span} is {span}.",
                        "i"="The value of {.arg .inc} is {inc}.",
                        "i"="Provide {req - length(breaks)} more elements to {.arg .breaks} to satisfy the condition."),
                      call = call)
        }
        br <- breaks
    }
    br <- .explode_breaks(br, span, inc)

    if (is.null(labels)) {
        lb <- .determine_crisp_labels(br, right)
    } else {
        if (length(labels) != length(br)) {
            if (length(breaks) == 1) {
                cli_abort(c("If {.arg .breaks} is scalar, the length of {.arg .labels} must be equal to the value of {.arg .breaks}.",
                            "i"="The length of {.arg .labels} is {length(labels)}.",
                            "i"="{.arg .breaks} is scalar value {breaks}."),
                          call = call)
            } else {
                n <- (length(breaks) - span - 1) / inc + 1
                if (length(br) != n) {
                    stop("fatal in .prepare_crisp()")
                }
                cli_abort(c("If {.arg .breaks} is non-scalar, the length of {.arg .labels} must be equal to (length({.arg .breaks}) - {.arg .span} - 1) / {.arg .inc} + 1.",
                            "i"="The length of {.arg .labels} is {length(labels)}.",
                            "i"="The length of {.arg .breaks} is {length(breaks)}.",
                            "i"="The value of {.arg .span} is {span}.",
                            "i"="The value of {.arg .inc} is {inc}.",
                            "i"="Provide {.arg .labels} of length {n} to satisfy the condition."),
                          call = call)
            }
        }
        lb <- labels
    }

    list(breaks = br, labels = lb)
}


.check_scalar_breaks <- function(breaks, call) {
    if (breaks <= 1 || !is_integerish(breaks)) {
        cli_abort(c("If {.arg .breaks} is a single value, it must be a natural number greater than 1.",
                    "i"="You've supplied {breaks}."),
                  call = call)
    }
}


.determine_crisp_breaks <- function(x, n, style, style_params, right, span, inc) {
    args <- list(var = x,
                 n = span + (n - 1) * inc,
                 style = style,
                 intervalClosure = if (right) "right" else "left")
    args <- c(args, style_params)
    ii <- do.call(classIntervals, args)

    breaks <- ii$brks
    #breaks <- seq(from = min(x, na.rm = TRUE),
                  #to = max(x, na.rm = TRUE),
                  #length.out = span + (n - 1) * inc + 1)

    c(-Inf, breaks[c(-1, -length(breaks))], Inf)
}


.explode_breaks <- function(breaks, span, inc) {
    i <- seq(from = 1, to = length(breaks) - span, by = inc)
    j <- seq(from = 1 + span, to = length(breaks), by = inc)

    lapply(seq_along(i), function(k) signif(breaks[i[k]:j[k]], 3))
}


.partition_numeric <- function(x, pp, colname, fun) {
    res <- lapply(pp$breaks, function(br) fun(x, br))
    names(res) <- paste0(colname, "=", pp$labels)

    as_tibble(res)
}


.prepare_fuzzy <- function(x, colname, breaks, labels, span, inc, call) {
    if (length(breaks) == 1) {
        .check_scalar_breaks(breaks, call)
        br <- .determine_fuzzy_breaks(x, breaks, span, inc)
    } else {
        if (length(breaks) < 3) {
            cli_abort(c("If {.arg .breaks} is non-scalar, it must be a vector with at least 3 elements.",
                        "i"="The length of {.arg .breaks} is {length(breaks)}."),
                      call = call)
        }
        n <- (length(breaks) - span - 2) / inc + 1
        req <- span + (ceiling(n) - 2) * inc
        if (!is_integerish(n) || n <= 0) {
            cli_abort(c("If {.arg .breaks} is non-scalar, the length of the vector must be equal to {.arg .span} + (n - 1) * {inc} + 2 for some natural number n.",
                        "i"="The length of {.arg .breaks} is {length(breaks)}.",
                        "i"="The value of {.arg .span} is {span}.",
                        "i"="The value of {.arg .inc} is {inc}.",
                        "i"="Provide {req - length(breaks)} more elements to {.arg .breaks} to satisfy the condition."),
                      call = call)
        }
        br <- breaks
    }

    # why span + 1: for crisp interval, the minimum consecutive breaks is 2, for fuzzy 3.
    br <- .explode_breaks(br, span + 1, inc)

    if (is.null(labels)) {
        lb <- .determine_fuzzy_labels(br)
    } else {
        if (length(labels) != length(br)) {
            if (length(breaks) == 1) {
                cli_abort(c("If {.arg .breaks} is scalar, the length of {.arg .labels} must be equal to the value of {.var .breaks}.",
                            "i"="The length of {.arg .labels} is {length(labels)}.",
                            "i"="{.arg .breaks} is {breaks}."),
                          call = call)
            } else {
                n <- (length(breaks) - span - 2) / inc + 1
                if (length(br) != n) {
                    stop("fatal in .prepare_fuzzy()")
                }
                cli_abort(c("If {.arg .breaks} is non-scalar, the length of {.arg .labels} must be equal to (length({.arg .breaks}) - {.arg .span} - 2) / {.arg .inc} + 1.",
                            "i"="The length of {.arg .labels} is {length(labels)}.",
                            "i"="The length of {.arg .breaks} is {length(breaks)}.",
                            "i"="The value of {.arg .span} is {span}.",
                            "i"="The value of {.arg .inc} is {inc}.",
                            "i"="Provide {.arg .labels} of length {n} to satisfy the condition."),
                          call = call)
            }
        }
        lb <- labels
    }

    list(breaks = br, labels = lb)
}


.determine_fuzzy_breaks <- function(x, n, span, inc) {
    breaks <- seq(from = min(x, na.rm = TRUE),
                  to = max(x, na.rm = TRUE),
                  length.out = span + (n - 1) * inc)

    c(-Inf, breaks, Inf)
}


.determine_crisp_labels <- function(breaks, right) {
    l <- sapply(breaks, function(br) br[1])
    r <- sapply(breaks, function(br) br[length(br)])
    ll <- ifelse(right, "(", "[")
    rr <- ifelse(right, "]", ")")

    paste0(ll, l, ";", r, rr)
}


.determine_fuzzy_labels <- function(breaks) {
    l <- sapply(breaks, function(br) br[1])
    c1 <- sapply(breaks, function(br) br[2])
    c2 <- sapply(breaks, function(br) br[length(br) - 1])
    r <- sapply(breaks, function(br) br[length(br)])

    if (all(c1 == c2)) {
        res <- paste0("(", l, ";", c1, ";", r, ")")
    } else {
        res <- paste0("(", l, ";", c1, ";", c2, ";", r, ")")
    }

    res
}


.sanitize_predicate_name <- function(x) {
    gsub("[,={}]+", "_", x)
}
