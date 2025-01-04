test_that(".var_test error", {
    expect_warning(res <- .var_test(NULL, 2),
                   "var.test: error: not enough 'x' observations")
    expect_null(res)
})

test_that(".var_test max p-value not reached", {
    x <- 1:20
    y <- 20:1
    expect_null(.var_test(x = x, y = y, max_p_value = 0.05))
})

test_that(".var_test two-sample", {
    x <- 1:20
    y <- 3:20

    res <- .var_test(x = x,
                     y = y,
                     alternative = "two.sided")

    expect_true(is.list(res))
    expect_equal(length(res), 10)
    expect_equal(res$estimate, 1.228, tolerance = 1e-4)
    expect_equal(res$statistic, 1.228, tolerance = 1e-4)
    expect_equal(res$p_value, 0.67511, tolerance = 1e-4)
    expect_equal(res$n_x, 20)
    expect_equal(res$n_y, 18)
    expect_equal(res$conf_lo, 0.46639, tolerance = 1e-4)
    expect_equal(res$conf_hi, 3.1524, tolerance = 1e-4)
    expect_equal(res$alternative, "two.sided")
    expect_equal(res$method, "F test to compare two variances")
    expect_equal(res$comment, "")
})
