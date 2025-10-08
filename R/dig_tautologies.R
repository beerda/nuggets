#' Find tautologies or "almost tautologies" in a dataset
#'
#' This function finds tautologies in a dataset, i.e., rules of the form
#' `{a1 & a2 & ... & an} => {c}` where `a1`, `a2`, ..., `an` are
#' antecedents and `c` is a consequent. The intent of searching for
#' tautologies is to find rules that are always true, which may be
#' used for filtering of further generated conditions. The resulting
#' rules may be used as a basis for the list of `excluded` formulae
#' (see the `excluded` argument of [dig()]).
#'
#' The search for tautologies is performed by iteratively
#' searching for rules with increasing length of the antecedent.
#' Rules found in previous iterations are used as `excluded`
#' argument in the next iteration.
#'
#' @param x a matrix or data frame with data to search in. The matrix must be
#'      numeric (double) or logical. If `x` is a data frame then each column
#'      must be either numeric (double) or logical.
#' @param antecedent a tidyselect expression (see
#'      [tidyselect syntax](https://tidyselect.r-lib.org/articles/syntax.html))
#'      specifying the columns to use in the antecedent (left) part of the rules
#' @param consequent a tidyselect expression (see
#'      [tidyselect syntax](https://tidyselect.r-lib.org/articles/syntax.html))
#'      specifying the columns to use in the consequent (right) part of the rules
#' @param disjoint an atomic vector of size equal to the number of columns of `x`
#'      that specifies the groups of predicates: if some elements of the `disjoint`
#'      vector are equal, then the corresponding columns of `x` will NOT be
#'      present together in a single condition. If `x` is prepared with
#'      [partition()], using the [var_names()] function on `x`'s column names
#'      is a convenient way to create the `disjoint` vector.
#' @param max_length The maximum length, i.e., the maximum number of predicates in the
#'      antecedent, of a rule to be generated. If equal to Inf, the maximum length
#'      is limited only by the number of available predicates.
#' @param min_coverage the minimum coverage of a rule in the dataset `x`.
#'      (See Description for the definition of *coverage*.)
#' @param min_support the minimum support of a rule in the dataset `x`.
#'      (See Description for the definition of *support*.)
#' @param min_confidence the minimum confidence of a rule in the dataset `x`.
#'      (See Description for the definition of *confidence*.)
#' @param measures a character vector specifying the additional quality measures to compute.
#'      If `NULL`, no additional measures are computed. Possible values are `"lift"`,
#'      `"conviction"`, `"added_value"`.
#'      See [https://mhahsler.github.io/arules/docs/measures](https://mhahsler.github.io/arules/docs/measures)
#'      for a description of the measures.
#' @param t_norm a t-norm used to compute conjunction of weights. It must be one of
#'      `"goedel"` (minimum t-norm), `"goguen"` (product t-norm), or `"lukas"`
#'      (Lukasiewicz t-norm).
#' @param max_results the maximum number of generated conditions to execute the
#'      callback function on. If the number of found conditions exceeds
#'      `max_results`, the function stops generating new conditions and returns
#'      the results. To avoid long computations during the search, it is recommended
#'      to set `max_results` to a reasonable positive value. Setting `max_results`
#'      to `Inf` will generate all possible conditions.
#' @param verbose a logical value indicating whether to print progress messages.
#' @param threads the number of threads to use for parallel computation.
#' @returns An S3 object which is an instance of `associations` and `nugget`
#'      classes and which is a tibble with found tautologies in the format equal to
#'      the output of [dig_associations()].
#' @author Michal Burda
#' @export
dig_tautologies <- function(x,
                            antecedent = everything(),
                            consequent = everything(),
                            disjoint = var_names(colnames(x)),
                            max_length = Inf,
                            min_coverage = 0,
                            min_support = 0,
                            min_confidence = 0,
                            measures = NULL,
                            t_norm = "goguen",
                            max_results = Inf,
                            verbose = FALSE,
                            threads = 1) {
    .must_be_integerish_scalar(max_length)
    .must_be_greater_eq(max_length, 0)

    .must_be_integerish_scalar(max_results)
    .must_be_greater_eq(max_results, 1)

    antecedent <- enquo(antecedent)
    consequent <- enquo(consequent)
    tautologies <- list()
    result <- NULL
    len <- 0

    digattr <- NULL
    while (len <= max_length) {
        maxres <- max_results
        if (is.finite(max_results) && !is.null(result)) {
            maxres <- max_results - nrow(result)
        }

        res <- dig_associations(x = x,
                                antecedent = !!antecedent,
                                consequent = !!consequent,
                                disjoint = disjoint,
                                excluded = tautologies,
                                min_length = len,
                                max_length = len,
                                min_coverage = min_coverage,
                                min_support = min_support,
                                min_confidence = min_confidence,
                                measures = measures,
                                t_norm = t_norm,
                                max_results = maxres,
                                verbose = verbose,
                                threads = threads,
                                error_context = list(arg_x = "x",
                                                     arg_antecedent = "antecedent",
                                                     arg_consequent = "consequent",
                                                     arg_disjoint = "disjoint",
                                                     arg_excluded = "internal `tautologies`",
                                                     arg_min_length = "internal `len`",
                                                     arg_max_length = "internal `len`",
                                                     arg_min_coverage = "min_coverage",
                                                     arg_min_support = "min_support",
                                                     arg_min_confidence = "min_confidence",
                                                     arg_measures = "measures",
                                                     arg_t_norm = "t_norm",
                                                     arg_max_results = "internal `maxres`",
                                                     arg_verbose = "verbose",
                                                     arg_threads = "threads",
                                                     call = current_env()))

        if (is.null(digattr)) {
            digattr <- attributes(res)
        }

        if (nrow(res) <= 0) {
            break
        }

        result <- rbind(result, res)
        tautologies <- c(tautologies, parse_condition(res$antecedent, res$consequent))
        len <- len + 1
    }

    rownames(result) <- NULL

    nugget(result,
           flavour = "associations",
           call_function = "dig_tautologies",
           call_args = list(antecedent = digattr$call_args$antecedent,
                            consequent = digattr$call_args$consequent,
                            disjoint = disjoint,
                            max_length = max_length,
                            min_coverage = min_coverage,
                            min_support = min_support,
                            min_confidence = min_confidence,
                            measures = measures,
                            t_norm = t_norm,
                            max_results = max_results,
                            verbose = verbose,
                            threads = threads))
}
