test_that("dig_correlations", {
    set.seed(2123)
    d <- data.frame(a = TRUE,
                    b = c(TRUE, FALSE),
                    x = rnorm(100),
                    y = rnorm(100),
                    z = rnorm(100))
    res <- dig_correlations(x = d,
                            condition = where(is.logical),
                            xvars = where(is.numeric),
                            yvars = where(is.numeric))

    expect_true(is_tibble(res))
    expect_equal(nrow(res), 12)
    expect_equal(colnames(res),
                 c("condition", "xvar", "yvar", "estimate", "p_value"))
    expect_equal(res$condition,
                 c(rep("{}", 3), rep("{a}", 3), rep("{b}", 3), rep("{a,b}", 3)))
    expect_equal(res$xvar,
                 rep(c("x", "x", "y"), 4))
    expect_equal(res$yvar,
                 rep(c("y", "z", "z"), 4))
})


test_that("dig_correlations iris", {
    dcor <- dichotomize(iris, what = Species, .other = TRUE)
    res <- dig_correlations(dcor, max_length = 0)

    expect_true(is_tibble(res))
    expect_equal(nrow(res), 6)

    res <- dig_correlations(dcor,
                            xvars = Sepal.Length:Petal.Width,
                            yvars = Sepal.Length:Petal.Width,
                            max_length = 0)
})
