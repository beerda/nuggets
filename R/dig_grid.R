#' Search for grid-based rules
#'
#' @description
#' `r lifecycle::badge("experimental")`
#'
#' This function creates a grid of combinations of pairs of columns specified
#' by `xvars` and `yvars` (see also [var_grid()]). After that, it enumerates all
#' conditions created from data in `x` (by calling [dig()]) and for each such
#' condition and for each row of the grid of combinations, a user-defined
#' function `f` is executed on each sub-data created from `x` by selecting all
#' rows of `x` that satisfy the generated condition and by selecting the
#' columns in the grid's row.
#'
#' Function is useful for searching for patterns that are based on the
#' relationships between pairs of columns, such as in [dig_correlations()].
#'
#' @param x a matrix or data frame with data to search in.
#' @param f the callback function to be executed for each generated condition.
#'      The arguments of the callback function differ based on the value of the
#'      `type` argument (see below):
#'      \itemize{
#'      \item If `type = "crisp"` (that is, boolean),
#'      the callback function `f` must accept a single argument `d` of type
#'      `data.frame` with two columns, xvar (accessible as `d[[1]]`) and yvar
#'      (accessible as `d[[2]]`). Data frame `d` is a subset of the original
#'      data frame `x` with all rows that satisfy the generated condition.
#'      \item If `type = "fuzzy"`, the callback function `f` must accept an argument
#'      `d` of type `data.frame` with two columns, xvar (`d[[1]]`) and yvar
#'      (`d[[2]]`), named as in`x`, and a numeric argument `weights`
#'      with the same length as the number of rows in `d`. The `weights`
#'      argument contains the truth degree
#'      of the generated condition for each row of `d`. The truth degree is
#'      a number in the interval \eqn{[0, 1]} that represents the degree of
#'      satisfaction of the condition in the original data row.
#'      }
#'      In all cases, the function must return a list of scalar values, which
#'      will be converted into a single row of result of final tibble.
#' @param condition a tidyselect expression (see
#'      [tidyselect syntax](https://tidyselect.r-lib.org/articles/syntax.html))
#'      specifying the columns to use as condition predicates. The selected
#'      columns must be logical or numeric. If numeric, fuzzy conditions are
#'      considered.
#' @param xvars a tidyselect expression (see
#'      [tidyselect syntax](https://tidyselect.r-lib.org/articles/syntax.html))
#'      specifying the columns of `x`, whose names will be used as a domain for
#'      combinations use at the first place (xvar)
#' @param yvars a tidyselect expression (see
#'      [tidyselect syntax](https://tidyselect.r-lib.org/articles/syntax.html))
#'      specifying the columns of `x`, whose names will be used as a domain for
#'      combinations use at the second place (yvar)
#' @param disjoint an atomic vector of size equal to the number of columns of `x`
#'      that specifies the groups of predicates: if some elements of the `disjoint`
#'      vector are equal, then the corresponding columns of `x` will NOT be
#'      present together in a single condition. If `x` is prepared with
#'      [partition()], using the [varnames()] function on `x`'s column names
#'      is a convenient way to create the `disjoint` vector.
#' @param allow a character string specifying which columns are allowed to be
#'      selected by `xvars` and `yvars` arguments. Possible values are:
#'      \itemize{
#'      \item `"all"` - all columns are allowed to be selected
#'      \item `"numeric"` - only numeric columns are allowed to be selected
#'      }
#' @param na_rm a logical value indicating whether to remove rows with missing
#'      values from sub-data before the callback function `f` is called
#' @param type a character string specifying the type of conditions to be processed.
#'      The `"crisp"` type accepts only logical columns as condition predicates.
#'      The `"fuzzy"` type accepts both logical and numeric columns as condition
#'      predicates where numeric data are in the interval \eqn{[0, 1]}. The
#'      callback function `f` differs based on the value of the `type` argument
#'      (see the description of `f` above).
#' @param min_length the minimum size (the minimum number of predicates) of the
#'      condition to be generated (must be greater or equal to 0). If 0, the empty
#'      condition is generated in the first place.
#' @param max_length the maximum size (the maximum number of predicates) of the
#'      condition to be generated. If equal to Inf, the maximum length of conditions
#'      is limited only by the number of available predicates.
#' @param min_support the minimum support of a condition to trigger the callback
#'      function for it. The support of the condition is the relative frequency
#'      of the condition in the dataset `x`. For logical data, it equals to the
#'      relative frequency of rows such that all condition predicates are TRUE on it.
#'      For numerical (double) input, the support is computed as the mean (over all
#'      rows) of multiplications of predicate values.
#' @param threads the number of threads to use for parallel computation.
#' @param error_context a list of details to be used in error messages.
#'      This argument is useful when `dig_grid()` is called from another
#'      function to provide error messages, which refer to arguments of the
#'      calling function. The list must contain the following elements:
#'      \itemize{
#'      \item `arg_x` - the name of the argument `x` as a character string
#'      \item `arg_condition` - the name of the argument `condition` as a character
#'         string
#'      \item `arg_xvars` - the name of the argument `xvars` as a character string
#'      \item `arg_yvars` - the name of the argument `yvars` as a character string
#'      \item `call` - an environment in which to evaluate the error messages.
#'      }
#' @param ... Further arguments, currently unused.
#' @return A tibble with found patterns. Each row represents a single call of
#'      the callback function `f`.
#' @author Michal Burda
#' @seealso [dig()], [var_grid()]; see also [dig_correlations()] and
#'     [dig_paired_contrasts()], as they are using this function internally.
#' @examples
#' # *** Example of crisp (boolean) patterns:
#' # dichotomize iris$Species
#' crispIris <- partition(iris, Species)
#'
#' # a simple callback function that computes mean difference of `xvar` and `yvar`
#' f <- function(d) {
#'     list(m = mean(d[[1]] - d[[2]]),
#'          n = nrow(d))
#'     }
#'
#' # call f() for each condition created from column `Species`
#' dig_grid(crispIris,
#'          f,
#'          condition = starts_with("Species"),
#'          xvars = starts_with("Sepal"),
#'          yvars = starts_with("Petal"),
#'          type = "crisp")
#'
#' # *** Example of fuzzy patterns:
#' # create fuzzy sets from Sepal columns
#' fuzzyIris <- partition(iris,
#'                        starts_with("Sepal"),
#'                        .method = "triangle",
#'                        .breaks = 3)
#'
#' # a simple callback function that computes a weighted mean of a difference of
#' # `xvar` and `yvar`
#' f <- function(d, weights) {
#'     list(m = weighted.mean(d[[1]] - d[[2]], w = weights),
#'          w = sum(weights))
#' }
#'
#' # call f() for each fuzzy condition created from column fuzzy sets whose
#' # names start with "Sepal"
#' dig_grid(fuzzyIris,
#'          f,
#'          condition = starts_with("Sepal"),
#'          xvars = Petal.Length,
#'          yvars = Petal.Width,
#'          type = "fuzzy")
#' @export
dig_grid <- function(x,
                     f,
                     condition = where(is.logical),
                     xvars = where(is.numeric),
                     yvars = where(is.numeric),
                     disjoint = varnames(colnames(x)),
                     allow = "all",
                     na_rm = FALSE,
                     type = "crisp",
                     min_length = 0L,
                     max_length = Inf,
                     min_support = 0.0,
                     threads = 1L,
                     error_context = list(arg_x = "x",
                                          arg_f = "f",
                                          arg_condition = "condition",
                                          arg_xvars = "xvars",
                                          arg_yvars = "yvars",
                                          arg_disjoint = "disjoint",
                                          arg_allow = "allow",
                                          arg_na_rm = "na_rm",
                                          arg_type = "type",
                                          arg_min_length = "min_length",
                                          arg_max_length = "max_length",
                                          arg_min_support = "min_support",
                                          arg_threads = "threads",
                                          call = current_env()),
                     ...) {
    .must_be_flag(na_rm,
                  arg = error_context$arg_na_rm,
                  call = error_context$call)
    .must_be_enum(type, c("crisp", "fuzzy"),
                  arg = error_context$arg_type,
                  call = error_context$call)

    .must_be_function(f,
                      required = if (type == "crisp") c("d") else c("d", "weights"),
                      optional = NULL,
                      arg = error_context$arg_f,
                      call = error_context$call)

    condition <- enquo(condition)

    cols <- .convert_data_to_list(x, error_context = error_context)
    .extract_cols(cols,
                  !!condition,
                  allow_numeric = (type == "fuzzy"),
                  allow_empty = TRUE,
                  error_context = list(arg_selection = error_context$arg_condition,
                                       call = error_context$call))

    xvars <- enquo(xvars)
    yvars <- enquo(yvars)
    grid <- var_grid(x,
                     !!xvars,
                     !!yvars,
                     allow = allow,
                     error_context = error_context)

    fcrisp <- function(condition, support, indices) {
        cond <- format_condition(names(condition))
        d <- x[indices, , drop = FALSE]

        result <- apply(grid, MARGIN = 1, simplify = FALSE, FUN = function(row) {
            dd <- d[, row, drop = FALSE]
            if (na_rm)
                dd <- na.omit(dd)

            f(d = dd)
        })

        isnull <- sapply(result, is.null)
        result <- lapply(result[!isnull], as_tibble)
        result <- do.call(rbind, result)
        gr <- grid[!isnull, ]

        if (!is.null(result)) {
            result <- cbind(condition = rep(cond, nrow(gr)),
                            support = support,
                            gr,
                            result)
        }

        result
    }

    ffuzzy <- function(condition, support, weights) {
        cond <- format_condition(names(condition))

        result <- apply(grid, 1, function(row) {
            dd <- x[, row, drop = FALSE]
            if (na_rm) {
                dd <- na.omit(dd)
                weights <- weights[attr(dd, "na.action")]
            }

            f(d = dd, weights = weights)
        })

        result <- lapply(result, as_tibble)
        result <- do.call(rbind, result)

        cbind(condition = rep(cond, nrow(grid)),
              support = support,
              grid,
              result)
    }

    ff <- ifelse(type == "crisp", fcrisp, ffuzzy)

    res <- dig(x = x,
               f = ff,
               condition = !!condition,
               disjoint = disjoint,
               min_length = min_length,
               max_length = max_length,
               min_support = min_support,
               threads = threads,
               error_context = list(arg_x = error_context$arg_x,
                                    arg_condition = error_context$arg_condition,
                                    arg_disjoint = error_context$arg_disjoint,
                                    arg_min_length = error_context$arg_min_length,
                                    arg_max_length = error_context$arg_max_length,
                                    arg_min_support = error_context$arg_min_support,
                                    arg_threads = error_context$arg_threads,
                                    call = error_context$call),
               ...)

    res <- do.call(rbind, res)

    as_tibble(res)
}
