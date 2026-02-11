test_that("plot_contingency", {
    expect_no_error({
        pdf(NULL); on.exit(dev.off(), add = TRUE)
        g <- plot_contingency(1, 2, 3, 4)
        expect_s3_class(g, "ggplot")
        print(g)
    })

    expect_error({
        pdf(NULL); on.exit(dev.off(), add = TRUE)
        g <- plot_contingency("1", 2, 3, 4)
        print(g)
    }, "`pp` must be a double scalar.")

    expect_error({
        pdf(NULL); on.exit(dev.off(), add = TRUE)
        g <- plot_contingency(1, "2", 3, 4)
        print(g)
    }, "`pn` must be a double scalar.")

    expect_error({
        pdf(NULL); on.exit(dev.off(), add = TRUE)
        g <- plot_contingency(1, 2, "3", 4)
        print(g)
    }, "`np` must be a double scalar.")

    expect_error({
        pdf(NULL); on.exit(dev.off(), add = TRUE)
        g <- plot_contingency(1, 2, 3, "4")
        print(g)
    }, "`nn` must be a double scalar.")

    expect_error({
        pdf(NULL); on.exit(dev.off(), add = TRUE)
        g <- plot_contingency(-1, 2, 3, 4)
        print(g)
    }, "`pp` must be >= 0.")

    expect_error({
        pdf(NULL); on.exit(dev.off(), add = TRUE)
        g <- plot_contingency(1, -2, 3, 4)
        print(g)
    }, "`pn` must be >= 0.")

    expect_error({
        pdf(NULL); on.exit(dev.off(), add = TRUE)
        g <- plot_contingency(1, 2, -3, 4)
        print(g)
    }, "`np` must be >= 0.")

    expect_error({
        pdf(NULL); on.exit(dev.off(), add = TRUE)
        g <- plot_contingency(1, 2, 3, -4)
        print(g)
    }, "`nn` must be >= 0.")

    expect_no_error({
        pdf(NULL); on.exit(dev.off(), add = TRUE)
        g <- plot_contingency(data.frame(pp = 1, pn = 2, np = 3, nn = 4, foo = "bar"))
        expect_s3_class(g, "ggplot")
        print(g)
    })

    expect_error({
        pdf(NULL); on.exit(dev.off(), add = TRUE)
        g <- plot_contingency(data.frame(pp = 1, np = 3, nn = 4, foo = "bar", bar = "baz"))
        print(g)
    }, "The data frame must have columns named pp, pn, np, and nn.")

    expect_error({
        pdf(NULL); on.exit(dev.off(), add = TRUE)
        g <- plot_contingency(data.frame(pp = 1:2, pn = 8:9, np = 3:4, nn = 4:5))
        print(g)
    }, "The data frame must have exactly one row.")
})
