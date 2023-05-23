test_that("empty arg", {
    m <- matrix(1:12 / 12, ncol = 2)
    res <- dig(m, function() 1)

    expect_equal(length(res), 4)
    expect_equal(res, rep(list(1), 4))
})


test_that("condition arg", {
    m <- matrix(1:12 / 12, ncol = 2)
    res <- dig(m, function(condition) list(cond = condition))

    expect_equal(length(res), 4)
    expect_equal(res, list(list(cond = integer(0)),
                           list(cond = c(1L)),
                           list(cond = c(2L)),
                           list(cond = c(1L, 2L))))
})

test_that("max_length filter", {
    m <- matrix(1:12 / 12, ncol = 2)

    res <- dig(m, function() 1, max_length = 0L)
    expect_equal(length(res), 1)

    res <- dig(m, function() 1, max_length = 1L)
    expect_equal(length(res), 3)

    res <- dig(m, function() 1, max_length = 2L)
    expect_equal(length(res), 4)

    res <- dig(m, function() 1, max_length = -1L)
    expect_equal(length(res), 4)
})
