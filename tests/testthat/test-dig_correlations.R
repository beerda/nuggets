test_that("dig_correlations", {
    set.seed(2123)
    d <- data.frame(a = TRUE,
                    b = c(TRUE, FALSE),
                    x = rnorm(100),
                    y = rnorm(100),
                    z = rnorm(100))
    res <- dig_correlations(x = d,
                            method = "pearson",
                            alternative = "two.sided",
                            condition = where(is.logical),
                            xvars = where(is.numeric),
                            yvars = where(is.numeric))

    expect_true(is_nugget(res, flavour = "correlations"))
    res <- res[order(res$condition_length, res$condition), ]

    expect_true(is_tibble(res))
    expect_equal(nrow(res), 12)
    expect_equal(colnames(res),
                 c("condition", "support", "xvar", "yvar", "estimate", "p_value", "method", "alternative", "rows", "condition_length"))
    expect_equal(res$condition,
                 c(rep("{}", 3), rep("{a}", 3), rep("{b}", 3), rep("{a,b}", 3)))
    expect_equal(res$xvar,
                 rep(c("x", "x", "y"), 4))
    expect_equal(res$yvar,
                 rep(c("y", "z", "z"), 4))
    expect_equal(res$support,
                 c(rep(100, 6), rep(50, 6)) / 100)
    expect_equal(res$method,
                 rep("Pearson's product-moment correlation", 12))
    expect_equal(res$alternative,
                 rep("two.sided", 12))
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

    expect_true(is_nugget(res, flavour = "correlations"))
    res <- res[order(res$condition_length, res$condition), ]

    expect_true(is_tibble(res))
    expect_equal(nrow(res), 12)
    expect_equal(colnames(res),
                 c("condition", "support", "xvar", "yvar", "estimate", "p_value", "method", "alternative", "rows", "condition_length"))
    expect_equal(res$condition,
                 c(rep("{}", 3), rep("{a}", 3), rep("{b}", 3), rep("{a,b}", 3)))
    expect_equal(res$xvar,
                 rep(c("x", "x", "y"), 4))
    expect_equal(res$yvar,
                 rep(c("y", "z", "z"), 4))
    expect_equal(res$support,
                 c(rep(100, 6), rep(50, 6)) / 100)
    expect_equal(res$method,
                 rep("Pearson's product-moment correlation", 12))
    expect_equal(res$alternative,
                 rep("two.sided", 12))
    expect_equal(res$rows,
                 c(98, 99, 99,
                   98, 99, 99,
                   49, 49, 50,
                   49, 49, 50))
})


test_that("dig_correlations iris", {
    dcor <- partition(iris, Species)

    res <- dig_correlations(dcor, max_length = 0)
    expect_true(is_nugget(res, flavour = "correlations"))
    expect_true(is_tibble(res))
    expect_equal(nrow(res), 6)

    res <- dig_correlations(dcor,
                            xvars = Sepal.Length:Petal.Width,
                            yvars = Sepal.Length:Petal.Width,
                            max_length = 0)
    expect_true(is_nugget(res, flavour = "correlations"))
    expect_true(is_tibble(res))
    expect_equal(nrow(res), 6)

    res <- dig_correlations(dcor,
                            xvars = Sepal.Length:Petal.Width,
                            yvars = Sepal.Length:Petal.Width,
                            condition = NULL)
    expect_true(is_nugget(res, flavour = "correlations"))
    expect_true(is_tibble(res))
    expect_equal(nrow(res), 6)
})


test_that("dig_correlations call args", {
    set.seed(2123)
    d <- data.frame(a = TRUE,
                    b = c(TRUE, FALSE),
                    x = rnorm(100),
                    y = rnorm(100),
                    z = rnorm(100))

    res <- dig_correlations(x = d,
                            condition = where(is.logical),
                            xvars = x:y,
                            yvars = y:z,
                            disjoint = c("a", "b", "x", "y", "z"),
                            excluded = list("a"),
                            method = "spearman",
                            alternative = "greater",
                            exact = TRUE,
                            min_length = 1L,
                            max_length = 2L,
                            min_support = 0.1,
                            max_support = 0.9,
                            max_results = 100,
                            verbose = TRUE,
                            threads = 1)
    expect_true(is_nugget(res, flavour = "correlations"))
    expect_true(is_tibble(res))
    expect_equal(attr(res, "call_function"), "dig_correlations")
    expect_true(is.list(attr(res, "call_data")))
    expect_equal(attr(res, "call_data")$nrow, nrow(d))
    expect_equal(attr(res, "call_data")$ncol, ncol(d))
    expect_equal(attr(res, "call_data")$colnames, as.character(colnames(d)))
    expect_true(is.list(attr(res, "call_args")))
    expect_equal(attr(res, "call_args")$x, "d")
    expect_equal(attr(res, "call_args")$condition, c("a", "b"))
    expect_equal(attr(res, "call_args")$xvars, c("x", "y"))
    expect_equal(attr(res, "call_args")$yvars, c("y", "z"))
    expect_equal(attr(res, "call_args")$disjoint, c("a", "b", "x", "y", "z"))
    expect_equal(attr(res, "call_args")$excluded, list("a"))
    expect_equal(attr(res, "call_args")$method, "spearman")
    expect_equal(attr(res, "call_args")$alternative, "greater")
    expect_equal(attr(res, "call_args")$exact, TRUE)
    expect_equal(attr(res, "call_args")$min_length, 1L)
    expect_equal(attr(res, "call_args")$max_length, 2L)
    expect_equal(attr(res, "call_args")$min_support, 0.1)
    expect_equal(attr(res, "call_args")$max_support, 0.9)
    expect_equal(attr(res, "call_args")$max_results, 100)
    expect_equal(attr(res, "call_args")$verbose, TRUE)
    expect_equal(attr(res, "call_args")$threads, 1)
})


test_that("errors", {
    d <- data.frame(n = 1:5 / 5, l = TRUE, i = 1:5, s = letters[1:5])

    expect_true(is.list(dig_correlations(d, condition = c(l))))
    expect_error(dig_correlations(d, condition = c(l, n)),
                 "All columns selected by `condition` must be logical.")
    expect_error(dig_correlations(d, condition = c(l, s)),
                 "All columns selected by `condition` must be logical.")
})
