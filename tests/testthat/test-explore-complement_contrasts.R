test_that("explore.complement_contrasts()", {
    .skip_if_shiny_not_installed()

    d <- partition(mtcars, .breaks = 2, .keep = TRUE)
    res <- suppressWarnings({
        dig_complement_contrasts(d,
                                 condition = where(is.logical),
                                 vars = where(is.numeric),
                                 min_support = 0.3,
                                 max_length = 2)
    })

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
