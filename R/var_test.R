# Internal function for the F test used in pre-defined dig functions.
#
# @author Michal Burda
.var_test <- function(x,
                      y,
                      alternative = c("two.sided", "less", "greater"),
                      ratio = 1,
                      conf_level = 0.95,
                      max_p_value = 1) {
    res <- .quietly(var.test(x = x,
                             y = y,
                             ratio = ratio,
                             alternative = alternative,
                             conf.level = conf_level))
    fit <- res$result

    if (is.null(fit)) {
        # error
        warn(paste("var.test:", res$comment))
        return(NULL)

    } else if (is.finite(fit$p.value) && fit$p.value > max_p_value) {
        # omit the result
        return(NULL)

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
