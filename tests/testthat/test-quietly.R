test_that("quietly error", {
    f <- function() {
        stop("a")
        1
    }

    expect_equal(.quietly(f()),
                 list(result = NULL,
                      comment = "error: a"))
})

test_that("quietly warning", {
    f <- function() {
        warn("a")
        1
    }

    expect_equal(.quietly(f()),
                 list(result = 1,
                      comment = "warning: a"))
})

test_that("quietly message", {
    f <- function() {
        message("a")
        1
    }

    expect_equal(.quietly(f()),
                 list(result = 1,
                      comment = "message: a"))
})

test_that("quietly normal execution", {
    f <- function() {
        1
    }

    expect_equal(.quietly(f()),
                 list(result = 1,
                      comment = ""))
})
