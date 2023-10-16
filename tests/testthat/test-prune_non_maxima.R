test_that("prune_non_maxima", {
    comp <- function(x, y) {
        ax <- as.character(x)
        ay <- as.character(y)

        res <- 0L
        if (nchar(ax) == nchar(ay)) {
            res <- sign(x - y)
        }

        res
    }

    expect_equal(prune_non_maxima(list(), comp),
                 list())

    expect_equal(prune_non_maxima(as.list(c(1:5, 13:18, 105:109)), comp),
                 list(5, 18, 109))

    expect_equal(prune_non_maxima(as.list(c(1:5, 18:13, 105:109)), comp),
                 list(5, 18, 109))

    expect_equal(prune_non_maxima(as.list(c(5:1, 18:13, 108:102, 109)), comp),
                 list(5, 18, 109))
})
