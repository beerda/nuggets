#' Convert columns of data frame to Boolean or fuzzy sets (of triangular,
#' trapezoidal, or raised-cosinal shape)
#'
#' Convert the selected columns of the data frame into either dummy
#' logical columns, or into membership degrees of fuzzy sets, while leaving
#' the remaining columns untouched. Each column selected for transformation
#' typically results in multiple columns in the output.
#'
#' Transformations performed by this function are typically useful as a
#' preprocessing step before using the [dig()] function or some of its
#' derivatives ([dig_correlations()], [dig_paired_baseline_contrasts()],
#' [dig_associations()]).
#'
#' The transformation of selected columns differ based on the type. Concretely:
#' - **logical** column `x` is transformed into pair of logical columns,
#'   `x=TRUE` and`x=FALSE`;
#' - **factor** column `x`, which has levels `l1`, `l2`, and `l3`, is transformed
#'   into three logical columns named `x=l1`, `x=l2`, and `x=l3`;
#' - **numeric** column`x` is transformed accordingly to `.method` argument:
#'   - if `.method="crisp"`, the column is first transformed into a factor
#'     with intervals as factor levels and then it is processed as a factor
#'     (see above);
#'   - for other `.method` (`triangle` or `raisedcos`), several new columns
#'     are created, where each column has numeric values from the interval
#'     \eqn{[0,1]} and represents a certain fuzzy set (either triangular or
#'     raised-cosinal).
#'   Details of transformation of numeric columns can be specified with
#'   additional arguments (`.breaks`, `.labels`, `.right`).
#'
#' The processing of source **numeric** columns is quite complex and depends
#' on the following arguments: `.method`, `.breaks`, `.right`, `.span`, and
#' `.inc`.
#'
#' @section Crisp transformation of numeric data:
#'
#' For `.method = "crisp"`, the numeric column is transformed into a set of
#' logical columns where each column represents a certain interval of values.
#' The intervals are determined by the `.breaks` argument.
#'
#' If `.breaks` is an integer scalar, it specifies the number of resulting
#' intervals to break the numeric column to. The intervals are obtained
#' automatically from the source column by splitting the range of the source
#' values into `.breaks` intervals of equal length. The first and the last
#' interval are defined from the minimum infinity to the first break and from
#' the last break to the maximum infinity, respectively.
#'
#' If `.breaks` is a vector, the values specify the manual borders of intervals.
#' (Infinite values are allowed.)
#'
#' For `.span = 1` and `.inc = 1`, the intervals are consecutive and
#' non-overlapping. If `.breaks = c(1, 3, 5, 7, 9, 11)` and `.right = TRUE`,
#' for example, the following intervals are considered: \eqn{(1;3]}, \eqn{(3;5]},
#' \eqn{(5;7]}, \eqn{(7;9]}, and \eqn{(9;11]}. (If `.right = FALSE`, the intervals are:
#' \eqn{[1;3)}, \eqn{[3;5)}, \eqn{[5;7)}, \eqn{[7;9)}, and \eqn{[9;11)}.)
#'
#' For `.span` > 1, the intervals overlap in `.span` breaks. For
#' `.span = 2`, `.inc = 1`, and `.right = TRUE`, the intervals are: \eqn{(1;5]},
#' \eqn{(3;7]}, \eqn{(5;9]}, and \eqn{(7;11]}.
#'
#' As can be seen, so far the next interval was created by shifting in 1
#' position in `.breaks`. The `.inc` argument modifies that shift. If `.inc = 2`
#' and `.span = 1`, the intervals are: \eqn{(1;3]}, \eqn{(5;7]}, and \eqn{(9;11]}.
#' For `.span = 2` and `.inc = 3`, the intervals are: \eqn{(1;5]}, and \eqn{(9;11]}.
#'
#'
#' @section Fuzzy transformation of numeric data:
#'
#' For `.method = "triangle"` or `.method = "raisedcos"`, the numeric column is
#' transformed into a set of columns where each column represents membership
#' degrees to a certain fuzzy set. The shape of the underlying fuzzy sets
#' is again determined by the `.breaks` argument.
#'
#' If `.breaks` is an integer scalar, it specifies the number of target fuzzy
#' sets. The breaks are determined automatically from the source data column
#' similarly as in the crisp transformation described above.
#'
#' If `.breaks` is a vector, the values specify the breaking points of fuzzy sets.
#' Infinite values as breaks produce fuzzy sets with open borders.
#'
#' For `.span = 1`, each underlying fuzzy set is determined by three consecutive
#' breaks. Outside of these breaks, the membership degree is 0. In the interval
#' between the first two breaks, the membership degree is increasing and
#' in the interval between the last two breaks, the membership degree is
#' decreasing. Hence the membership degree 1 is obtained for values equal to
#' the middle break. This practically forms fuzzy sets of triangular or
#' raised-cosinal shape.
#'
#' For `.span` > 1, the fuzzy set is determined by four breaks. Outside of
#' these breaks, the membership degree is 0. In the interval between the first
#' and the second break, the membership degree is increasing, in the interval
#' between the third and the fourth break, the membership degree is decreasing,
#' and in the interval between the second and the third break, the membership
#' degree is 1. This practically forms fuzzy sets of trapezoidal shape.
#'
#' Similar to the crisp transformation, the `.inc` argument determines the
#' shift of breaks when creating the next underlying fuzzy set.
#'
#' Let `.breaks = c(1, 3, 5, 7, 9, 11)`. For `.span = 1` and `.inc = 1`, the
#' fuzzy sets are determined by the following triplets having effectively the
#' triangular or raised-cosinal shape: \eqn{(1;3;5)},
#' \eqn{(3;5;7)}, \eqn{(5;7;9)}, and \eqn{(7;9;11)}.
#'
#' For `.span = 2` and `.inc = 1`, the fuzzy sets are determined by the following
#' quadruplets: \eqn{(1;3;5;7)}, \eqn{(3;5;7;9)}, and \eqn{(5;7;9;11)}. These
#' fuzzy sets have the trapezoidal shape with linear (if `.method = "triangle"`)
#' or cosine (if `.method = "raisedcos"`) increasing and decreasing border-parts.
#'
#' For `.span = 1` and `.inc = 3`, the fuzzy sets are determined by the following
#' triplets: \eqn{(1;3;5)}, and \eqn{(7;9;11)} while skipping 2nd and 3rd fuzzy
#' sets.
#'
#' See the examples for more details.
#'
#' @param .data the data frame to be processed
#' @param .what a tidyselect expression (see
#'      [tidyselect syntax](https://tidyselect.r-lib.org/articles/syntax.html))
#'      specifying the columns to be transformed
#' @param ... optional other tidyselect expressions selecting additional
#'      columns to be processed
#' @param .breaks for numeric columns, this has to be either an integer scalar
#'      or a numeric vector. If `.breaks` is an integer scalar, it specifies
#'      the number of resulting intervals to break the numeric column to
#'      (for `.method="crisp"`) or the number of target fuzzy sets (for
#'      `.method="triangle"` or `.method="raisedcos`). If `.breaks` is a vector,
#'      the values specify the borders of intervals (for `.method="crisp"`)
#'      or the breaking points of fuzzy sets.
#' @param .labels character vector specifying the names used to construct
#'      the newly created column names. If `NULL`, the labels are generated
#'      automatically.
#' @param .na if `TRUE`, an additional logical column is created for each
#'      source column that contains `NA` values. For column named `x`, the
#'      newly created column's name will be `x=NA`.
#' @param .keep if `TRUE`, the original columns being transformed remain
#'      present in the resulting data frame.
#' @param .method The method of transformation for numeric columns. Either
#'      `"crisp"`, `"triangle"`, or `"raisedcos"` is required.
#' @param .right If `.method="crisp"`, this argument specifies if the
#'      intervals should be closed on the right (and open on the left) or
#'      vice versa.
#' @param .span The span of the intervals for numeric columns. If `.method="crisp"`,
#'      this argument specifies the number of consecutive breaks in a single
#'      resulting interval. If `.method="triangle"` or `.method="raisedcos"`,
#'      this argument specifies the number of breaks that should form the
#'      core of the fuzzy set, (i.e. where the membership degrees are 1). For
#'      `.span = 1`, the fuzzy set has a triangular shape with only a single
#'      value with membership equal to 1, for `.span = 2`, the fuzzy set has
#'      a trapezoidal shape.
#' @param .inc how many breaks to move on to the right when creating the next
#'      column from a numeric column in `x`. In other words, if `.inc = 1`,
#'      all resulting columns are created (by shifting breaks by 1), if
#'      `.inc = 2`, the first, third, fifth, etc. columns are created, i.e.,
#'      every second resulting column is skipped.
#' @return A tibble created by transforming `.data`.
#' @author Michal Burda
#' @examples
#' # transform logical columns and factors
#' d <- data.frame(a = c(TRUE, TRUE, FALSE),
#'                 b = factor(c("A", "B", "A")),
#'                 c = c(1, 2, 3))
#' partition(d, a, b)
#'
#' # transform numeric columns to logical columns (crisp transformation)
#' partition(CO2, conc:uptake, .method = "crisp", .breaks = 3)
#'
#' # transform numeric columns to triangular fuzzy sets:
#' partition(CO2, conc:uptake, .method = "triangle", .breaks = 3)
#'
#' # transform numeric columns to raised-cosinal fuzzy sets
#' partition(CO2, conc:uptake, .method = "raisedcos", .breaks = 3)
#'
#' # transform numeric columns to trapezoidal fuzzy sets overlapping in non-core
#' # regions so that the membership degrees sum to 1 along the consecutive fuzzy sets
#' # (i.e., the so-called Ruspini condition is met)
#' partition(CO2, conc:uptake, .method = "triangle", .breaks = 3, .span = 2, .inc = 2)
#'
#' # complex transformation with different settings for each column
#' CO2 |>
#'     partition(Plant:Treatment) |>
#'     partition(conc,
#'               .method = "raisedcos",
#'               .breaks = c(-Inf, 95, 175, 350, 675, 1000, Inf)) |>
#'     partition(uptake,
#'               .method = "triangle",
#'               .breaks = c(-Inf, 7.7, 28.3, 45.5, Inf),
#'               .labels = c("low", "medium", "high"))
#' @export
partition <- function(.data,
                      .what = everything(),
                      ...,
                      .breaks = NULL,
                      .labels = NULL,
                      .na = TRUE,
                      .keep = FALSE,
                      .method = "crisp",
                      .right = TRUE,
                      .span = 1,
                      .inc = 1) {
    .must_be_data_frame(.data)
    .must_be_numeric_vector(.breaks, null = TRUE)
    .must_be_character_vector(.labels, null = TRUE)
    .must_be_flag(.na)
    .must_be_flag(.keep)
    .must_be_enum(.method, c("crisp", "triangle", "raisedcos"))
    .must_be_flag(.right)
    .must_be_integerish_scalar(.span)
    .must_be_integerish_scalar(.inc)

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

    if (length(sel) <= 0) {
        return(as_tibble(.data))
    }

    res <- lapply(seq_along(sel), function(i) {
        colname <- names(sel)[i]
        colindex <- sel[i]
        res <- emptydf
        x <- .data[[colindex]]

        if (is.logical(x)) {
            res <- tibble(a = !is.na(x) & x,
                          b = !is.na(x) & !x)
            colnames(res) <- paste0(colname, "=", c("T", "F"))

        } else if (is.factor(x)) {
            res <- .partition_factor(x, colname)

        } else if (is.numeric(x)) {
            if (is.null(.breaks)) {
                cli_abort(c("{.arg .breaks} must not be NULL in order to partition numeric column {.var {colname}}."),
                          call = call)
            }

            if (.method == "crisp") {
                pp <- .prepare_crisp(x, colname, .breaks, .labels, .right, .span, .inc, call)
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
    names(res) <- paste0(colname, "=", levels(x))

    as_tibble(res)
}


.prepare_crisp <- function(x, colname, breaks, labels, right, span, inc, call) {
    if (length(breaks) == 1) {
        .check_scalar_breaks(breaks, call)
        br <- .determine_crisp_breaks(x, breaks, span, inc)
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


.determine_crisp_breaks <- function(x, n, span, inc) {
    breaks <- seq(from = min(x, na.rm = TRUE),
                  to = max(x, na.rm = TRUE),
                  length.out = span + (n - 1) * inc + 1)

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
