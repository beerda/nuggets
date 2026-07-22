#######################################################################
# nuggets: An R framework for exploration of patterns in data
# Copyright (C) 2025 Michal Burda
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program. If not, see <https://www.gnu.org/licenses/>.
#######################################################################


#' @title Convert data-frame columns into Boolean or fuzzy predicates
#'
#' @description
#' Transform selected columns of a data frame into Boolean predicates
#' (logical indicator columns) or fuzzy predicates (numeric membership degrees
#' between 0 and 1), while leaving all unselected columns unchanged.
#'
#' The function is a general-purpose transformation utility, but it is
#' primarily intended as a preprocessing step for predicate-based pattern
#' discovery with [dig()] and related functions such as
#' [dig_correlations()], [dig_paired_baseline_contrasts()],
#' and [dig_associations()].
#'
#' Depending on the type of each selected column, `partition()` creates one or
#' more derived columns:
#' - **logical** columns become predicates for `TRUE` and `FALSE`;
#' - **factor** columns become predicates for selected subsets of levels;
#' - **numeric** columns are transformed according to `.method` into dummy,
#'   crisp, or fuzzy predicates.
#'
#' The selectors supplied in `.what` and `...` are combined using standard
#' tidyselect rules. Duplicate selections are removed by the selection
#' mechanism. Selection may be empty; in that case, `.data` is returned
#' unchanged as a tibble.
#'
#' Generated columns are appended after the retained original columns.
#' By default, the original selected columns are removed (`.keep = FALSE`);
#' unselected columns are always preserved.
#'
#' Predicate names are sanitized to make them suitable as column names.
#' Sanitization is applied to original column names and to individual factor
#' level names.
#'
#' @details
#' `partition()` converts selected variables into a predicate representation
#' useful for searching for relationships, associations, and other patterns.
#'
#' For logical and factor inputs, the result consists of logical columns.
#' For numeric inputs, the result depends on `.method`:
#' - `"dummy"` creates logical predicates for observed numeric values treated
#'   as ordered categories;
#' - `"crisp"` creates logical interval predicates;
#' - `"triangle"` and `"raisedcos"` create numeric membership degrees in
#'   \eqn{[0,1]}.
#'
#' Missing values do not belong to ordinary generated predicates. If `.na = TRUE`
#' and a transformed source column contains at least one missing value, an
#' additional logical predicate `x=NA` is added.
#'
#' For numeric inputs other than `.method = "dummy"`, `.breaks` must be
#' supplied. If it is a numeric vector, it is sorted automatically.
#'
#' @section Logical columns:
#'
#' A logical column `x` is expanded into two logical predicates:
#' - `x=T` for rows where `x` is `TRUE`;
#' - `x=F` for rows where `x` is `FALSE`.
#'
#' Missing values are excluded from both predicates. If `.na = TRUE` and the
#' column contains missing values, `x=NA` is added.
#'
#' For logical columns, `.breaks`, `.labels`, `.method`, `.style`,
#' `.style_params`, `.subsets`, `.right`, `.span`, and `.inc` are ignored.
#'
#' @section Factor columns:
#'
#' A factor column is expanded into logical predicates representing subsets of
#' its levels. The subset sizes are controlled by `.subsets`.
#'
#' For an **unordered** factor, all subsets of the requested sizes are created.
#' For an **ordered** factor, only subsets formed by consecutive levels are
#' created.
#'
#' For example, if `x` has levels `a`, `b`, `c`, `d`:
#' - `.subsets = 1` creates predicates for `a`, `b`, `c`, and `d`;
#' - `.subsets = 2` creates all pairs if `x` is unordered;
#' - `.subsets = 2` creates only `a,b`, `b,c`, `c,d` if `x` is ordered.
#'
#' Subset sizes equal to the total number of levels are rejected, because they
#' would produce a predicate that is always `TRUE` for all non-missing values.
#'
#' If `.na = TRUE` and the factor contains missing values, `x=NA` is added.
#'
#' For factor columns, `.breaks`, `.labels`, `.method`, `.style`,
#' `.style_params`, `.right`, `.span`, and `.inc` are ignored.
#'
#' @section Numeric columns with `.method = "dummy"`:
#'
#' A numeric column is treated as an ordered categorical variable with one
#' category for each observed value, and is then partitioned like an ordered
#' factor.
#'
#' Thus, `.subsets = 1` creates predicates for individual values, `.subsets = 2`
#' creates predicates for consecutive pairs of values, and so on.
#'
#' This method can generate many predicates when the column has many distinct
#' values.
#'
#' If `.na = TRUE` and the column contains missing values, `x=NA` is added.
#'
#' For numeric columns with `.method = "dummy"`, `.breaks`, `.labels`,
#' `.style`, `.style_params`, `.right`, `.span`, and `.inc` are ignored.
#'
#' @section Crisp transformation of numeric data:
#'
#' For `.method = "crisp"`, a numeric column is transformed into logical
#' predicates representing intervals.
#'
#' If `.breaks` is a single integer, it specifies the number of output
#' intervals. Breakpoints are computed automatically according to `.style`
#' and `.style_params`, and the outermost intervals are extended to `-Inf`
#' and `Inf`.
#'
#' If `.breaks` is a numeric vector, it directly specifies the sequence of
#' break boundaries used to construct the interval predicates.
#'
#' Supported values of `.style` correspond to methods in
#' [classInt::classIntervals()]:
#'
#' - `"equal"` – equal-width intervals across the column range (default);
#' - `"quantile"` – equal-frequency intervals (see [quantile()] for additional
#'    parameters that may be passed through `.style_params`; note that
#'    the probs parameter is set automatically and should not be included in
#'    `.style_params`);
#' - `"kmeans"` – intervals found by 1D k-means clustering (see [kmeans()]
#'   for additional parameters);
#' - `"sd"` – intervals based on standard deviations from the mean;
#' - `"hclust"` – hierarchical clustering intervals (see [hclust()] for
#'    additional parameters);
#' - `"bclust"` – model-based clustering intervals (see [e1071::bclust()] for
#'    additional parameters);
#' - `"fisher"` / `"jenks"` – Fisher–Jenks optimal partitioning;
#' - `"dpih"` – kernel-based density partitioning (see [KernSmooth::dpih()]
#'    for additional parameters);
#' - `"headtails"` – head/tails natural breaks;
#' - `"maximum"` – maximization-based partitioning;
#' - `"box"` – breaks at boxplot hinges.
#'
#' Additional parameters for these methods can be passed through
#' `.style_params`, which should be a named list of arguments accepted by the
#' respective algorithm in [classInt::classIntervals()]. For example, when
#' `.style = "kmeans"`, one can specify
#' `.style_params = list(algorithm = "Lloyd")` to request Lloyd's algorithm
#' for k-means clustering.
#'
#' The argument `.right` controls interval closure:
#' - if `TRUE`, intervals are left-open and right-closed, e.g. \eqn{(1;3]};
#' - if `FALSE`, intervals are left-closed and right-open, e.g. \eqn{[1;3)}.
#'
#' The argument `.span` controls how many consecutive elementary intervals are
#' merged into each predicate. The argument `.inc` controls by how many break
#' positions the construction window is shifted between successive predicates.
#'
#' With `.span = 1` and `.inc = 1`, the resulting intervals are consecutive and
#' non-overlapping. Larger `.span` values produce wider, overlapping intervals;
#' larger `.inc` values skip some possible windows.
#'
#' @section Fuzzy transformation of numeric data:
#'
#' For `.method = "triangle"` or `.method = "raisedcos"`, a numeric column is
#' transformed into fuzzy predicates represented by membership degrees in
#' \eqn{[0,1]}.
#'
#' If `.breaks` is a single integer, it specifies the number of fuzzy sets.
#' If `.breaks` is a numeric vector, it specifies the sequence of boundary
#' points from which fuzzy predicates are constructed.
#'
#' The argument `.span` controls shape:
#' - with `.span = 1`, predicates are triangular (`"triangle"`) or
#'   raised-cosine (`"raisedcos"`);
#' - with `.span > 1`, predicates are trapezoidal, with a rising edge,
#'   a plateau, and a falling edge.
#'
#' The argument `.inc` controls by how many break positions the construction
#' window is shifted between successive predicates.
#'
#' The method `"triangle"` uses linear slopes; `"raisedcos"` uses
#' cosine-smoothed slopes.
#'
#' If `.breaks` includes `-Inf` or `Inf`, the corresponding boundary predicates
#' become open-ended.
#'
#' @param .data A data frame to be transformed.
#' @param .what A tidyselect expression selecting columns to transform.
#' @param ... Additional tidyselect expressions selecting more columns.
#'   All selectors from `.what` and `...` are combined using standard
#'   tidyselect behavior.
#' @param .breaks For numeric columns with `.method = "crisp"`,
#'   `"triangle"`, or `"raisedcos"`, either:
#'   - a single integer, interpreted as the number of output intervals
#'     (`"crisp"`) or fuzzy sets (`"triangle"`, `"raisedcos"`), or
#'   - a numeric vector of breakpoints.
#'
#'   Ignored for logical columns, factor columns, and numeric columns with
#'   `.method = "dummy"`. If `.method != "dummy"` for a numeric column and
#'   `.breaks` is `NULL`, an error is raised.
#' @param .labels Optional character vector used to name numeric interval or
#'   fuzzy predicates. If `NULL`, labels are generated automatically.
#'
#'   Used only for numeric columns with `.method = "crisp"`, `"triangle"`,
#'   or `"raisedcos"`. Ignored otherwise.
#' @param .na If `TRUE`, add a logical predicate `x=NA` for each transformed
#'   source column that contains at least one missing value.
#' @param .keep If `TRUE`, keep the original selected columns in the output.
#'   If `FALSE`, remove them after transformation. Unselected columns are
#'   always preserved.
#' @param .method Transformation method for selected numeric columns:
#'   - `"dummy"` – treat numeric values as ordered categories and create
#'     logical predicates;
#'   - `"crisp"` – create logical interval predicates;
#'   - `"triangle"` – create fuzzy predicates with linear slopes;
#'   - `"raisedcos"` – create fuzzy predicates with cosine-smoothed slopes.
#'
#'   Ignored for logical and factor columns.
#' @param .style Method used to compute breakpoints when `.method = "crisp"`
#'   and `.breaks` is a single integer. Supported values correspond to methods
#'   in [classInt::classIntervals()], e.g., `"equal"`, `"quantile"`, `"kmeans"`,
#'   `"sd"`, `"hclust"`, `"bclust"`, `"fisher"`, `"jenks"`, `"dpih"`,
#'   `"headtails"`, `"maximum"`, `"box"`.  Defaults to `"equal"`.
#'
#'   Ignored for logical columns, factor columns, numeric columns with
#'   `.method = "dummy"`, and numeric columns where `.breaks` is a vector.
#' @param .style_params A named list of additional parameters passed to the
#'   breakpoint computation method specified by `.style`.
#'
#'   Used only when `.method = "crisp"` and `.breaks` is a single integer.
#' @param .subsets For factor columns, and for numeric columns with
#'   `.method = "dummy"`, an integer vector specifying the sizes of level
#'   subsets for which predicates should be created.
#'
#'   For unordered factors, all subsets of the requested sizes are created.
#'   For ordered factors, and for numeric columns with `.method = "dummy"`,
#'   only subsets of consecutive values are created.
#'
#'   Subset sizes equal to the total number of available levels are rejected,
#'   because they would produce a predicate that is always `TRUE` for all
#'   non-missing values.
#'
#'   Ignored for logical columns and for numeric columns with `.method =
#'   "crisp"`, `"triangle"`, or `"raisedcos"`.
#' @param .right For numeric columns with `.method = "crisp"`, whether
#'   intervals are right-closed and left-open (`TRUE`) or left-closed and
#'   right-open (`FALSE`). Ignored otherwise.
#' @param .span For numeric columns:
#'   - with `.method = "crisp"`, the number of consecutive elementary
#'     intervals merged into one predicate;
#'   - with `.method = "triangle"` or `"raisedcos"`, controls whether fuzzy
#'     predicates are triangular (`.span = 1`) or trapezoidal (`.span > 1`).
#'
#'   Ignored for logical columns, factor columns, and numeric columns with
#'   `.method = "dummy"`.
#' @param .inc For numeric columns with `.method = "crisp"`, `"triangle"`, or
#'   `"raisedcos"`, the number of break positions by which the construction
#'   window is shifted between successive predicates.
#'
#'   Ignored for logical columns, factor columns, and numeric columns with
#'   `.method = "dummy"`.
#'
#' @return
#' A tibble in which selected columns have been replaced or supplemented by
#' generated Boolean or fuzzy predicates.
#'
#' If `.keep = FALSE`, the original selected columns are removed. If
#' `.keep = TRUE`, they are retained. Unselected columns are always preserved.
#' Generated predicate columns are appended after the retained original columns.
#'
#' @author Michal Burda
#'
#' @examples
#' # Logical column -> predicates for TRUE and FALSE
#' x <- tibble::tibble(a = c(TRUE, FALSE, NA, TRUE))
#' partition(x, a)
#'
#' # Factor column -> predicates for individual levels
#' x <- tibble::tibble(a = factor(c("low", "medium", "high", NA)))
#' partition(x, a)
#'
#' # Unordered factor -> predicates for all pairs of levels
#' x <- tibble::tibble(a = factor(c("a", "b", "c", "a")))
#' partition(x, a, .subsets = 2)
#'
#' # Ordered factor -> only consecutive subsets are created
#' x <- tibble::tibble(a = ordered(c("low", "medium", "high", "medium"),
#'                                 levels = c("low", "medium", "high")))
#' partition(x, a, .subsets = 2)
#'
#' # Keep original selected columns
#' partition(CO2, Plant, .keep = TRUE)
#'
#' # Suppress explicit NA predicate
#' x <- tibble::tibble(a = c(TRUE, FALSE, NA))
#' partition(x, a, .na = FALSE)
#'
#' # Numeric data treated as ordered categories
#' x <- tibble::tibble(a = c(1, 2, 2, 3, 4))
#' partition(x, a, .method = "dummy")
#'
#' # Numeric data treated as ordered categories with consecutive pairs
#' partition(x, a, .method = "dummy", .subsets = 2)
#'
#' # Crisp transformation using equal-width bins
#' partition(CO2, conc, .method = "crisp", .breaks = 4)
#'
#' # Crisp transformation using quantile-based bins
#' partition(CO2, conc, .method = "crisp", .breaks = 4, .style = "quantile")
#'
#' # Crisp transformation using k-means clustering for breakpoints
#' partition(CO2, conc, .method = "crisp", .breaks = 4, .style = "kmeans")
#'
#' # Crisp transformation using Lloyd algorithm for k-means breakpoints
#' partition(CO2, conc, .method = "crisp", .breaks = 4, .style = "kmeans",
#'           .style_params = list(algorithm = "Lloyd"))
#'
#' # Crisp transformation with manually specified breaks
#' partition(CO2, conc, .method = "crisp",
#'           .breaks = c(-Inf, 200, 500, 800, Inf))
#'
#' # Crisp transformation with overlapping intervals
#' partition(CO2, conc, .method = "crisp",
#'           .breaks = c(1, 3, 5, 7, 9, 11),
#'           .span = 2, .inc = 1)
#'
#' # Crisp transformation with left-closed, right-open intervals
#' partition(CO2, conc, .method = "crisp", .breaks = 4, .right = FALSE)
#'
#' # Fuzzy triangular transformation
#' partition(CO2, conc:uptake, .method = "triangle", .breaks = 3)
#'
#' # Raised-cosine fuzzy predicates
#' partition(CO2, conc:uptake, .method = "raisedcos", .breaks = 3)
#'
#' # Trapezoidal fuzzy predicates
#' partition(CO2, conc:uptake, .method = "triangle", .breaks = 3, .span = 2)
#'
#' # Overlapping trapezoidal fuzzy predicates (Ruspini condition)
#' partition(CO2, conc:uptake, .method = "triangle", .breaks = 3,
#'           .span = 2, .inc = 2)
#'
#' # Fuzzy transformation with manually specified breaks
#' partition(CO2, uptake,
#'           .method = "triangle",
#'           .breaks = c(-Inf, 7.7, 28.3, 45.5, Inf))
#'
#' # Fuzzy transformation with custom labels
#' partition(CO2, uptake,
#'           .method = "triangle",
#'           .breaks = c(-Inf, 7.7, 28.3, 45.5, Inf),
#'           .labels = c("low", "medium", "high"))
#'
#' # Different settings can be applied in successive calls
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
                      .subsets = 1,
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

    .must_be_integerish_vector(.subsets)
    .must_not_be_empty(.subsets)
    .must_be_greater_eq(.subsets, 1)

    .must_be_flag(.right)

    .must_be_integerish_scalar(.span)
    .must_be_greater_eq(.span, 1)

    .must_be_integerish_scalar(.inc)
    .must_be_greater_eq(.inc, 1)

    if (.style != "equal" && .method != "crisp") {
        cli_abort(c("The {.arg .style} argument is only applicable when {.arg .method} is {.val crisp}.",
                    "i" = "You've supplied {.arg .style} = {.val { .style}} and {.arg .method} = {.val { .method}}."),
                  call = current_env())
    }

    .subsets <- sort(unique(as.integer(.subsets)))
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
            cli_abort(c("Unable to partition column {.field {colname}} because it contains only NA values.",
                       "i"="Column selected for partitioning must contain some non-NA values.",
                       "x"="Column {.field {colname}} is empty or all values are NA."),
                      call = call)

        } else if (any(is.infinite(x))) {
            positions <- which(is.infinite(x))
            cli_abort(c("Unable to partition column {.field {colname}} because it contains infinite values.",
                       "i"="Column selected for partitioning must not contain infinite values.",
                       "x"="Column {.field {colname}} contains {.val {length(positions)}} infinite value{?s} at position{?s}: {paste(positions, collapse = ', ')}."),
                      call = call)

        } else if (is.logical(x)) {
            res <- tibble(a = !is.na(x) & x,
                          b = !is.na(x) & !x)
            colnames(res) <- paste0(colname, "=", c("T", "F"))

        } else if (is.factor(x)) {
            res <- .partition_factor(x, colname, .subsets)

        } else if (is.numeric(x)) {
            if (.method == "dummy") {
                res <- .partition_factor(as.ordered(x), colname, .subsets)

            } else if (is.null(.breaks)) {
                cli_abort(c("{.arg .breaks} must not be NULL in order to partition numeric column {.field {colname}}."),
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
                f1 <- if (.method == "triangle") triangle_ else raisedcos_
                f2 <- function(x, br) {
                    res <- f1(x, br)
                    res[is.na(res)] <- 0
                    res
                }
                res <- .partition_numeric(x, pp, colname, f2)
            }

        } else {
            cli_abort(c("Unable to partition column {.field {colname}}.",
                       "i"="Column selected for partitioning must be a factor, logical, or numeric.",
                       "x"="The column {.field {colname}} is a {.cls {class(x)}}."),
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


.generate_seq <- function(len, m, FUN) {
    starts <- seq(from = 1, to = len - m + 1)
    lapply(starts, function(i) FUN(i:(i + m - 1)))
}


.generate_comb <- function(len, m, FUN) {
    combn(x = len, m = m, FUN = FUN, simplify = FALSE)
}


.partition_factor <- function(x, colname, subsets) {
    items <- lapply(levels(x), function(lev) !is.na(x) & x == lev)
    names(items) <- .sanitize_predicate_name(levels(x))

    inner_fun <- function(i) {
        r <- list(Reduce(`|`, items[i]))
        names(r) <- paste0(names(items)[i], collapse = ",")

        r
    }

    fun <- if (is.ordered(x)) .generate_seq else .generate_comb
    res <- list()
    for (s in subsets) {
        if (s >= length(items)) {
            cli_abort(c("Subset size {.val {s}} defined by {.arg .subsets} is too large for column {.field {colname}}.",
                       "i"="Column {.field {colname}} has only {.val {length(items)}} level{?s}.",
                       "i"="Maximum subset size for this column is {.val {length(items) - 1}}."),
                      call = current_env())
        }
        new_comb <- fun(length(items), s, inner_fun)
        new_comb <- do.call(c, new_comb)
        res <- c(res, new_comb)
    }

    names(res) <- paste0(colname, "=", names(res))

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
            cli_abort(c("If {.arg .breaks} is non-scalar, the length of the vector must be equal to {.arg .span} + (n - 1) * {.val {inc}} + 1 for some natural number n.",
                        "i"="The length of {.arg .breaks} is {.val {length(breaks)}}.",
                        "i"="The value of {.arg .span} is {.val {span}}.",
                        "i"="The value of {.arg .inc} is {.val {inc}}.",
                        "i"="Provide {.val {req - length(breaks)}} more elements to {.arg .breaks} to satisfy the condition."),
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
                            "i"="The length of {.arg .labels} is {.val {length(labels)}}.",
                            "i"="{.arg .breaks} is scalar value {.val {breaks}}."),
                          call = call)
            } else {
                n <- (length(breaks) - span - 1) / inc + 1
                if (length(br) != n) {
                    stop("fatal in .prepare_crisp()")
                }
                cli_abort(c("If {.arg .breaks} is non-scalar, the length of {.arg .labels} must be equal to 1 + (length({.arg .breaks}) - {.arg .span} - 1) / {.arg .inc}.",
                            "i"="The length of {.arg .labels} is {.val {length(labels)}}.",
                            "i"="The length of {.arg .breaks} is {.val {length(breaks)}}.",
                            "i"="The value of {.arg .span} is {.val {span}}.",
                            "i"="The value of {.arg .inc} is {.val {inc}}.",
                            "i"="Provide {.arg .labels} of length {.val {n}} to satisfy the condition."),
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
                    "i"="You've supplied {.val {breaks}}."),
                  call = call)
    }
}


