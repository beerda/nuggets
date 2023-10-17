test_that("which_incomparable", {
    f <- function(x, y) {
        ax <- as.character(x)
        ay <- as.character(y)

        nchar(ax) == nchar(ay)
    }

    expect_equal(which_incomparable(list(), f),
                 integer(0))
    expect_equal(which_incomparable(list(1, 5, 7), f),
                 c(1))
    expect_equal(which_incomparable(list(1, 5, 7, 10), f),
                 c(1, 4))
    expect_equal(which_incomparable(list(100, 5, 7, 10), f),
                 c(1, 2, 4))

})
