test_that("numeric matrix", {
    m <- matrix(1:12 / 12, ncol = 2)
    res <- dig(m, function() 1)

    expect_equal(length(res), 4)
    expect_equal(res, rep(list(1), 4))
})


test_that("logical matrix", {
    m <- matrix(rep(c(T, F), 6), ncol = 2)
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

test_that("support arg", {
    m <- matrix(c(T,T,T,T,F,F, T,F,T,F,T,F), ncol = 2)
    res <- dig(m, function(support) list(sup = support))

    expect_equal(length(res), 4)
    expect_equal(res, list(list(sup = Inf),
                           list(sup = 4/6),
                           list(sup = 3/6),
                           list(sup = 2/6)))
})

test_that("indices arg", {
    m <- matrix(c(T,T,T,T,F,F, T,F,T,F,T,F), ncol = 2)
    res <- dig(m, function(indices) list(i = indices))

    expect_equal(length(res), 4)
    expect_equal(res, list(list(i = c(T,T,T,T,T,T)),
                           list(i = c(T,T,T,T,F,F)),
                           list(i = c(T,F,T,F,T,F)),
                           list(i = c(T,F,T,F,F,F))))
})

test_that("weights arg", {
    c1 <- c(0.0, 0.2, 0.4, 0.6, 0.8, 1.0)
    c2 <- c(0.5, 0.6, 0.7, 0.8, 0.9, 1.0)
    m <- matrix(c(c1, c2), ncol = 2)
    res <- dig(m, function(weights) list(w = weights))

    expect_equal(length(res), 4)
    expect_equal(res, list(list(w = c(1,1,1,1,1,1)),
                           list(w = c1),
                           list(w = c2),
                           list(w = c1 * c2)))
})


test_that("min_length filter", {
    m <- matrix(1:12 / 12, ncol = 2)

    res <- dig(m, function() 1, min_length = 0L)
    expect_equal(length(res), 4)

    res <- dig(m, function() 1, min_length = 1L)
    expect_equal(length(res), 3)

    res <- dig(m, function() 1, min_length = 2L)
    expect_equal(length(res), 1)

    res <- dig(m, function() 1, min_length = 3L)
    expect_equal(length(res), 0)
})


test_that("max_length filter", {
    m <- matrix(1:12 / 12, ncol = 2)

    res <- dig(m, function() 1, max_length = 0L)
    expect_equal(length(res), 1)

    res <- dig(m, function() 1, max_length = 1L)
    expect_equal(length(res), 3)

    res <- dig(m, function() 1, max_length = 2L)
    expect_equal(length(res), 4)

    res <- dig(m, function() 1, max_length = Inf)
    expect_equal(length(res), 4)
})


test_that("min_support filter", {
    m <- matrix(c(T,T,T,T,F,F, T,F,T,F,T,F), ncol = 2)

    res <- dig(m, function() 1, min_support = 0)
    expect_equal(length(res), 4)

    res <- dig(m, function() 1, min_support = 0.001)
    expect_equal(length(res), 4)

    res <- dig(m, function() 1, min_support = 0.5)
    expect_equal(length(res), 3)

    res <- dig(m, function() 1, min_support = 0.6)
    expect_equal(length(res), 2)

    res <- dig(m, function() 1, min_support = 1)
    expect_equal(length(res), 1)
})


test_that("disjoint filter", {
    m <- matrix(T, ncol = 3)

    res <- dig(m, function() 1)
    expect_equal(length(res), 8)

    res <- dig(m,
               function(condition) list(cond = condition),
               disjoint = c(1, 2, 3))

    expect_equal(length(res), 8)
    expect_equal(res, list(list(cond = integer(0)),
                           list(cond = c(1L)),
                           list(cond = c(2L)),
                           list(cond = c(3L)),
                           list(cond = c(1L, 3L)),
                           list(cond = c(2L, 3L)),
                           list(cond = c(1L, 2L)),
                           list(cond = c(1L, 2L, 3L))))

    res <- dig(m,
               function(condition) list(cond = condition),
               disjoint = c(1, 1, 2))

    expect_equal(length(res), 6)
    expect_equal(res, list(list(cond = integer(0)),
                           list(cond = c(1L)),
                           list(cond = c(2L)),
                           list(cond = c(3L)),
                           list(cond = c(1L, 3L)),
                           list(cond = c(2L, 3L))))

    res <- dig(m,
               function(condition) list(cond = condition),
               disjoint = c(1, 1, 1))

    expect_equal(length(res), 4)
    expect_equal(res, list(list(cond = integer(0)),
                           list(cond = c(1L)),
                           list(cond = c(2L)),
                           list(cond = c(3L))))
})
