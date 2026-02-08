#######################################################################
# nuggets: An R framework for exploration of patterns in data
# Copyright (C) 2025 Michal Burda
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program. If not, see <https://www.gnu.org/licenses/>.
#######################################################################


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

test_that("geom_diamond of single rule with empty condition", {
    d <- data.frame(
        condition = c("{}"),
        stringsAsFactors = FALSE
    )

    expect_no_error({
        pdf(NULL); on.exit(dev.off(), add = TRUE)
        g <- ggplot(d) +
            aes(condition = condition) +
            geom_diamond()
        print(g)
    })
})

test_that(".geom_diamond_draw_panel returns gList", {
    # Prepare data that has been processed by setup_data
    x <- c(0.0, -0.5, 0.5)
    y <- c(2.0, 1.0, 1.0)
    d <- data.frame(
        condition = c("{}", "{a=1}", "{b=2}"),
        x = x,
        y = y,
        xlabel = x + 0.125,
        ylabel = y + 0.125,
        linewidth_orig = rep(0.5, 3),
        label = c("-", "a=1", "b=2"),
        colour = rep("black", 3),
        size = rep(1, 3),
        shape = rep(21, 3),
        fill = rep("white", 3),
        alpha = rep(NA, 3),
        stroke = rep(1, 3),
        stringsAsFactors = FALSE
    )
    
    # Create mock panel_params and coord (these are ggplot internals)
    panel_params <- list()
    coord <- ggplot2::coord_cartesian()
    
    # Call the function
    result <- .geom_diamond_draw_panel(d, panel_params, coord)
    
    # Verify result is a gList
    expect_true(inherits(result, "gList"))
    
    # Verify it contains elements (at least point and label)
    expect_true(length(result) > 0)
})

test_that(".geom_diamond_draw_panel with edges (no curvature)", {
    # Create data with parent-child relationships (no curvature needed)
    x <- c(0.0, 0.0)
    y <- c(1.0, 0.0)
    d <- data.frame(
        condition = c("{a=1}", "{a=1, b=2}"),
        x = x,
        y = y,
        xlabel = x + 0.125,
        ylabel = y + 0.125,
        linewidth_orig = rep(0.5, 2),
        label = c("a=1", "a=1, b=2"),
        colour = rep("black", 2),
        size = rep(1, 2),
        shape = rep(21, 2),
        fill = rep("white", 2),
        alpha = rep(NA, 2),
        stroke = rep(1, 2),
        stringsAsFactors = FALSE
    )
    
    panel_params <- list()
    coord <- ggplot2::coord_cartesian()
    
    result <- .geom_diamond_draw_panel(d, panel_params, coord,
                                       linetype = "solid")
    
    expect_true(inherits(result, "gList"))
    expect_true(length(result) > 0)
})

test_that(".geom_diamond_draw_panel with custom parameters", {
    x <- c(0.0, -0.5, 0.5)
    y <- c(2.0, 1.0, 1.0)
    d <- data.frame(
        condition = c("{}", "{a=1}", "{b=2}"),
        x = x,
        y = y,
        xlabel = x + 0.2,
        ylabel = y - 0.3,
        linewidth_orig = rep(0.5, 3),
        label = c("-", "a=1", "b=2"),
        colour = rep("black", 3),
        size = rep(1, 3),
        shape = rep(21, 3),
        fill = rep("white", 3),
        alpha = rep(NA, 3),
        stroke = rep(1, 3),
        stringsAsFactors = FALSE
    )
    
    panel_params <- list()
    coord <- ggplot2::coord_cartesian()
    
    # Test with custom linewidth and linetype
    result <- .geom_diamond_draw_panel(d, panel_params, coord,
                                       linetype = "dashed",
                                       linewidth = 1.5,
                                       nudge_x = 0.2,
                                       nudge_y = -0.3)
    
    expect_true(inherits(result, "gList"))
})

