test_that("var_grid everything on data.frame", {
    d <- data.frame(v = FALSE,
                    w = FALSE,
                    x = TRUE,
                    y = c(TRUE, FALSE),
                    z = c(TRUE, FALSE))

    res <- var_grid(d,
                    xvars = everything(),
                    yvars = everything())

    expect_true(is_tibble(res))
    expect_equal(nrow(res), 10)
    expect_equal(colnames(res), c("xvar", "yvar"))
    expect_equal(res$xvar, c("v", "v", "v", "v", "w", "w", "w", "x", "x", "y"))
    expect_equal(res$yvar, c("w", "x", "y", "z", "x", "y", "z", "y", "z", "z"))
    expect_equal(attr(res, "xvars"), c("v", "w", "x", "y", "z"))
    expect_equal(attr(res, "yvars"), c("v", "w", "x", "y", "z"))
})

test_that("var_grid everything on data.frame (with custom colnames)", {
    d <- data.frame(v = FALSE,
                    w = FALSE,
                    x = TRUE,
                    y = c(TRUE, FALSE),
                    z = c(TRUE, FALSE))

    res <- var_grid(d,
                    xvars = everything(),
                    yvars = everything(),
                    xvar_name = "blaX",
                    yvar_name = "blaY")

    expect_true(is_tibble(res))
    expect_equal(nrow(res), 10)
    expect_equal(colnames(res), c("blaX", "blaY"))
    expect_equal(res$blaX, c("v", "v", "v", "v", "w", "w", "w", "x", "x", "y"))
    expect_equal(res$blaY, c("w", "x", "y", "z", "x", "y", "z", "y", "z", "z"))
    expect_equal(attr(res, "xvars"), c("v", "w", "x", "y", "z"))
    expect_equal(attr(res, "yvars"), c("v", "w", "x", "y", "z"))
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
    expect_equal(attr(res, "xvars"), c("v", "w", "x"))
    expect_equal(attr(res, "yvars"), c("z"))
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
    expect_equal(attr(res, "xvars"), c("v"))
    expect_equal(attr(res, "yvars"), c("x"))
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
    expect_equal(attr(res, "xvars"), c("v", "w", "x", "y", "z"))
    expect_equal(attr(res, "yvars"), c("v", "w", "x", "y", "z"))
})

test_that("var_grid only xvar", {
    d <- data.frame(v = FALSE,
                    w = FALSE,
                    x = TRUE,
                    y = c(TRUE, FALSE),
                    z = c(TRUE, FALSE))

    res <- var_grid(d,
                    xvars = everything(),
                    yvars = NULL)

    expect_true(is_tibble(res))
    expect_equal(nrow(res), 5)
    expect_equal(colnames(res), "var")
    expect_equal(res$var, c("v", "w", "x", "y", "z"))
    expect_equal(attr(res, "xvars"), c("v", "w", "x", "y", "z"))
    expect_null(attr(res, "yvars"))
})

test_that("var_grid with disjoint", {
    d <- data.frame(v = FALSE,
                    w = FALSE,
                    x = TRUE,
                    y = c(TRUE, FALSE),
                    z = c(TRUE, FALSE))

    res <- var_grid(d,
                    xvars = everything(),
                    yvars = everything())

    expect_true(is_tibble(res))
    expect_equal(nrow(res), 10)
    expect_equal(colnames(res), c("xvar", "yvar"))
    expect_equal(res$xvar, c("v", "v", "v", "v", "w", "w", "w", "x", "x", "y"))
    expect_equal(res$yvar, c("w", "x", "y", "z", "x", "y", "z", "y", "z", "z"))
    expect_equal(attr(res, "xvars"), c("v", "w", "x", "y", "z"))
    expect_equal(attr(res, "yvars"), c("v", "w", "x", "y", "z"))

    res <- var_grid(d,
                    xvars = everything(),
                    yvars = everything(),
                    disjoint = c("vw", "vw", "xyz", "xyz", "xyz"))

    expect_equal(nrow(res), 6)
    expect_equal(colnames(res), c("xvar", "yvar"))
    expect_equal(res$xvar, c("v", "v", "v", "w", "w", "w"))
    expect_equal(res$yvar, c("x", "y", "z", "x", "y", "z"))
    expect_equal(attr(res, "xvars"), c("v", "w", "x", "y", "z"))
    expect_equal(attr(res, "yvars"), c("v", "w", "x", "y", "z"))
})

test_that("var_grid errors", {
    d <- data.frame(v = FALSE,
                    w = FALSE,
                    x = TRUE,
                    y = c(TRUE, FALSE),
                    z = c(TRUE, FALSE))
    d2 <- data.frame(n = 1:5 / 5, l = TRUE, i = 1:5, s = letters[1:5])

    expect_error(var_grid(d, xvars = where(is.numeric), yvars = x),
                 "`xvars` must select non-empty list of columns")
    expect_error(var_grid(d, yvars = where(is.numeric), xvars = x),
                 "`yvars` must select non-empty list of columns")
    expect_error(var_grid(d, xvars = x, yvars = x),
                 "`xvars` and `yvars` can't select the same single column")
    expect_error(var_grid(d2, xvars = n, yvars = l, allow = "numeric"),
                 "All columns selected by `yvars` must be numeric.")
    expect_error(var_grid(d2, xvars = s, yvars = n, allow = "numeric"),
                 "All columns selected by `xvars` must be numeric.")
    expect_error(var_grid(list(a = 1, b = 2),
                          xvars = everything(),
                          yvars = everything()),
                 "`x` must be a matrix or a data frame")

    expect_error(var_grid(d, xvars = everything(), yvars = everything(),
                          disjoint = list("x")),
                 "`disjoint` must be a plain vector")
    expect_error(var_grid(d, xvars = everything(), yvars = everything(),
                          disjoint = "x"),
                 "The length of `disjoint` must be 0 or must be equal to the number of columns in `x`.")
})
