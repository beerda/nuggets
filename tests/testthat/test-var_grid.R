test_that("var_grid everything on data.frame", {
    d <- data.frame(v = FALSE,
                    w = FALSE,
                    x = TRUE,
                    y = c(TRUE, FALSE),
                    z = c(TRUE, FALSE))

    res <- var_grid(d, xvars = everything(), yvars = everything())

    expect_true(is_tibble(res))
    expect_equal(nrow(res), 10)
    expect_equal(colnames(res), c("xvar", "yvar"))
    expect_equal(res$xvar, c("v", "v", "v", "v", "w", "w", "w", "x", "x", "y"))
    expect_equal(res$yvar, c("w", "x", "y", "z", "x", "y", "z", "y", "z", "z"))
})

test_that("var_grid selected on data.frame", {
    d <- data.frame(v = FALSE,
                    w = FALSE,
                    x = TRUE,
                    y = c(TRUE, FALSE),
                    z = c(TRUE, FALSE))

    res <- var_grid(d, xvars = v:x, yvars = z)

    expect_true(is_tibble(res))
    expect_equal(nrow(res), 3)
    expect_equal(colnames(res), c("xvar", "yvar"))
    expect_equal(res$xvar, c("v", "w", "x"))
    expect_equal(res$yvar, c("z", "z", "z"))
})

test_that("var_grid single on data.frame", {
    d <- data.frame(v = FALSE,
                    w = FALSE,
                    x = TRUE,
                    y = c(TRUE, FALSE),
                    z = c(TRUE, FALSE))

    res <- var_grid(d, xvars = v, yvars = x)

    expect_true(is_tibble(res))
    expect_equal(nrow(res), 1)
    expect_equal(colnames(res), c("xvar", "yvar"))
    expect_equal(res$xvar, c("v"))
    expect_equal(res$yvar, c("x"))
})

test_that("var_grid everything on matrix", {
    m <- matrix(0, nrow = 5, ncol = 5)
    colnames(m) <- c("v", "w", "x", "y", "z")

    res <- var_grid(m, xvars = everything(), yvars = everything())

    expect_true(is_tibble(res))
    expect_equal(nrow(res), 10)
    expect_equal(colnames(res), c("xvar", "yvar"))
    expect_equal(res$xvar, c("v", "v", "v", "v", "w", "w", "w", "x", "x", "y"))
    expect_equal(res$yvar, c("w", "x", "y", "z", "x", "y", "z", "y", "z", "z"))
})
