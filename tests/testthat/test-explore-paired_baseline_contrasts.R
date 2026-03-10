test_that("explore.paired_baseline_contrasts()", {
    .skip_if_shiny_not_installed()

    crispIris <- iris
    crispIris$Sepal.Ratio <- iris$Sepal.Length / iris$Sepal.Width
    crispIris$Petal.Ratio <- iris$Petal.Length / iris$Petal.Width
    crispIris <- partition(crispIris, Species)

    res <- dig_paired_baseline_contrasts(crispIris,
                                         condition = where(is.logical),
                                         xvars = Sepal.Ratio,
                                         yvars = Petal.Ratio,
                                         method = "t",
                                         min_support = 0.1)

    # test run on some results
    expect_true(is_nugget(res))
    expect_true(nrow(res) > 0)

    app <- explore(res)
    expect_true(inherits(app, "shiny.appobj"))

    app <- explore(res, data = crispIris)
    expect_true(inherits(app, "shiny.appobj"))

    # test run on empty results
    empty <- res[0, ]
    app <- explore(empty)
    expect_true(inherits(app, "shiny.appobj"))

    app <- explore(empty, data = crispIris)
    expect_true(inherits(app, "shiny.appobj"))
})
