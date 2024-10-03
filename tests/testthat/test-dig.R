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


test_that("data frame", {
    d <- data.frame(a = 1:6 / 10,
                    b = c(T, T, T, F, F, F))
    res <- dig(d, function() 1)

    expect_equal(length(res), 4)
    expect_equal(res, rep(list(1), 4))
})


test_that("select condition columns", {
    m <- matrix(rep(c(T, F), 12), ncol = 3)

    res <- dig(m,
               f = function(condition) list(cond = condition),
               condition = c("1", "3"))

    expect_equal(length(res), 4)
    expect_equal(res, list(list(cond = integer(0)),
                           list(cond = c("1"=1L)),
                           list(cond = c("3"=3L)),
                           list(cond = c("1"=1L, "3"=3L))))
})


test_that("select condition columns with names", {
    m <- matrix(rep(c(T, F), 12), ncol = 3)
    colnames(m) <- c("aaah", "blee", "ciis")

    res <- dig(m,
               f = function(condition) list(cond = condition),
               condition = c("aaah", "ciis"))

    expect_equal(length(res), 4)
    expect_equal(res, list(list(cond = integer(0)),
                           list(cond = c("aaah"=1L)),
                           list(cond = c("ciis"=3L)),
                           list(cond = c("aaah"=1L, "ciis"=3L))))
})


test_that("condition arg", {
    m <- matrix(1:12 / 12, ncol = 2)
    res <- dig(m, function(condition) list(cond = condition))

    expect_equal(length(res), 4)
    expect_equal(res, list(list(cond = integer(0)),
                           list(cond = c("2"=2L)),
                           list(cond = c("1"=1L)),
                           list(cond = c("2"=2L, "1"=1L))))
})


test_that("condition arg with names", {
    m <- matrix(1:12 / 12, ncol = 2)
    colnames(m) <- c("aaah", "blee")
    res <- dig(m, function(condition) list(cond = condition))

    expect_equal(length(res), 4)
    expect_equal(res, list(list(cond = integer(0)),
                           list(cond = c("blee"=2L)),
                           list(cond = c("aaah"=1L)),
                           list(cond = c("blee"=2L, "aaah"=1L))))
})


test_that("support arg", {
    m <- matrix(c(T,T,T,T,F,F, T,F,T,F,T,F), ncol = 2)
    res <- dig(m, function(support) list(sup = support))

    expect_equal(length(res), 4)
    expect_equal(res, list(list(sup = 1),
                           list(sup = 4/6),
                           list(sup = 3/6),
                           list(sup = 2/6)),
                 tolerance = 1e-6)
})


test_that("sum arg", {
    m <- matrix(c(T,T,T,T,F,F, T,F,T,F,T,F), ncol = 2)
    res <- dig(m, function(sum) list(sum = sum))

    expect_equal(length(res), 4)
    expect_equal(res, list(list(sum = 6),
                           list(sum = 4),
                           list(sum = 3),
                           list(sum = 2)))
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
                           list(w = c2),
                           list(w = c1),
                           list(w = c1 * c2)),
                 tolerance = 1e-6)
})


test_that("foci_supports arg", {
    m <- matrix(c(T,T,T,T,F,F, T,F,T,F,T,F), ncol = 2)
    res <- dig(m,
               f = function(foci_supports) list(fs = foci_supports),
               condition = "1",
               focus = "2")

    expect_equal(length(res), 2)
    expect_equal(res, list(list(fs = c("2" = 3/6)),
                           list(fs = c("2" = 2/6))),
                 tolerance = 1e-6)
})


test_that("conti_pp arg", {
    m <- matrix(c(T,T,T,T,F,F, T,F,T,F,T,F), ncol = 2)
    res <- dig(m,
               f = function(conti_pp) list(fs = conti_pp),
               condition = "1",
               focus = "2")

    expect_equal(length(res), 2)
    expect_equal(res, list(list(fs = c("2" = 3/6)),
                           list(fs = c("2" = 2/6))),
                 tolerance = 1e-6)
})


test_that("conti_np arg", {
    m <- matrix(c(T,T,T,T,F,F, T,F,T,F,T,F), ncol = 2)
    res <- dig(m,
               f = function(conti_np) list(fs = conti_np),
               condition = "1",
               focus = "2")

    expect_equal(length(res), 2)
    expect_equal(res, list(list(fs = c("2" = 0/6)),
                           list(fs = c("2" = 1/6))),
                 tolerance = 1e-6)
})


test_that("conti_pn arg", {
    m <- matrix(c(T,T,T,T,F,F, T,F,T,F,F,F), ncol = 2)
    res <- dig(m,
               f = function(conti_pn) list(fs = conti_pn),
               condition = "1",
               focus = "2")

    expect_equal(length(res), 2)
    expect_equal(res, list(list(fs = c("2" = 4/6)),
                           list(fs = c("2" = 2/6))),
                 tolerance = 1e-6)
})


