# Internal function for the t-test
#
# The result is always a list with the same elements. If an error occurs,
# the returned list contains the desired elements filled with NAs.
#
# @return
# @author Michal Burda
.t_test <- function(x,
                    y = NULL,
                    alternative = c("two.sided", "less", "greater"),
                    mu = 0,
                    paired = FALSE,
                    var_equal = FALSE,
                    conf_level = 0.95,
                    max_p_value = 1) {
    fit <- try(t.test(x = x,
                      y = y,
                      alternative = alternative,
                      mu = mu,
                      paired = paired,
                      var.equal = var_equal,
                      conf.level = conf_level),
               silent = TRUE)

    if (inherits(fit, "try-error")) {
        # error
        warn(paste("t.test:", conditionMessage(attr(fit, "condition"))))
        return(NULL)

    } else if (fit$p.value > max_p_value) {
        # omit the result
        return(NULL)

    } else if (is.null(y)) {
        # one-sample test
        return(list(estimate = as.numeric(fit$estimate[1]),
                    statistic = as.numeric(fit$statistic[1]),
                    df = as.numeric(fit$parameter[1]),
                    p_value = as.numeric(fit$p.value),
                    n = length(x),
                    conf_lo = as.numeric(fit$conf.int[1]),
                    conf_hi = as.numeric(fit$conf.int[2]),
                    stderr = as.numeric(fit$stderr),
                    alternative = fit$alternative,
                    method = fit$method))

    } else if (paired) {
        # paired test
        return(list(estimate = as.numeric(fit$estimate[1]),
                    statistic = as.numeric(fit$statistic[1]),
                    df = as.numeric(fit$parameter[1]),
                    p_value = as.numeric(fit$p.value),
                    n = length(x),
                    conf_lo = as.numeric(fit$conf.int[1]),
                    conf_hi = as.numeric(fit$conf.int[2]),
                    stderr = as.numeric(fit$stderr),
                    alternative = fit$alternative,
                    method = fit$method))

    } else {
        # two-sample test
        return(list(estimate_x = as.numeric(fit$estimate[1]),
                    estimate_y = as.numeric(fit$estimate[2]),
                    statistic = as.numeric(fit$statistic[1]),
                    df = as.numeric(fit$parameter[1]),
                    p_value = as.numeric(fit$p.value),
                    n_x = length(x),
                    n_y = length(y),
                    conf_lo = as.numeric(fit$conf.int[1]),
                    conf_hi = as.numeric(fit$conf.int[2]),
                    stderr = as.numeric(fit$stderr),
                    alternative = fit$alternative,
                    method = fit$method))
    }
}
