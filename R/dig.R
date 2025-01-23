#' Search for patterns of custom type
#'
#' @description
#' `r lifecycle::badge("experimental")`
#'
#' A general function for searching for patterns of custom type. The function
#' allows for the selection of columns of `x` to be used as condition
#' predicates. The function enumerates all possible conditions in the form of
#' elementary conjunctions of selected predicates, and for each condition,
#' a user-defined callback function `f` is executed. The callback function is
#' intended to perform some analysis and return an object representing a pattern
#' or patterns related to the condition. [dig()] returns a list of these
#' returned objects.
#'
#' The callback function `f` may have some arguments that are listed in the
#' `f` argument description. The algorithm provides information about the
#' generated condition based on the present arguments.
#'
#' Additionally to `condition`, the function allows for the selection of
#' the so-called *focus* predicates. The focus predicates, a.k.a. *foci*, are
#' predicates that are evaluated within each condition and some additional
#' information is provided to the callback function about them.
#'
#' `dig()` allows to specify some restrictions on the generated conditions,
#' such as:
#' - the minimum and maximum length of the condition (`min_length` and
#'   `max_length` arguments).
#' - the minimum support of the condition (`min_support` argument). Support
#'   of the condition is the relative frequency of the condition in the dataset
#'   `x`.
#' - the minimum support of the focus (`min_focus_support` argument). Support
#'   of the focus is the relative frequency of rows such that all condition
#'   predicates AND the focus are TRUE on it. Foci with support lower than
#'   `min_focus_support` are filtered out.
#'
#' @param x a matrix or data frame. The matrix must be numeric (double) or logical.
#'      If `x` is a data frame then each column must be either numeric (double) or
#'      logical.
#' @param f the callback function executed for each generated condition. This
#'      function may have some of the following arguments. Based on the present
#'      arguments, the algorithm would provide information about the generated
#'      condition:
#'      \itemize{
#'      \item `condition` - a named integer vector of column indices that represent
#'        the predicates of the condition. Names of the vector correspond to
#'        column names;
#'      \item `support` - a numeric scalar value of the current condition's support;
#'      \item `indices` - a logical vector indicating the rows satisfying the condition;
#'      \item `weights` - (similar to indices) weights of rows to which they satisfy
#'        the current condition;
#'      \item `pp` - a value of a contingency table, `condition & focus`.
#'        `pp` is a named numeric vector where each value is a support of conjunction
#'        of the condition with a foci column (see the `focus` argument to specify,
#'        which columns). Names of the vector are foci column names.
#'      \item `pn` - a value of a contingency table, `condition & neg focus`.
#'        `pn` is a named numeric vector where each value is a support of conjunction
#'        of the condition with a negated foci column (see the `focus` argument to
#'        specify, which columns are foci) - names of the vector are foci column names.
#'      \item `np` - a value of a contingency table, `neg condition & focus`.
#'        `np` is a named numeric vector where each value is a support of conjunction
#'        of the negated condition with a foci column (see the `focus` argument to
#'        specify, which columns are foci) - names of the vector are foci column names.
#'      \item `nn` - a value of a contingency table, `neg condition & neg focus`.
#'        `nn` is a named numeric vector where each value is a support of conjunction
#'        of the negated condition with a negated foci column (see the `focus`
#'        argument to specify, which columns are foci) - names of the vector are foci
#'        column names.
#'      \item `foci_supports` - (deprecated, use `pp` instead)
#'        a named numeric vector of supports of foci columns
#'        (see `focus` argument to specify, which columns are foci) - names of the
#'        vector are foci column names.
#'      }
#' @param condition a tidyselect expression (see
#'      [tidyselect syntax](https://tidyselect.r-lib.org/articles/syntax.html))
#'      specifying the columns to use as condition predicates
#' @param focus a tidyselect expression (see
#'      [tidyselect syntax](https://tidyselect.r-lib.org/articles/syntax.html))
#'      specifying the columns to use as focus predicates
#' @param disjoint an atomic vector of size equal to the number of columns of `x`
#'      that specifies the groups of predicates: if some elements of the `disjoint`
#'      vector are equal, then the corresponding columns of `x` will NOT be
#'      present together in a single condition. If `x` is prepared with
#'      [partition()], using the [var_names()] function on `x`'s column names
#'      is a convenient way to create the `disjoint` vector.
#' @param excluded NULL or a list of character vectors, where each character vector
#'      contains the names of columns that must not appear together in a single
#'      condition.
#' @param min_length the minimum size (the minimum number of predicates) of the
#'      condition to trigger the callback function `f`. The value of this argument must be
#'      greater or equal to 0. If 0, also the empty condition triggers the callback.
#' @param max_length The maximum allowed size (the maximum number of predicates)
#'      of the condition. Conditions longer than `max_length` are not generated.
#'      If equal to Inf, the maximum length of conditions is limited only by the
#'      number of available predicates. The value of this argument must be greater
#'      or equal to 0 and also greater or equal to `min_length`. This argument
#'      effectively affects the speed of the search process and the number of
#'      triggered calls of the callback function `f`.
#' @param min_support the minimum support of a condition to trigger the callback
#'      function `f`. The support of the condition is the relative frequency
#'      of the condition in the dataset `x`. For logical data, it equals to the
#'      relative frequency of rows such that all condition predicates are TRUE on it.
#'      For numerical (double) input, the support is computed as the mean (over all
#'      rows) of multiplications of predicate values. The value of this argument
#'      must be in the range \eqn{[0, 1]}. If the support of the condition is
#'      lower than `min_support`, the recursive search for conditions containing
#'      the current condition is stopped. Therefore, the value of `min_support`
#'      effectively affects the speed of the search process and the number of
#'      triggered calls of the callback function `f`.
#' @param min_focus_support the minimum required support of a focus, for it to be
#'      passed to the callback function `f`. The support of the focus is the
#'      relative frequency of rows such that all condition predicates AND the
#'      focus are TRUE on it. For logical data, it equals to the relative frequency
#'      of rows, for which all condition predicates AND the focus are TRUE. The
#'      numerical (double) input is treated as membership degrees to fuzzy sets
#'      and the support is computed as the mean (over all rows) of a t-norm
#'      of predicate values. (The applied t-norm is selected by the `t_norm`
#'      argument, see below.) The value of this argument must be in the range \eqn{[0, 1]}.
#'      If the support of the focus is lower than `min_focus_support`, the focus
#'      is not passed to the callback function `f`. See also the `filter_empty_foci`
#'      argument which, together with `min_focus_support`, effectively affects
#'      the speed of the search process and the number of triggered calls of the
#'      callback function `f`.
#' @param min_conditional_focus_support the minimum relative support of a focus
#'      within a condition. The conditional support of the focus is the relative
#'      frequency of rows with focus being TRUE within rows where the condition is
#'      TRUE. If \eqn{s(C)} represents the relative frequency of the condition
#'      being TRUE within the dataset and \eqn{s(C \cup F)} represents the relative
#'      frequency of the condition and the focus being both TRUE within the dataset,
#'      (computed as t-norm if the input is numerical), then the conditional support
#'      of the focus is \eqn{s(C \cup F) / s(C)}. The value of this argument must
#'      be in the range \eqn{[0, 1]}. If the conditional support of the focus is
#'      lower than `min_conditional_focus_support`, the focus is not passed to the
#'      callback function `f`. See also the `filter_empty_foci` argument which,
#'      together with `min_conditional_focus_support`, effectively affects the
#'      speed of the search process and the number of triggered calls of the
#'      callback function `f`.
#' @param max_support the maximum support of a condition to trigger the callback
#'      function `f`. If the support of the condition is greater than
#'      `max_support`, the condition is not passed to the callback function.
#'      `max_support` does not stop the recursive generation of conditions
#'      containing the current condition, but only the execution of the callback
#'      function. The value of this argument must be in the range \eqn{[0, 1]}.
#' @param filter_empty_foci a logical scalar indicating whether to skip triggering
#'      the callback function `f` on conditions, for which no focus remains
#'      available after filtering by `min_focus_support` or `min_conditional_focus_support`.
#'      If `TRUE`, the callback function `f` is triggered only if at least
#'      one focus remains after filtering. If `FALSE`, the callback function `f`
#'      is triggered regardless of the number of remaining foci.
#' @param t_norm a t-norm used to compute conjunction of weights. It must be one of
#'      `"goedel"` (minimum t-norm), `"goguen"` (product t-norm), or `"lukas"`
#'      (Lukasiewicz t-norm).
#' @param max_results the maximum number of generated conditions to execute the
#'      callback function on. If the number of found conditions exceeds
#'      `max_results`, the function stops generating new conditions and returns
#'      the results. To avoid long computations during the search, it is recommended
#'      to set `max_results` to a reasonable positive value. Setting `max_results`
#'      to `Inf` will generate all possible conditions.
#' @param verbose a logical scalar indicating whether to print progress messages.
#' @param threads the number of threads to use for parallel computation.
#' @param error_context a list of details to be used in error messages.
#'      This argument is useful when `dig()` is called from another
#'      function to provide error messages, which refer to arguments of the
#'      calling function. The list must contain the following elements:
#'      \itemize{
#'      \item `arg_x` - the name of the argument `x` as a character string
#'      \item `arg_f` - the name of the argument `f` as a character string
#'      \item `arg_condition` - the name of the argument `condition` as a character
#'         string
#'      \item `arg_focus` - the name of the argument `focus` as a character string
#'      \item `arg_disjoint` - the name of the argument `disjoint` as a character
#'         string
#'      \item `arg_min_length` - the name of the argument `min_length` as a character
#'         string
#'      \item `arg_max_length` - the name of the argument `max_length` as a character
#'         string
#'      \item `arg_min_support` - the name of the argument `min_support` as a character
#'         string
#'      \item `arg_min_focus_support` - the name of the argument `min_focus_support`
#'         as a character string
#'      \item `arg_max_support` - the name of the argument `max_support` as a character
#'      \item `arg_filter_empty_foci` - the name of the argument `filter_empty_foci`
#'         as a character string
#'      \item `arg_t_norm` - the name of the argument `t_norm` as a character string
#'      \item `arg_threads` - the name of the argument `threads` as a character string
#'      \item `call` - an environment in which to evaluate the error messages.
#'      }
#' @returns A list of results provided by the callback function `f`.
#' @seealso [partition()], [var_names()], [dig_grid()]
#' @author Michal Burda
#' @examples
#' library(tibble)
#'
#' # Prepare iris data for use with dig()
#' d <- partition(iris, .breaks = 2)
#'
#' # Call f() for each condition with support >= 0.5. The result is a list
#' # of strings representing the conditions.
#' dig(x = d,
#'     f = function(condition) {
#'         format_condition(names(condition))
#'     },
#'     min_support = 0.5)
#'
#' # Create a more complex pattern object - a list with some statistics
#' res <- dig(x = d,
#'            f = function(condition, support) {
#'                list(condition = format_condition(names(condition)),
#'                     support = support)
#'            },
#'            min_support = 0.5)
#' print(res)
#'
#' # Format the result as a data frame
#' do.call(rbind, lapply(res, as_tibble))
#'
#' # Within each condition, evaluate also supports of columns starting with
#' # "Species"
#' res <- dig(x = d,
#'            f = function(condition, support, pp) {
#'                c(list(condition = format_condition(names(condition))),
#'                  list(condition_support = support),
#'                  as.list(pp / nrow(d)))
#'            },
#'            condition = !starts_with("Species"),
#'            focus = starts_with("Species"),
#'            min_support = 0.5,
#'            min_focus_support = 0)
#'
#' # Format the result as a tibble
#' do.call(rbind, lapply(res, as_tibble))
#'
#' # For each condition, create multiple patterns based on the focus columns
#' res <- dig(x = d,
#'            f = function(condition, support, pp) {
#'                lapply(seq_along(pp), function(i) {
#'                    list(condition = format_condition(names(condition)),
#'                         condition_support = support,
#'                         focus = names(pp)[i],
#'                         focus_support = pp[[i]] / nrow(d))
#'                })
#'            },
#'            condition = !starts_with("Species"),
#'            focus = starts_with("Species"),
#'            min_support = 0.5,
#'            min_focus_support = 0)
#'
#' # As res is now a list of lists, we need to flatten it before converting to
#' # a tibble
#' res <- unlist(res, recursive = FALSE)
#'
#' # Format the result as a tibble
#' do.call(rbind, lapply(res, as_tibble))
#' @export
dig <- function(x,
                f,
                condition = everything(),
                focus = NULL,
                disjoint = var_names(colnames(x)),
                excluded = NULL,
                min_length = 0,
                max_length = Inf,
                min_support = 0.0,
                min_focus_support = min_support,
                min_conditional_focus_support = 0.0,
                max_support = 1.0,
                filter_empty_foci = FALSE,
                t_norm = "goguen",
                max_results = Inf,
                verbose = FALSE,
                threads = 1L,
                error_context = list(arg_x = "x",
                                     arg_f = "f",
                                     arg_condition = "condition",
                                     arg_focus = "focus",
                                     arg_disjoint = "disjoint",
                                     arg_excluded = "excluded",
                                     arg_min_length = "min_length",
                                     arg_max_length = "max_length",
                                     arg_min_support = "min_support",
                                     arg_min_focus_support = "min_focus_support",
                                     arg_min_conditional_focus_support = "min_conditional_focus_support",
                                     arg_max_support = "max_support",
                                     arg_filter_empty_foci = "filter_empty_foci",
                                     arg_t_norm = "t_norm",
                                     arg_max_results = "max_results",
                                     arg_verbose = "verbose",
                                     arg_threads = "threads",
                                     call = current_env())) {
    cols <- .convert_data_to_list(x,
                                  error_context = error_context)

    condition <- enquo(condition)
    focus <- enquo(focus)
    condition_cols <- .extract_cols(cols,
                                    !!condition,
                                    allow_numeric = TRUE,
                                    allow_empty = TRUE,
                                    error_context = list(arg_selection = error_context$arg_condition,
                                                         call = error_context$call))
    foci_cols <- .extract_cols(cols,
                               !!focus,
                               allow_numeric = TRUE,
                               allow_empty = TRUE,
                               error_context = list(arg_selection = error_context$arg_focus,
                                                    call = error_context$call))

    .must_be_function(f,
                      required = NULL,
                      optional = c("condition", "foci_supports",
                                   "pp", "np", "pn", "nn",
                                   "indices", "sum", "support", "weights"),
                      arg = error_context$arg_f,
                      call = error_context$call)
    arguments <- formalArgs(f)
    if (is.null(arguments)) {
        arguments <- ""
    }

    .must_be_vector_or_factor(disjoint,
                              null = TRUE,
                              arg = error_context$arg_disjoint,
                              call = error_context$call)
    if (!isTRUE(length(disjoint) == 0 || length(disjoint) == ncol(x))) {
        cli_abort(c("The length of {.arg {error_context$arg_disjoint}} must be 0 or must be equal to the number of columns in {.arg {error_context$arg_x}}.",
                    "x" = "The number of columns in {.arg {error_context$arg_x}} is {ncol(x)}.",
                    "x" = "The length of {.arg {error_context$arg_disjoint}} is {length(disjoint)}."),
                  call = error_context$call)
    }

    disjoint_predicates <- integer(0L)
    disjoint_foci <- integer(0L)
    if (length(disjoint) > 0) {
        disjoint <- as.integer(as.factor(disjoint))
        disjoint_predicates <- disjoint[condition_cols$indices]
        disjoint_foci <- disjoint[foci_cols$indices]
    }

    .must_be_list_of_characters(excluded,
                                null = TRUE,
                                arg = error_context$arg_excluded,
                                call = error_context$call)
    if (is.null(excluded)) {
        excluded <- list()
    } else {
        # convert list elements to C++ indices starting from 0
        excluded <- lapply(excluded,
                           function(i) { fmatch(i, names(condition_cols$indices)) - 1 })
    }

    .must_be_integerish_scalar(min_length,
                               arg = error_context$arg_min_length,
                               call = error_context$call)
    .must_be_finite(min_length,
                    arg = error_context$arg_min_length,
                    call = error_context$call)
    .must_be_greater_eq(min_length, 0,
                        arg = error_context$arg_min_length,
                        call = error_context$call)
    min_length <- as.integer(min_length)

    .must_be_integerish_scalar(max_length,
                               arg = error_context$arg_max_length,
                               call = error_context$call)
    .must_be_greater_eq(max_length, 0,
                        arg = error_context$arg_max_length,
                        call = error_context$call)
    if (max_length < min_length) {
        cli_abort(c("{.arg {error_context$arg_max_length}} must be greater or equal to {.arg {error_context$arg_min_length}}.",
                    "x" = "{.arg {error_context$arg_min_length}} equals {min_length}.",
                    "x" = "{.arg {error_context$arg_max_length}} equals {max_length}."),
                  call = error_context$call)
    }
    if (!is.finite(max_length)) {
        max_length <- -1L;
    }
    max_length <- as.integer(max_length)

    .must_be_double_scalar(min_support,
                           arg = error_context$arg_min_support,
                           call = error_context$call)
    .must_be_in_range(min_support, c(0, 1),
                      arg = error_context$arg_min_support,
                      call = error_context$call)
    min_support <- as.double(min_support)

    .must_be_double_scalar(min_focus_support,
                           arg = error_context$arg_min_focus_support,
                           call = error_context$call)
    .must_be_in_range(min_focus_support, c(0, 1),
                      arg = error_context$arg_min_focus_support,
                      call = error_context$call)
    min_focus_support <- as.double(min_focus_support)

    .must_be_double_scalar(min_conditional_focus_support,
                           arg = error_context$arg_min_conditional_focus_support,
                           call = error_context$call)
    .must_be_in_range(min_conditional_focus_support, c(0, 1),
                      arg = error_context$arg_min_conditional_focus_support,
                      call = error_context$call)
    min_conditional_focus_support <- as.double(min_conditional_focus_support)

    .must_be_double_scalar(max_support,
                           arg = error_context$arg_max_support,
                           call = error_context$call)
    .must_be_in_range(max_support, c(0, 1),
                      arg = error_context$arg_max_support,
                      call = error_context$call)
    max_support <- as.double(max_support)

    .must_be_flag(filter_empty_foci,
                  arg = error_context$arg_filter_empty_foci,
                  call = error_context$call)

    .must_be_enum(t_norm, c("goguen", "goedel", "lukas"),
                  arg = error_context$arg_t_norm,
                  call = error_context$call)

    .must_be_integerish_scalar(max_results,
                               arg = error_context$arg_max_results,
                               call = error_context$call)
    .must_be_greater_eq(max_results, 1,
                        arg = error_context$arg_max_results,
                        call = error_context$call)
    if (is.finite(max_results)) {
        max_results <- as.integer(max_results)
    } else {
        max_results <- -1L
    }

    .must_be_flag(verbose,
                  arg = error_context$arg_verbose,
                  call = error_context$call)

    .must_be_integerish_scalar(threads,
                               arg = error_context$arg_threads,
                               call = error_context$call)
    .must_be_greater_eq(threads, 1,
                        arg = error_context$arg_threads,
                        call = error_context$call)
    threads <- as.integer(threads)

    config <- list(nrow = nrow(x),
                   arguments = arguments,
                   predicates = condition_cols$indices,
                   foci = foci_cols$indices,
                   disjoint_predicates = disjoint_predicates,
                   disjoint_foci = disjoint_foci,
                   excluded = excluded,
                   minLength = min_length,
                   maxLength = max_length,
                   minSupport = min_support,
                   minFocusSupport = min_focus_support,
                   minConditionalFocusSupport = min_conditional_focus_support,
                   maxSupport = max_support,
                   filterEmptyFoci = filter_empty_foci,
                   tNorm = t_norm,
                   maxResults = max_results,
                   verbose = verbose,
                   threads = threads)

    res <- dig_(condition_cols$logicals,
                condition_cols$doubles,
                foci_cols$logicals,
                foci_cols$doubles, config)

    .msg(verbose, "dig: executing callback function on the results")
    lapply(res, do.call, what = f)
}