test_that(".geom_diamond_draw_panel with na.rm parameter", {
    x <- c(0.0, -0.5, 0.5)
    y <- c(2.0, 1.0, 1.0)
    d <- data.frame(
        condition = c("{}", "{a=1}", "{b=2}"),
        x = x,
        y = y,
        xlabel = x,
        ylabel = y,
        linewidth_orig = rep(0.5, 3),
        label = c("-", "a=1", "b=2"),
        colour = rep("black", 3),
        size = rep(1, 3),
        shape = rep(21, 3),
        fill = rep("white", 3),
        alpha = rep(NA, 3),
        stroke = rep(1, 3),
        stringsAsFactors = FALSE
    )
    
    panel_params <- list()
    coord <- ggplot2::coord_cartesian()
    
    # Test with na.rm = TRUE
    result <- .geom_diamond_draw_panel(d, panel_params, coord, na.rm = TRUE)
    expect_true(inherits(result, "gList"))
    
    # Test with na.rm = FALSE
    result <- .geom_diamond_draw_panel(d, panel_params, coord, na.rm = FALSE)
    expect_true(inherits(result, "gList"))
})

test_that(".geom_diamond_draw_panel with edges having different curvatures", {
    # Create a more complex lattice with edges that will have different curvatures
    x <- c(0.0, -0.5, 0.5, -1.0, 0.0, 1.0)
    y <- c(2.0, 1.0, 1.0, 0.0, 0.0, 0.0)
    d <- data.frame(
        condition = c("{}", "{a=1}", "{b=2}", "{a=1, b=2}", "{b=2, a=3}", "{b=2, a=4}"),
        x = x,
        y = y,
        xlabel = x + 0.125,
        ylabel = y + 0.125,
        linewidth_orig = rep(0.5, 6),
        label = c("-", "a=1", "b=2", "a=1, b=2", "a=3, b=2", "a=4, b=2"),
        colour = rep("black", 6),
        size = rep(1, 6),
        shape = rep(21, 6),
        fill = rep("white", 6),
        alpha = rep(NA, 6),
        stroke = rep(1, 6),
        stringsAsFactors = FALSE
    )
    
    panel_params <- list()
    coord <- ggplot2::coord_cartesian()
    
    result <- .geom_diamond_draw_panel(d, panel_params, coord)
    
    # Should produce a gList with curves, points, and labels
    expect_true(inherits(result, "gList"))
    expect_true(length(result) > 0)
})

test_that(".geom_diamond_draw_panel with varying linewidth", {
    # Test with different linewidth values to trigger edge styling
    x <- c(0.0, 0.0, 0.0)
    y <- c(2.0, 1.0, 0.0)
    d <- data.frame(
        condition = c("{}", "{a=1}", "{a=1, b=2}"),
        x = x,
        y = y,
        xlabel = x,
        ylabel = y,
        linewidth_orig = c(1.0, 2.0, 3.0),
        label = c("-", "a=1", "a=1, b=2"),
        colour = rep("black", 3),
        size = rep(1, 3),
        shape = rep(21, 3),
        fill = rep("white", 3),
        alpha = rep(NA, 3),
        stroke = rep(1, 3),
        stringsAsFactors = FALSE
    )
    
    panel_params <- list()
    coord <- ggplot2::coord_cartesian()
    
    result <- .geom_diamond_draw_panel(d, panel_params, coord)
    
    expect_true(inherits(result, "gList"))
})

test_that(".geom_diamond_draw_panel with empty edges", {
    # Single node with no edges
    d <- data.frame(
        condition = "{a=1}",
        x = 0.0,
        y = 0.0,
        xlabel = 0.125,
        ylabel = 0.125,
        linewidth_orig = 0.5,
        label = "a=1",
        colour = "black",
        size = 1,
        shape = 21,
        fill = "white",
        alpha = NA,
        stroke = 1,
        stringsAsFactors = FALSE
    )
    
    panel_params <- list()
    coord <- ggplot2::coord_cartesian()
    
    result <- .geom_diamond_draw_panel(d, panel_params, coord)
    
    # Should still return a valid gList (with point and label, but no edges)
    expect_true(inherits(result, "gList"))
    expect_true(length(result) > 0)
})
