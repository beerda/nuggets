# Internal function for the Wilcoxon test used in pre-defined dig functions.
#
# @author Michal Burda
.wilcox_test <- function(x,
                         y = NULL,
                         alternative = c("two.sided", "less", "greater"),
                         mu = 0,
                         paired = FALSE,
                         exact = FALSE,
                         correct = TRUE,
                         conf_level = 0.95,
                         tol_root = 1e-4,
                         digits_rank = Inf,
                         max_p_value = 1) {
    res <- .quietly(wilcox.test(x = x,
                                y = y,
                                alternative = alternative,
                                mu = mu,
                                paired = paired,
                                exact = exact,
                                correct = correct,
                                conf.int = TRUE,
                                conf.level = conf_level,
                                tol.root = tol_root,
                                digits.rank = digits_rank))
    fit <- res$result

    if (is.null(fit)) {
        # error
        warn(paste("wilcox.test:", res$comment))
        return(NULL)

    } else if (is.finite(fit$p.value) && fit$p.value > max_p_value) {
        # omit the result
        return(NULL)

    } else if (is.null(y) || paired) {
        # one-sample test or paired test
        return(list(estimate = as.numeric(fit$estimate[1]),
                    statistic = as.numeric(fit$statistic[1]),
                    p_value = as.numeric(fit$p.value),
                    n = length(x),
                    conf_lo = as.numeric(fit$conf.int[1]),
                    conf_hi = as.numeric(fit$conf.int[2]),
                    alternative = fit$alternative,
                    method = fit$method,
                    comment = res$comment))

    } else {
        # two-sample test
        return(list(estimate = as.numeric(fit$estimate[1]),
                    statistic = as.numeric(fit$statistic[1]),
                    p_value = as.numeric(fit$p.value),
                    n_x = length(x),
                    n_y = length(y),
                    conf_lo = as.numeric(fit$conf.int[1]),
                    conf_hi = as.numeric(fit$conf.int[2]),
                    alternative = fit$alternative,
                    method = fit$method,
                    comment = res$comment))
    }
}
