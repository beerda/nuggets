test_that("explore.associations()", {
    .skip_if_shiny_not_installed()

    cars <- mtcars |>
        partition(cyl, vs:gear, .method = "dummy") |>
        partition(carb, .method = "crisp", .breaks = c(0, 3, 10)) |>
        partition(mpg, disp:qsec, .method = "triangle", .breaks = 3)

    rules <- dig_associations(cars,
                              antecedent = everything(),
                              consequent = everything(),
                              max_length = 1,
                              min_support = 0.1)

    # test run on some antecents
    expect_true(is_nugget(rules))
    expect_true(nrow(rules) > 0)
    expect_true(length(unique(rules$antecedent)) > 1)

    app <- explore(rules)
    expect_true(inherits(app, "shiny.appobj"))

    app <- explore(rules, data = cars)
    expect_true(inherits(app, "shiny.appobj"))

    # test run on empty antecedents
    rules <- rules[rules$antecedent == "{}", ]
    expect_true(is_nugget(rules))
    expect_true(nrow(rules) > 0)
    expect_true(length(unique(rules$antecedent)) == 1)

    app <- explore(rules)
    expect_true(inherits(app, "shiny.appobj"))

    app <- explore(rules, data = cars)
    expect_true(inherits(app, "shiny.appobj"))

    # test run on empty rules
    rules <- rules[0, ]
    app <- explore(rules)
    expect_true(inherits(app, "shiny.appobj"))

    app <- explore(rules, data = cars)
    expect_true(inherits(app, "shiny.appobj"))
})
