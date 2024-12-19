test_that(".wilcox_test error", {
    expect_warning(res <- .wilcox_test(NULL, 2),
                   "wilcox.test: 'x' must be numeric")
    expect_null(res)
})

test_that(".wilcox_test max p-value not reached", {
    x <- 1:20
    y <- 20:1
    expect_null(.wilcox_test(x = x, y = y, paired = FALSE, max_p_value = 0.05))
    expect_null(.wilcox_test(x = x, y = y, paired = TRUE, max_p_value = 0.05))
})

test_that(".wilcox_test one-sample", {
    x <- (-10):10
    res <- .wilcox_test(x = x,
                        mu = 0,
                        alternative = "two.sided",
                        exact = FALSE)

    expect_true(is.list(res))
    expect_equal(length(res), 8)
    expect_equal(res$estimate, 0)
    expect_equal(res$statistic, 105)
    expect_equal(res$p_value, 1)
    expect_equal(res$n, 21)
    expect_equal(res$conf_lo, -3, tolerance = 1e-4)
    expect_equal(res$conf_hi, 3, tolerance = 1e-4)
    expect_equal(res$alternative, "two.sided")
    expect_equal(res$method, "Wilcoxon signed rank test with continuity correction")
})

test_that(".wilcox_test paired", {
    x <- 1:20
    y <- 20:1

    res <- .wilcox_test(x = x,
                        y = y,
                        paired = TRUE,
                        exact = FALSE,
                        alternative = "two.sided")

    expect_true(is.list(res))
    expect_equal(length(res), 8)
    expect_equal(res$estimate, 0)
    expect_equal(res$statistic, 105, tolerance = 1e-4)
    expect_equal(res$p_value, 1.0, tolerance = 1e-3)
    expect_equal(res$n, 20)
    expect_equal(res$conf_lo, -6, tolerance = 1e-4)
    expect_equal(res$conf_hi, 6, tolerance = 1e-4)
    expect_equal(res$alternative, "two.sided")
    expect_equal(res$method, "Wilcoxon signed rank test with continuity correction")
})

test_that(".wilcox_test two-sample", {
    x <- 1:20
    y <- 3:20

    res <- .wilcox_test(x = x,
                        y = y,
                        paired = FALSE,
                        exact = FALSE,
                        alternative = "two.sided")

    expect_true(is.list(res))
    expect_equal(length(res), 9)
    expect_equal(res$estimate, -1)
    expect_equal(res$statistic, 162, tolerance = 1e-4)
    expect_equal(res$p_value, 0.60857, tolerance = 1e-4)
    expect_equal(res$n_x, 20)
    expect_equal(res$n_y, 18)
    expect_equal(res$conf_lo, -5, tolerance = 1e-4)
    expect_equal(res$conf_hi, 3, tolerance = 1e-4)
    expect_equal(res$alternative, "two.sided")
    expect_equal(res$method, "Wilcoxon rank sum test with continuity correction")
})
