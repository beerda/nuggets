test_that(".geom_diamond_setup_data (label = null, fill = null)", {
    d <- data.frame(
        condition = c("{}", "{a=1}", "{b=2}", "{a=1, b=2}", "{b=2, a=3}", "{b=2, a=4}"),
        stringsAsFactors = FALSE
    )
    params <- list(nudge_x = 0.2, nudge_y = -0.3)

    res <- .geom_diamond_setup_data(d, params)
    expect_true(is.data.frame(res))
    expect_true(is.null(res$fill))
    expect_equal(res$condition,
                 c("{}", "{a=1}", "{b=2}", "{a=1, b=2}", "{b=2, a=3}", "{b=2, a=4}"))
    expect_equal(res$formula,
                 c("-", "a=1", "b=2", "a=1, b=2", "a=3, b=2", "a=4, b=2"))
    expect_equal(res$label,
                 c("-", "a=1", "b=2", "a=1, b=2", "a=3, b=2", "a=4, b=2"))
    expect_equal(res$x,
                 c(0.0, -0.5, 0.5, -1.0, 0.0, 1.0))
    expect_equal(res$y,
                 c(2, 1, 1, 0, 0, 0))
    expect_equal(res$xlabel,
                 0.2 + c(0.0, -0.5, 0.5, -1.0, 0.0, 1.0))
    expect_equal(res$ylabel,
                 -0.3 + c(2, 1, 1, 0, 0, 0))
    expect_equal(res$xmin,
                 c(0.0, -0.5, 0.5, -1.0, 0.0, 1.0))
    expect_equal(res$xmax,
                 0.2 + c(0.0, -0.5, 0.5, -1.0, 0.0, 1.0))
    expect_equal(res$ymin,
                 -0.3 + c(2, 1, 1, 0, 0, 0))
    expect_equal(res$ymax,
                 c(2, 1, 1, 0, 0, 0))
    #expect_equal(res$linewidth,
                 #rep(0, 6))
})

test_that(".geom_diamond_setup_data (label = non-null, fill = non-null)", {
    d <- data.frame(
        condition = c("{}", "{a=1}", "{b=2}", "{a=1, b=2}", "{b=2, a=3}", "{b=2, a=4}"),
        label = c("empty", "a1", "b2", "a1b2", "b2a3", "b2a4"),
        fill = c(1, 1.5, 2, 1, 2, 0.5),
        stringsAsFactors = FALSE
    )
    params <- list(nudge_x = 0.2, nudge_y = -0.3)

    res <- .geom_diamond_setup_data(d, params)
    expect_true(is.data.frame(res))
    expect_equal(res$condition,
                 c("{}", "{a=1}", "{b=2}", "{a=1, b=2}", "{b=2, a=3}", "{b=2, a=4}"))
    expect_equal(res$formula,
                 c("-", "a=1", "b=2", "a=1, b=2", "a=3, b=2", "a=4, b=2"))
    expect_equal(res$label,
                 c("empty", "a1", "b2", "a1b2", "b2a3", "b2a4"))
    expect_equal(res$fill,
                 c(1, 1.5, 2, 1, 2, 0.5))
    #expect_equal(res$linewidth,
                 #c(1, 1.5, 2, 1, 2, 0.5))
})

test_that(".geom_diamond_create_edges", {
    x <- c(0.0, -0.5, 0.5, -1.0, 0.0, 1.0)
    y <- c(2.0,  1.0, 1.0,  0.0, 0.0, 0.0)
    d <- data.frame(
        #               1       2        3             4             5             6
        condition = c("{}", "{a=1}", "{b=2}", "{a=1, b=2}", "{b=2, a=3}", "{b=2, a=4}"),
        x = x,
        y = y,
        linewidth_orig = rep(0, 6),
        stringsAsFactors = FALSE
    )

    res <- .geom_diamond_create_edges(d, linetype = "foo")
    expect_true(is.data.frame(res))
    expect_equal(res$row,
                 c(1, 1, 2, 3, 3, 3))
    expect_equal(res$col,
                 c(2, 3, 4, 4, 5, 6))
    expect_equal(res$x,
                 x[c(1, 1, 2, 3, 3, 3)])
    expect_equal(res$xend,
                 x[c(2, 3, 4, 4, 5, 6)])
    expect_equal(res$y,
                 y[c(1, 1, 2, 3, 3, 3)])
    expect_equal(res$yend,
                 y[c(2, 3, 4, 4, 5, 6)])
    expect_equal(res$curvature,
                 rep(0, 6))
    expect_equal(res$alpha,
                 rep(NA, 6))
    expect_equal(res$group,
                 rep(1, 6))
    expect_equal(res$linetype,
                 rep("foo", 6))
    expect_equal(res$colour,
                 rep("#000000", 6))
    expect_equal(res$linewidth,
                 rep(0.0, 6))
})

test_that("geom_diamond aes", {
    d <- data.frame(
        condition = c("{}", "{a}", "{b}", "{a, b}", "{b, c}"),
        aa = c(1,1,1,2,2),
        bb = c(1,2,3,1,2),
        cc = c(1,1,2,2,2),
        dd = factor(c("a", "b", "b", "a", "a")),
        fill = c(1.5, 2.0, 3.0, 1.0, 2.0),
        stringsAsFactors = FALSE
    )

    expect_error({
        pdf(NULL); on.exit(dev.off(), add = TRUE)
        g <- ggplot(d) +
            geom_diamond()
        print(g)
    }, "requires the following missing aesthetics: condition")

    expect_no_error({
        pdf(NULL); on.exit(dev.off(), add = TRUE)
        g <- ggplot(d) +
            aes(condition = condition) +
            geom_diamond()
        print(g)
    })

    expect_no_error({
        pdf(NULL); on.exit(dev.off(), add = TRUE)
        g <- ggplot(d) +
            geom_diamond(aes(condition = condition))
        print(g)
    })

    expect_no_error({
        pdf(NULL); on.exit(dev.off(), add = TRUE)
        g <- ggplot(d) +
            aes(condition = condition, label = condition, colour = aa,
                size = bb, shape = dd, fill = aa, alpha = bb, stroke = cc) +
            geom_diamond()
        print(g)
    })

    expect_no_error({
        pdf(NULL); on.exit(dev.off(), add = TRUE)
        g <- ggplot(d) +
            geom_diamond(aes(condition = condition, label = condition, colour = aa,
                             size = bb, shape = dd, fill = aa, alpha = bb, stroke = cc))
        print(g)
    })
})

test_that("geom_diamond error on duplicate entries", {
    d <- data.frame(
        condition = c("{}", "{a}", "{b}", "{a}", "{b, c}"),
        stringsAsFactors = FALSE
    )

    expect_error({
        pdf(NULL); on.exit(dev.off(), add = TRUE)
        g <- ggplot(d) +
            aes(condition = condition) +
            geom_diamond()
        print(g)
    }, "contains duplicate values")


    d <- data.frame(
        condition = c("{}", "{a}", "{b}", "{c, b}", "{b, c}"),
        stringsAsFactors = FALSE
    )

    expect_error({
        pdf(NULL); on.exit(dev.off(), add = TRUE)
        g <- ggplot(d) +
            aes(condition = condition) +
            geom_diamond()
        print(g)
    }, "contains duplicate values")
})
