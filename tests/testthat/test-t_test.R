test_that(".t_test error", {
    expect_warning(res <- .t_test(1, 2),
                   "t.test: not enough 'x' observations")
    expect_null(res)
})

test_that(".t_test max p-value not reached", {
    x <- 1:20
    y <- x
    y[5] <- 0
    expect_null(.t_test(x = x, y = y, paired = FALSE, max_p_value = 0.05))
    expect_null(.t_test(x = x, y = y, paired = TRUE, max_p_value = 0.05))
})

test_that(".t_test one-sample", {
    x <- (-10):10
    res <- .t_test(x = x, mu = 0, alternative = "two.sided")

    expect_true(is.list(res))
    expect_equal(length(res), 10)
    expect_equal(res$estimate, 0)
    expect_equal(res$statistic, 0)
    expect_equal(res$df, 20)
    expect_equal(res$p_value, 1)
    expect_equal(res$n, 21)
    expect_equal(res$conf_lo, -2.8244, tolerance = 1e-4)
    expect_equal(res$conf_hi, 2.8244, tolerance = 1e-4)
    expect_equal(res$stderr, 1.3540, tolerance = 1e-4)
    expect_equal(res$alternative, "two.sided")
    expect_equal(res$method, "One Sample t-test")
})

test_that(".t_test paired", {
    x <- 1:20
    y <- x + 1
    y[5] <- 0

    res <- .t_test(x = x, y = y, paired = TRUE, alternative = "two.sided")

    expect_true(is.list(res))
    expect_equal(length(res), 10)
    expect_equal(res$estimate, -0.7)
    expect_equal(res$statistic, -2.3333, tolerance = 1e-4)
    expect_equal(res$df, 19)
    expect_equal(res$p_value, 0.030771, tolerance = 1e-4)
    expect_equal(res$n, 20)
    expect_equal(res$conf_lo, -1.3279, tolerance = 1e-4)
    expect_equal(res$conf_hi, -0.07209, tolerance = 1e-4)
    expect_equal(res$stderr, 0.3, tolerance = 1e-4)
    expect_equal(res$alternative, "two.sided")
    expect_equal(res$method, "Paired t-test")
})

test_that(".t_test two-sample", {
    x <- 1:20
    y <- 3:20

    res <- .t_test(x = x, y = y, paired = FALSE, alternative = "two.sided")

    expect_true(is.list(res))
    expect_equal(length(res), 12)
    expect_equal(res$estimate_x, 10.5)
    expect_equal(res$estimate_y, 11.5)
    expect_equal(res$statistic, -0.54772, tolerance = 1e-4)
    expect_equal(res$df, 35.99889, tolerance = 1e-4)
    expect_equal(res$p_value, 0.58726, tolerance = 1e-4)
    expect_equal(res$n_x, 20)
    expect_equal(res$n_y, 18)
    expect_equal(res$conf_lo, -4.7028, tolerance = 1e-4)
    expect_equal(res$conf_hi, 2.7028, tolerance = 1e-4)
    expect_equal(res$stderr, 1.8257, tolerance = 1e-4)
    expect_equal(res$alternative, "two.sided")
    expect_equal(res$method, "Welch Two Sample t-test")
})
