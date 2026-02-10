test_that("plot_contingency", {
    g <- plot_contingency(1, 2, 3, 4)
    expect_s3_class(g, "ggplot")

    expect_error(plot_contingency("1", 2, 3, 4), "`pp` must be a double scalar.")
    expect_error(plot_contingency(1, "2", 3, 4), "`pn` must be a double scalar.")
    expect_error(plot_contingency(1, 2, "3", 4), "`np` must be a double scalar.")
    expect_error(plot_contingency(1, 2, 3, "4"), "`nn` must be a double scalar.")
    expect_error(plot_contingency(-1, 2, 3, 4), "`pp` must be >= 0.")
    expect_error(plot_contingency(1, -2, 3, 4), "`pn` must be >= 0.")
    expect_error(plot_contingency(1, 2, -3, 4), "`np` must be >= 0.")
    expect_error(plot_contingency(1, 2, 3, -4), "`nn` must be >= 0.")

    g <- plot_contingency(data.frame(pp = 1, pn = 2, np = 3, nn = 4, foo = "bar"))
    expect_s3_class(g, "ggplot")

    expect_error(plot_contingency(data.frame(pp = 1, np = 3, nn = 4, foo = "bar", bar = "baz")),
                 "The data frame must have columns named pp, pn, np, and nn.")

    expect_error(plot_contingency(data.frame(pp = 1:2, pn = 8:9, np = 3:4, nn = 4:5)),
                 "The data frame must have exactly one row.")
})
