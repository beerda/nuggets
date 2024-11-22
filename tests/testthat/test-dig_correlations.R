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
                 c("condition", "support", "xvar", "yvar", "estimate", "p_value", "rows"))
    expect_equal(res$condition,
                 c(rep("{}", 3), rep("{a}", 3), rep("{b}", 3), rep("{a,b}", 3)))
    expect_equal(res$xvar,
                 rep(c("x", "x", "y"), 4))
    expect_equal(res$yvar,
                 rep(c("y", "z", "z"), 4))
    expect_equal(res$support,
                 c(rep(100, 6), rep(50, 6)) / 100)
    expect_equal(res$rows,
                 c(rep(100, 6), rep(50, 6)))
})


test_that("dig_correlations with NA", {
    set.seed(2123)
    d <- data.frame(a = TRUE,
                    b = c(TRUE, FALSE),
                    x = rnorm(100),
                    y = rnorm(100),
                    z = rnorm(100))
    d[1, "x"] <- NA
    d[2, "y"] <- NA

    res <- dig_correlations(x = d,
                            condition = where(is.logical),
                            xvars = where(is.numeric),
                            yvars = where(is.numeric))

    expect_true(is_tibble(res))
    expect_equal(nrow(res), 12)
    expect_equal(colnames(res),
                 c("condition", "support", "xvar", "yvar", "estimate", "p_value", "rows"))
    expect_equal(res$condition,
                 c(rep("{}", 3), rep("{a}", 3), rep("{b}", 3), rep("{a,b}", 3)))
    expect_equal(res$xvar,
                 rep(c("x", "x", "y"), 4))
    expect_equal(res$yvar,
                 rep(c("y", "z", "z"), 4))
    expect_equal(res$support,
                 c(rep(100, 6), rep(50, 6)) / 100)
    expect_equal(res$rows,
                 c(98, 99, 99,
                   98, 99, 99,
                   49, 49, 50,
                   49, 49, 50))
})


test_that("dig_correlations iris", {
    dcor <- partition(iris, Species)
    res <- dig_correlations(dcor, max_length = 0)

    expect_true(is_tibble(res))
    expect_equal(nrow(res), 6)

    res <- dig_correlations(dcor,
                            xvars = Sepal.Length:Petal.Width,
                            yvars = Sepal.Length:Petal.Width,
                            max_length = 0)
})


test_that("errors", {
    d <- data.frame(n = 1:5 / 5, l = TRUE, i = 1:5, s = letters[1:5])

    expect_true(is.list(dig_correlations(d, condition = c(l))))
    expect_error(dig_correlations(d, condition = c(l, n)),
                 "columns selected by .* must be logical.")
    expect_error(dig_correlations(d, condition = c(l, s)),
                 "columns selected by .* must be logical.")
})