test_that("conti_nn arg", {
    m <- matrix(c(T,T,T,T,F,F, T,F,T,F,F,T), ncol = 2)
    res <- dig(m,
               f = function(conti_nn) list(fs = conti_nn),
               condition = "1",
               focus = "2")

    expect_equal(length(res), 2)
    expect_equal(res, list(list(fs = c("2" = 0/6)),
                           list(fs = c("2" = 1/6))),
                 tolerance = 1e-6)
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

    # disjoint 1, 2, 3
    res <- dig(m,
               function(condition) list(cond = condition),
               disjoint = c(1, 2, 3))

    expect_equal(length(res), 8)
    expect_equal(res, list(list(cond = integer(0)),
                           list(cond = c("1"=1L)),
                           list(cond = c("2"=2L)),
                           list(cond = c("3"=3L)),
                           list(cond = c("1"=1L, "3"=3L)),
                           list(cond = c("2"=2L, "3"=3L)),
                           list(cond = c("1"=1L, "2"=2L)),
                           list(cond = c("1"=1L, "2"=2L, "3"=3L))))

    # disjoint 1, 1, 2
    res <- dig(m,
               function(condition) list(cond = condition),
               disjoint = c(1, 1, 2))

    expect_equal(length(res), 6)
    expect_equal(res, list(list(cond = integer(0)),
                           list(cond = c("1"=1L)),
                           list(cond = c("2"=2L)),
                           list(cond = c("3"=3L)),
                           list(cond = c("1"=1L, "3"=3L)),
                           list(cond = c("2"=2L, "3"=3L))))

    # disjoint 1, 1, 1
    res <- dig(m,
               function(condition) list(cond = condition),
               disjoint = c(1, 1, 1))

    expect_equal(length(res), 4)
    expect_equal(res, list(list(cond = integer(0)),
                           list(cond = c("1"=1L)),
                           list(cond = c("2"=2L)),
                           list(cond = c("3"=3L))))


    # disjoint 1, 1, 2 with condition and focus
    m <- m[, c(1:3, 1:3), drop = FALSE]
    res <- dig(m,
               function(condition) list(cond = condition),
               disjoint = c(1, 1, 2, 3, 4, 5),
               condition = 1:3,
               focus = 4:6)

    expect_equal(length(res), 6)
    expect_equal(res, list(list(cond = integer(0)),
                           list(cond = c("1"=1L)),
                           list(cond = c("2"=2L)),
                           list(cond = c("3"=3L)),
                           list(cond = c("1"=1L, "3"=3L)),
                           list(cond = c("2"=2L, "3"=3L))))
})


test_that("conditions and foci are disjoint", {
    d <- data.frame(a = c(T,    T, T, F, F),
                    b = c(T,    F, T, T, T),
                    c = c(T,    T, F, F, F),
                    d = c(T,    F, F, F, F))

    f <- function(condition, foci_supports) {
        paste(paste(sort(names(condition)), collapse = "&"),
              "~",
              paste(names(foci_supports), collapse = "|"))
    }

    expected <- c(" ~ a|b|c|d",
                  "a ~ c|d",
                  "b ~ c|d",
                  "c ~ a|b|d",
                  "d ~ a|b|c",
                  "a&c ~ d",
                  "a&d ~ c",
                  "b&c ~ d",
                  "b&d ~ c",
                  "c&d ~ a|b",
                  "a&c&d ~ ",
                  "b&c&d ~ ")

    res <- dig(d,
               f,
               condition = everything(),
               focus = everything(),
               disjoint = c(1, 1, 2, 3))
    res <- unlist(res)

    expect_equal(sort(res), sort(expected))
})


test_that("conditions and foci are disjoint even if disjoints are not defined", {
    d <- data.frame(a = c(T,    T, T, F, F),
                    b = c(T,    F, T, T, T),
                    c = c(T,    T, F, F, F))

    f <- function(condition, foci_supports) {
        paste(paste(sort(names(condition)), collapse = "&"),
              "~",
              paste(names(foci_supports), collapse = "|"))
    }

    expected <- c(" ~ a|b|c",
                  "a ~ b|c",
                  "b ~ a|c",
                  "c ~ a|b",
                  "a&b ~ c",
                  "a&c ~ b",
                  "b&c ~ a",
                  "a&b&c ~ ")

    res <- dig(d,
               f,
               condition = everything(),
               focus = everything(),
               disjoint = NULL)
    res <- unlist(res)

    expect_equal(sort(res), sort(expected))
})


