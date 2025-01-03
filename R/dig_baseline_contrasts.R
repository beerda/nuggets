#'
#' @return
#' @author Michal Burda
#' @export
dig_baseline_contrasts <- function(x,
                                   condition = where(is.logical),
                                   vars = where(is.numeric),
                                   disjoint = var_names(colnames(x)),
                                   min_length = 0L,
                                   max_length = Inf,
                                   min_support = 0.0,
                                   method = "t",
                                   alternative = "two.sided",
                                   h0 = 0,
                                   conf_level = 0.95,
                                   max_p_value = 0.05,
                                   wilcox_exact = FALSE,
                                   wilcox_correct = TRUE,
                                   wilcox_tol_root = 1e-4,
                                   wilcox_digits_rank = Inf,
                                   threads = 1) {
    .must_be_enum(method, c("t", "wilcox"))
    .must_be_enum(alternative, c("two.sided", "less", "greater"))
    .must_be_double_scalar(h0)
    .must_be_double_scalar(conf_level)
    .must_be_in_range(conf_level, c(0, 1))
    .must_be_double_scalar(max_p_value)
    .must_be_in_range(max_p_value, c(0, 1))
    .must_be_flag(wilcox_exact, null = TRUE)
    .must_be_flag(wilcox_correct)
    .must_be_double_scalar(wilcox_tol_root)
    .must_be_double_scalar(wilcox_digits_rank)

    condition <- enquo(condition)
    vars <- enquo(vars)

    if (method == "t") {
        f <- function(pd) {
            .t_test(x = pd[[1]],
                    y = NULL,
                    alternative = alternative,
                    mu = h0,
                    paired = FALSE,
                    conf_level = conf_level,
                    max_p_value = max_p_value)
        }

    } else if (method == "wilcox") {
        f <- function(pd) {
            .wilcox_test(x = pd[[1]],
                         y = NULL,
                         alternative = alternative,
                         mu = h0,
                         paired = FALSE,
                         exact = wilcox_exact,
                         correct = wilcox_correct,
                         conf_level = conf_level,
                         tol_root = wilcox_tol_root,
                         digits_rank = wilcox_digits_rank,
                         max_p_value = max_p_value)
        }

    } else {
        stop("Internal error - unknown method: ", method)
    }

    dig_grid(x = x,
             f = f,
             condition = !!condition,
             xvars = !!vars,
             yvars = NULL,
             disjoint = disjoint,
             allow = "numeric",
             na_rm = TRUE,
             type = "crisp",
             min_length = min_length,
             max_length = max_length,
             min_support = min_support,
             threads = threads,
             error_context = list(arg_x = "x",
                                  arg_condition = "condition",
                                  arg_xvars = "vars",
                                  arg_yvars = "yvars",
                                  arg_min_length = "min_length",
                                  arg_max_length = "max_length",
                                  arg_min_support = "min_support",
                                  arg_threads = "threads",
                                  call = current_env()))
}
