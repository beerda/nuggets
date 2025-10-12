#' Search for patterns of a custom type
#'
#' A general function for searching for patterns of a custom type. The function
#' allows selection of columns of `x` to be used as condition predicates. It
#' enumerates all possible conditions in the form of elementary conjunctions of
#' selected predicates, and for each condition executes a user-defined callback
#' function `f`. The callback is expected to perform some analysis and return an
#' object (often a list) representing a pattern or patterns related to the
#' condition. The results of all calls are returned as a list.
#'
#' The callback function `f` may accept a number of arguments (see `f` argument
#' description). The algorithm automatically provides condition-related
#' information to `f` based on which arguments are present.
#'
#' In addition to conditions, the function can evaluate *focus* predicates
#' (foci). Foci are specified separately and are tested within each generated
#' condition. Extra information about them is then passed to `f`.
#'
#' Restrictions may be imposed on generated conditions, such as:
#' - minimum and maximum condition length (`min_length`, `max_length`);
#' - minimum condition support (`min_support`);
#' - minimum focus support (`min_focus_support`), i.e. support of rows where
#'   both the condition and the focus hold.
#'
#' @details
#' Let \eqn{P} be the set of condition predicates selected by `condition` and
#' \eqn{E} be the set of focus predicates selected by `focus`. The function
#' generates all possible conditions as elementary conjunctions of distinct
#' predicates from \eqn{P}. These conditions are filtered using `disjoint`,
#' `excluded`, `min_length`, `max_length`, `min_support`, and `max_support`.
#'
#' For each remaining condition, all foci from \eqn{E} are tested and filtered
#' using `min_focus_support` and `min_conditional_focus_support`. If at least
#' one focus remains (or if `filter_empty_foci = FALSE`), the callback `f` is
#' executed with details of the condition and foci. Results of all calls are
#' collected and returned as a list.
#'
#' Let \eqn{C} be a condition (\eqn{C \subseteq P}), \eqn{F} the set of
#' filtered foci (\eqn{F \subseteq E}), \eqn{R} the set of rows of `x`, and
#' \eqn{\mu_C(r)} the truth degree of condition \eqn{C} on row \eqn{r}. The
#' parameters passed to `f` are defined as:
#'
#' - `condition`: a named integer vector of column indices representing the
#'   predicates of \eqn{C}. Names correspond to column names.
#'
#' - `sum`: a numeric scalar value of the number of rows satisfying \eqn{C} for
#'   logical data, or the sum of truth degrees for fuzzy data,
#'   \eqn{sum = \sum_{r \in R} \mu_C(r)}.
#'
#' - `support`: a numeric scalar value of relative frequency of rows satisfying \eqn{C},
#'   \eqn{supp = sum / |R|}.
#'
#' - `pp`, `pn`, `np`, `nn`: a numeric vector of entries of a contingency table
#'   for \eqn{C} and \eqn{F}, satisfying the Ruspini condition
#'   \eqn{pp + pn + np + nn = |R|}.
#'   The \eqn{i}-th elements of these vectors correspond to the \eqn{i}-th focus
#'   \eqn{F_i} from \eqn{F} and are defined as:
#'   * `pp[i]`: rows satisfying both \eqn{C} and \eqn{F_i},
#'     \eqn{pp_i = \sum_{r \in R} \mu_{C \land F_i}(r)}.
#'   * `pn[i]`: rows satisfying \eqn{C} but not \eqn{F_i},
#'     \eqn{pn_i = \sum_{r \in R} \mu_C(r) - pp_i}.
#'   * `np[i]`: rows satisfying \eqn{F_i} but not \eqn{C},
#'     \eqn{np_i = \sum_{r \in R} \mu_{F_i}(r) - pp_i}.
#'   * `nn[i]`: rows satisfying neither \eqn{C} nor \eqn{F_i},
#'     \eqn{nn_i = |R| - (pp_i + pn_i + np_i)}.
#'
#' @param x A matrix or data frame. If a matrix, it must be numeric (double) or
#'   logical. If a data frame, all columns must be numeric (double) or logical.
#' @param f A callback function executed for each generated condition. It may
#'   accept arguments such as
#'   `condition`, `sum`, `support`, `indices`,
#'   `weights`, `pp`, `pn`, `np`, `nn`, or `foci_supports` (deprecated). The
#'   algorithm supplies matching values automatically. `f` should return an
#'   object (typically a list). Results of all calls are collected and returned.
#' @param f A callback function executed for each generated condition. It may
#'   declare any subset of the arguments listed below. The algorithm detects
#'   which arguments are present and provides only those values to `f`. This
#'   design allows the user to control both the amount of information received
#'   and the computational cost, as some arguments are more expensive to
#'   compute than others. The function `f` is expected to return an object
#'   (typically a list) representing a pattern or patterns related to the
#'   condition. The results of all calls of `f` are collected and returned as
#'   a list. Possible arguments are: `condition`, `sum`, `support`, `indices`,
#'   `weights`, `pp`, `pn`, `np`, `nn`, or `foci_supports` (deprecated), which
#'   are thoroughly described below in the "Details" section.
#' @param condition Tidyselect expression (see
#'      [tidyselect syntax](https://tidyselect.r-lib.org/articles/syntax.html))
#'      specifying columns of `x` to use as condition predicates
#' @param focus Tidyselect expression (see
#'      [tidyselect syntax](https://tidyselect.r-lib.org/articles/syntax.html))
#'      specifying columns of `x` to use as focus predicates
#' @param disjoint An atomic vector (length = number of columns in `x`) defining
#'   groups of predicates. Columns in the same group cannot appear together in
#'   a condition. With data from [partition()], use [var_names()] on column
#'   names to construct `disjoint`.
#' @param excluded `NULL` or a list of character vectors, each representing an
#'   implication formula. In each vector, all but the last element form the
#'   antecedent and the last element is the consequent. These formulae are
#'   treated as *tautologies* and used to filter out generated conditions. If
#'   a condition contains both the antecedent and the consequent of any such
#'   formula, it is not passed to the callback function `f`. Likewise, if a
#'   condition contains the antecedent, the corresponding focus (the consequent)
#'   is not passed to `f`.
#' @param min_length Minimum number of predicates in a condition required to
#'   trigger the callback `f`. Must be \eqn{\ge 0}. If set to 0, the empty
#'   condition also triggers the callback.
#' @param max_length Maximum number of predicates allowed in a condition.
#'   Conditions longer than `max_length` are not generated. If `Inf`, the only
#'   limit is the total number of available predicates. Must be \eqn{\ge 0} and
#'   \eqn{\ge min_length}. This setting strongly influences both the number of
#'   generated conditions and the speed of the search.
#' @param min_support Minimum support of a condition required to trigger `f`.
#'   Support is the relative frequency of the condition in `x`. For logical
#'   data, this is the proportion of rows where all condition predicates are
#'   `TRUE`. For numeric (double) data, support is the mean (over all rows) of
#'   the products of predicate values. Must be in \eqn{[0,1]}. If a condition’s
#'   support falls below `min_support`, recursive generation of its extensions
#'   is stopped. Thus, `min_support` directly affects search speed and the
#'   number of callback calls.
#' @param min_focus_support Minimum support of a focus required for it to be
#'   passed to `f`. For logical data, this is the proportion of rows where both
#'   the condition and the focus are `TRUE`. For numeric (double) data, support
#'   is computed as the mean (over all rows) of a t-norm of predicate values
#'   (the t-norm is selected by `t_norm`). Must be in \eqn{[0,1]}. Foci with
#'   support below this threshold are excluded. Together with
#'   `filter_empty_foci`, this parameter influences both search speed and the
#'   number of triggered calls of `f`.
#' @param min_conditional_focus_support Minimum conditional support of a focus
#'   within a condition. Defined as the relative frequency of rows where the
#'   focus is `TRUE` among those where the condition is `TRUE`. If \eqn{sum}
#'   (see `support` in *Details*) is the number of rows (or sum of truth
#'   degrees for fuzzy data) satisfying the condition, and \eqn{pp} (see
#'   `pp[i]` in *Details*) is the sum of truth degrees where both the condition
#'   and the focus hold, then conditional support is \eqn{pp / sum}. Must be in
#'   \eqn{[0,1]}. Foci below this threshold are not passed to `f`. Together with
#'   `filter_empty_foci`, this parameter influences search speed and the number
#'   of callback calls.
#' @param max_support Maximum support of a condition to trigger `f`. Conditions
#'   with support above this threshold are skipped, but recursive generation of
#'   their supersets continues. Must be in \eqn{[0,1]}.
#' @param filter_empty_foci Logical; controls whether `f` is triggered for
#'   conditions with no remaining foci after filtering by `min_focus_support`
#'   or `min_conditional_focus_support`. If `TRUE`, `f` is called only when at
#'   least one focus remains. If `FALSE`, `f` is called regardless.
#' @param t_norm T-norm used for conjunction of weights: `"goedel"` (minimum),
#'   `"goguen"` (product), or `"lukas"` (Lukasiewicz).
#' @param max_results Maximum number of results (objects returned by the
#'   callback `f`) to store and return in the output list. When this limit
#'   is reached, generation of further conditions stops. Use a positive
#'   integer to enable early stopping; set to `Inf` to remove the cap.
#' @param verbose Logical; if `TRUE`, print progress messages.
#' @param threads Number of threads for parallel computation.
#' @param error_context A list of details to be used when constructing error
#'   messages. This is mainly useful when `dig()` is called from another
#'   function and errors should refer to the caller’s argument names rather
#'   than those of `dig()`. The list must contain:
#'   \itemize{
#'     \item `arg_x` – name of the argument `x` as a character string
#'     \item `arg_f` – name of the argument `f` as a character string
#'     \item `arg_condition` – name of the argument `condition`
#'     \item `arg_focus` – name of the argument `focus`
#'     \item `arg_disjoint` – name of the argument `disjoint`
#'     \item `arg_excluded` – name of the argument `excluded`
#'     \item `arg_min_length` – name of the argument `min_length`
#'     \item `arg_max_length` – name of the argument `max_length`
#'     \item `arg_min_support` – name of the argument `min_support`
#'     \item `arg_min_focus_support` – name of the argument
#'       `min_focus_support`
#'     \item `arg_min_conditional_focus_support` – name of the argument
#'       `min_conditional_focus_support`
#'     \item `arg_max_support` – name of the argument `max_support`
#'     \item `arg_filter_empty_foci` – name of the argument `filter_empty_foci`
#'     \item `arg_t_norm` – name of the argument `t_norm`
#'     \item `arg_threads` – name of the argument `threads`
#'     \item `call` – environment in which to evaluate error messages
#'   }
#' @returns A list of results returned by the callback function `f`.
#' @seealso [partition()], [var_names()], [dig_grid()]
#' @author Michal Burda
#'
#' @examples
#' library(tibble)
#'
#' # Prepare iris data
#' d <- partition(iris, .breaks = 2)
#'
#' # Simple callback: return formatted condition names
#' dig(x = d,
#'     f = function(condition) format_condition(names(condition)),
#'     min_support = 0.5)
#'
#' # Callback returning condition and support
#' res <- dig(x = d,
#'            f = function(condition, support) {
#'                list(condition = format_condition(names(condition)),
#'                     support = support)
#'            },
#'            min_support = 0.5)
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
#' do.call(rbind, lapply(res, as_tibble))
#'
#' # Multiple patterns per condition based on foci
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
#' # Flatten result and convert to tibble
#' res <- unlist(res, recursive = FALSE)
#' do.call(rbind, lapply(res, as_tibble))
#'
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
                min_focus_support = 0.0,
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

    fun <- function(l) {
        do.call(f, l)
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

    orig_disjoint <- disjoint
    if (length(disjoint) > 0) {
        disjoint <- as.integer(as.factor(disjoint))
    } else {
        disjoint <- seq_along(cols)
    }

    .must_be_list_of_characters(excluded,
                                null = TRUE,
                                arg = error_context$arg_excluded,
                                call = error_context$call)
    orig_excluded <- excluded
    if (is.null(excluded)) {
        excluded <- list()
    } else {
        excluded_predicates <- unique(unlist(excluded))
        excluded_undefined <- setdiff(excluded_predicates, colnames(x))
        if (length(excluded_undefined) > 0) {
            details <- paste0("Column {.var ", excluded_undefined, "} can't be found.")
            cli_abort(c("Can't find some column names in {.arg {error_context$arg_x}} that correspond to all predicates in {.arg {error_context$arg_excluded}}.",
                        "i" = "Consider using {.fn remove_ill_conditions()} to remove conditions with undefined predicates.",
                        ..error_details(details)))
        }
        excluded <- lapply(excluded,
                           fmatch,
                           colnames(x))
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
                   disjoint = disjoint,
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

    res <- dig_(cols,
                names(cols),
                condition_cols$selected,
                foci_cols$selected,
                fun,
                config)

    nugget(res,
           flavour = NULL,
           call_function = "dig",
           call_data = list(nrow = nrow(x),
                            ncol = ncol(x),
                            colnames = as.character(colnames(x))),
           call_args = list(x = deparse(substitute(x)),
                            condition = names(cols)[condition_cols$selected],
                            focus = names(cols)[foci_cols$selected],
                            disjoint = orig_disjoint,
                            excluded = orig_excluded,
                            min_length = min_length,
                            max_length = if (max_length < 0) Inf else max_length,
                            min_support = min_support,
                            min_focus_support = min_focus_support,
                            min_conditional_focus_support = min_conditional_focus_support,
                            max_support = max_support,
                            filter_empty_foci = filter_empty_foci,
                            t_norm = t_norm,
                            max_results = max_results,
                            verbose = verbose,
                            threads = threads))
}