test_that("data frame select & disjoint", {
    set.seed(32344)

    d <- data.frame(a = c(T,    T, T, F, F),
                    b = c(T,    F, T, T, T),
                    c = c(T,    T, F, F, F),
                    d = c(T,    F, F, F, F),
                    x = c(1.0,  0.1, 0.2, 0.3, 0.4),
                    y = c(1.0,  0.9, 0.8, 0.7, 0.6),
                    z = c(1.0,  0.8, 0.6, 0.4, 0.2),
                    w = c(1.0,  0, 0, 0, 0))

    f <- function(condition, support) {
        paste(paste(sort(names(condition)), collapse = " & "),
              "=",
              round(support, 2))
    }

    disjoint <- c(1, 1, 2, 3,  5, 5, 6, 7)

    expected <- c("a = 0.6", "b = 0.8", "c = 0.4", "x = 0.4", "y = 0.8", "z = 0.6",
                  "a & c = 0.4", "a & x = 0.26", "a & y = 0.54", "a & z = 0.48",
                  "b & c = 0.2", "b & x = 0.38", "b & y = 0.62", "b & z = 0.44",
                  "c & x = 0.22", "c & y = 0.38", "c & z = 0.36",
                  "x & z = 0.28",
                  "y & z = 0.52")

    # permutation 1
    perm <- seq_along(d)
    res <- dig(d[, perm],
               f,
               condition = c(a, b, c, x, y, z),
               disjoint = disjoint[perm],
               min_length = 1,
               max_length = 2)
    expect_equal(sort(unlist(res)), sort(expected))

    # permutation 2
    perm <- sample(perm)
    res <- dig(d[, perm],
               f,
               condition = c(a, b, c, x, y, z),
               disjoint = disjoint[perm],
               min_length = 1,
               max_length = 2)
    expect_equal(sort(unlist(res)), sort(expected))

    # permutation 3
    perm <- sample(perm)
    res <- dig(d[, perm],
               f,
               condition = c(a, b, c, x, y, z),
               disjoint = disjoint[perm],
               min_length = 1,
               max_length = 2)
    expect_equal(sort(unlist(res)), sort(expected))

    # permuted condition 1
    res <- dig(d[, perm],
               f,
               condition = c(x, y, z, a, b, c),
               disjoint = disjoint[perm],
               min_length = 1,
               max_length = 2)
    expect_equal(sort(unlist(res)), sort(expected))

    # permuted condition 2
    res <- dig(d[, perm],
               f,
               condition = c(x, a, y, b, z, c),
               disjoint = disjoint[perm],
               min_length = 1,
               max_length = 2)
    expect_equal(sort(unlist(res)), sort(expected))
})


test_that("t-norm goedel", {
    c1 <- c(0.0, 0.2, 0.4, 0.6, 0.8, 1.0)
    c2 <- c(0.5, 0.6, 0.7, 0.8, 0.9, 1.0)
    m <- matrix(c(c1, c2), ncol = 2)

    res <- dig(m,
               function(weights) list(w = weights),
               min_length = 2,
               t_norm = "goedel")
    expect_equal(length(res), 1)
    expect_equal(res, list(list(w = pmin(c1, c2))),
                 tolerance = 1e-6)
})


test_that("t-norm goguen", {
    c1 <- c(0.0, 0.2, 0.4, 0.6, 0.8, 1.0)
    c2 <- c(0.5, 0.6, 0.7, 0.8, 0.9, 1.0)
    m <- matrix(c(c1, c2), ncol = 2)

    res <- dig(m,
               function(weights) list(w = weights),
               min_length = 2,
               t_norm = "goguen")
    expect_equal(length(res), 1)
    expect_equal(res, list(list(w = c1 * c2)),
                 tolerance = 1e-6)
})


test_that("t-norm lukas", {
    c1 <- c(0.0, 0.2, 0.4, 0.6, 0.8, 1.0)
    c2 <- c(0.5, 0.6, 0.7, 0.8, 0.9, 1.0)
    m <- matrix(c(c1, c2), ncol = 2)

    res <- dig(m,
               function(weights) list(w = weights),
               min_length = 2,
               t_norm = "lukas")
    expect_equal(length(res), 1)
    expect_equal(res, list(list(w = pmax(0, c1 + c2 - 1))),
                 tolerance = 1e-6)
})


test_that("multithread", {
    m <- matrix(T, ncol = 10, nrow=100)

    res <- dig(m, function() 1, threads = 24)
    expect_equal(length(res), 1024)
})


test_that("min_focus_support & filter_empty_foci", {
    m <- matrix(c(c(1,1,1,1,1,1,1,1,0,0),
                  c(1,1,1,1,1,1,0,0,1,1),
                  c(0,0,0,1,1,1,1,1,1,1),
                  c(0,0,0,0,1,1,1,1,1,1)), ncol = 4)

    f <- function(condition, foci_supports) {
       paste(paste(condition, collapse = " & "),
             "=",
             paste(round(foci_supports, 1), collapse = ", "))
    }

    res <- dig(m,
               f,
               condition = 1:2,
               focus = 3:4,
               min_support = 0.1,
               min_focus_support = 0.5,
               filter_empty_foci = FALSE)

    expect_equal(unlist(res), c(" = 0.7, 0.6", "1 = 0.5", "2 = 0.5", "1 & 2 = "))

    res <- dig(m,
               f,
               condition = 1:2,
               focus = 3:4,
               min_support = 0.1,
               min_focus_support = 0.5,
               filter_empty_foci = TRUE)

    expect_equal(unlist(res), c(" = 0.7, 0.6", "1 = 0.5", "2 = 0.5"))
})