.determine_crisp_breaks <- function(x, n, style, style_params, right, span, inc) {
    args <- list(var = na.omit(x),
                 n = span + (n - 1) * inc,
                 style = style,
                 intervalClosure = if (right) "right" else "left",
                 warnSmallN = FALSE)
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
                        "i"="The length of {.arg .breaks} is {.val {length(breaks)}}."),
                      call = call)
        }
        n <- (length(breaks) - span - 2) / inc + 1
        req <- span + (ceiling(n) - 2) * inc
        if (!is_integerish(n) || n <= 0) {
            cli_abort(c("If {.arg .breaks} is non-scalar, the length of the vector must be equal to {.arg .span} + (n - 1) * {.val {inc}} + 2 for some natural number n.",
                        "i"="The length of {.arg .breaks} is {.val {length(breaks)}}.",
                        "i"="The value of {.arg .span} is {.val {span}}.",
                        "i"="The value of {.arg .inc} is {.val {inc}}.",
                        "i"="Provide {.val {req - length(breaks)}} more elements to {.arg .breaks} to satisfy the condition."),
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
                cli_abort(c("If {.arg .breaks} is scalar, the length of {.arg .labels} must be equal to the value of {.arg .breaks}.",
                            "i"="The length of {.arg .labels} is {.val {length(labels)}}.",
                            "i"="{.arg .breaks} is {.val {breaks}}."),
                          call = call)
            } else {
                n <- (length(breaks) - span - 2) / inc + 1
                if (length(br) != n) {
                    stop("fatal in .prepare_fuzzy()")
                }
                cli_abort(c("If {.arg .breaks} is non-scalar, the length of {.arg .labels} must be equal to (length({.arg .breaks}) - {.arg .span} - 2) / {.arg .inc} + 1.",
                            "i"="The length of {.arg .labels} is {.val {length(labels)}}.",
                            "i"="The length of {.arg .breaks} is {.val {length(breaks)}}.",
                            "i"="The value of {.arg .span} is {.val {span}}.",
                            "i"="The value of {.arg .inc} is {.val {inc}}.",
                            "i"="Provide {.arg .labels} of length {.val {n}} to satisfy the condition."),
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
