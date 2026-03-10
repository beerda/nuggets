test_that("explore.correlations()", {
    .skip_if_shiny_not_installed()

    d <- partition(iris, Species)
    res <- dig_correlations(d,
                            condition = where(is.logical),
                            xvars = Sepal.Length:Petal.Width,
                            yvars = Sepal.Length:Petal.Width)

    # test run on some results
    expect_true(is_nugget(res))
    expect_true(nrow(res) > 0)

    app <- explore(res)
    expect_true(inherits(app, "shiny.appobj"))

    app <- explore(res, data = d)
    expect_true(inherits(app, "shiny.appobj"))

    # test run on empty results
    empty <- res[0, ]
    app <- explore(empty)
    expect_true(inherits(app, "shiny.appobj"))

    app <- explore(empty, data = d)
    expect_true(inherits(app, "shiny.appobj"))
})
