test_that("numeric matrix", {
    m <- matrix(1:12 / 12, ncol = 2)
    res <- dig(m, function() 1)

    expect_true(is_nugget(res))
    expect_true(is.list(res))
    expect_equal(length(res), 4)

    attributes(res) <- NULL
    expect_equal(res, rep(list(1), 4))
})


test_that("logical matrix", {
    m <- matrix(T, ncol = 4, nrow = 10)
    res <- dig(m, function() 1)

    expect_true(is_nugget(res))
    expect_true(is.list(res))
    expect_equal(length(res), 16)

    attributes(res) <- NULL
    expect_equal(res, rep(list(1), 16))
})


test_that("logical matrix", {
    m <- matrix(rep(c(T, F), 6), ncol = 2)
    res <- dig(m, function() 1)

    expect_true(is_nugget(res))
    expect_true(is.list(res))
    expect_equal(length(res), 4)

    attributes(res) <- NULL
    expect_equal(res, rep(list(1), 4))
})


test_that("data frame", {
    d <- data.frame(a = 1:6 / 10,
                    b = c(T, T, T, F, F, F))
    res <- dig(d, function() 1)

    expect_true(is_nugget(res))
    expect_true(is.list(res))
    expect_equal(length(res), 4)

    attributes(res) <- NULL
    expect_equal(res, rep(list(1), 4))
})


test_that("max_results limiting", {
    d <- data.frame(a = 1:6 / 10,
                    b = c(T, T, T, F, F, F))

    res <- dig(d, function() 1, max_results = Inf)
    expect_equal(length(res), 4)

    res <- dig(d, function() 1, max_results = 1)
    expect_equal(length(res), 1)

    res <- dig(d, function() 1, max_results = 2)
    expect_equal(length(res), 2)

    res <- dig(d, function() 1, max_results = 4)
    expect_equal(length(res), 4)

    res <- dig(d, function() 1, max_results = 10)
    expect_equal(length(res), 4)
})


test_that("select condition columns", {
    m <- matrix(rep(c(T, F), 12), ncol = 3)

    res <- dig(m,
               f = function(condition) list(cond = condition),
               condition = c("1", "3"))

    expect_true(is_nugget(res))
    expect_true(is.list(res))
    expect_equal(length(res), 4)
    expect_equal(attr(res, "call_function"), "dig")
    expect_true(is.list(attr(res, "call_args")));
    expect_equal(attr(res, "call_args")$condition, c("1", "3"))

    attributes(res) <- NULL
    expect_setequal(res, list(list(cond = integer(0)),
                              list(cond = c("1"=1L)),
                              list(cond = c("1"=1L, "3"=3L)),
                              list(cond = c("3"=3L))))
})


test_that("select condition columns with names", {
    m <- matrix(rep(c(T, F), 12), ncol = 3)
    colnames(m) <- c("aaah", "blee", "ciis")

    res <- dig(m,
               f = function(condition) list(cond = condition),
               condition = c("aaah", "ciis"))

    expect_true(is_nugget(res))
    expect_true(is.list(res))
    expect_equal(length(res), 4)
    expect_equal(attr(res, "call_function"), "dig")
    expect_true(is.list(attr(res, "call_args")));
    expect_equal(attr(res, "call_args")$condition, c("aaah", "ciis"))
    expect_setequal(res, list(list(cond = integer(0)),
                              list(cond = c("aaah"=1L)),
                              list(cond = c("aaah"=1L, "ciis"=3L)),
                              list(cond = c("ciis"=3L))))
})


test_that("condition arg", {
    m <- matrix(1:12 / 12, ncol = 2)
    res <- dig(m, function(condition) list(cond = condition))

    expect_true(is_nugget(res))
    expect_true(is.list(res))
    expect_equal(length(res), 4)
    expect_setequal(res, list(list(cond = integer(0)),
                              list(cond = c("1"=1L)),
                              list(cond = c("2"=2L, "1"=1L)),
                              list(cond = c("2"=2L))))
})


test_that("condition arg with names", {
    m <- matrix(1:12 / 12, ncol = 2)
    colnames(m) <- c("aaah", "blee")
    res <- dig(m, function(condition) list(cond = condition))

    expect_true(is_nugget(res))
    expect_true(is.list(res))
    expect_equal(length(res), 4)
    expect_setequal(res, list(list(cond = integer(0)),
                              list(cond = c("aaah"=1L)),
                              list(cond = c("blee"=2L, "aaah"=1L)),
                              list(cond = c("blee"=2L))))
})


test_that("support arg", {
    m <- matrix(c(T,T,T,T,F,F, T,F,T,F,T,F), ncol = 2)
    res <- dig(m, function(support) list(sup = support))

    expect_true(is_nugget(res))
    expect_true(is.list(res))
    expect_equal(length(res), 4)

    res <- res[order(unlist(res), decreasing = TRUE)]
    expect_equal(res, list(list(sup = 1),
                           list(sup = 4/6),
                           list(sup = 3/6),
                           list(sup = 2/6)),
                 tolerance = 1e-6)
})


test_that("sum arg", {
    m <- matrix(c(T,T,T,T,F,F, T,F,T,F,T,F), ncol = 2)
    res <- dig(m, function(condition, sum) list(sum = sum))

    expect_true(is_nugget(res))
    expect_true(is.list(res))
    expect_equal(length(res), 4)

    res <- res[order(unlist(res), decreasing = TRUE)]
    expect_setequal(res, list(list(sum = 6),
                              list(sum = 4),
                              list(sum = 3),
                              list(sum = 2)))
})


test_that("indices arg", {
    m <- matrix(c(T,T,T,T,F,F, T,F,T,F,T,F), ncol = 2)
    res <- dig(m, function(indices) list(i = indices))

    expect_true(is_nugget(res))
    expect_true(is.list(res))
    expect_equal(length(res), 4)

    res <- res[order(sapply(res, function(x) sum(x$i)), decreasing = TRUE)]
    expect_setequal(res, list(list(i = c(T,T,T,T,T,T)),
                              list(i = c(T,T,T,T,F,F)),
                              list(i = c(T,F,T,F,T,F)),
                              list(i = c(T,F,T,F,F,F))))
})


test_that("weights arg", {
    c1 <- c(0.0, 0.2, 0.4, 0.6, 0.8, 1.0)
    c2 <- c(0.5, 0.6, 0.7, 0.8, 0.9, 1.0)
    m <- matrix(c(c1, c2), ncol = 2)
    res <- dig(m, function(weights) list(w = weights))

    expect_true(is_nugget(res))
    expect_true(is.list(res))
    expect_equal(length(res), 4)

    attributes(res) <- NULL
    expect_equal(res, list(list(w = c(1,1,1,1,1,1)),
                           list(w = c2),
                           list(w = c1 * c2),
                           list(w = c1)),
                 tolerance = 1e-6)
})


test_that("foci_supports arg", {
    m <- matrix(c(T,T,T,T,F,F, T,F,T,F,T,F), ncol = 2)
    res <- dig(m,
               f = function(foci_supports) list(fs = foci_supports),
               condition = "1",
               focus = "2")

    expect_true(is_nugget(res))
    expect_true(is.list(res))
    expect_equal(attr(res, "call_function"), "dig")
    expect_true(is.list(attr(res, "call_args")));
    expect_equal(attr(res, "call_args")$condition, "1")
    expect_equal(attr(res, "call_args")$focus, "2")

    attributes(res) <- NULL
    expect_equal(length(res), 2)
    expect_equal(res, list(list(fs = c("2" = 3/6)),
                           list(fs = c("2" = 2/6))),
                 tolerance = 1e-6)
})


test_that("pp arg", {
    m <- matrix(c(T,T,T,T,F,F, T,F,T,F,T,F), ncol = 2)
    res <- dig(m,
               f = function(pp) list(fs = pp),
               condition = "1",
               focus = "2")

    attributes(res) <- NULL
    expect_equal(length(res), 2)
    expect_equal(res, list(list(fs = c("2" = 3)),
                           list(fs = c("2" = 2))),
                 tolerance = 1e-6)
})


test_that("np arg", {
    m <- matrix(c(T,T,T,T,F,F, T,F,T,F,T,F), ncol = 2)
    res <- dig(m,
               f = function(np) list(fs = np),
               condition = "1",
               focus = "2")

    attributes(res) <- NULL
    expect_equal(length(res), 2)
    expect_equal(res, list(list(fs = c("2" = 0)),
                           list(fs = c("2" = 1))),
                 tolerance = 1e-6)
})


test_that("pn arg", {
    m <- matrix(c(T,T,T,T,F,F, T,F,T,F,F,F), ncol = 2)
    res <- dig(m,
               f = function(pn) list(fs = pn),
               condition = "1",
               focus = "2")

    attributes(res) <- NULL
    expect_equal(length(res), 2)
    expect_equal(res, list(list(fs = c("2" = 4)),
                           list(fs = c("2" = 2))),
                 tolerance = 1e-6)
})


test_that("nn arg", {
    m <- matrix(c(T,T,T,T,F,F, T,F,T,F,F,T), ncol = 2)
    res <- dig(m,
               f = function(nn) list(fs = nn),
               condition = "1",
               focus = "2")

    attributes(res) <- NULL
    expect_equal(length(res), 2)
    expect_equal(res, list(list(fs = c("2" = 0)),
                           list(fs = c("2" = 1))),
                 tolerance = 1e-6)
})


test_that("complex contingency table test (logical)", {
    set.seed(234)
    cols <- 5
    rows <- 65
    m <- matrix(sample(c(T, F), cols * rows, TRUE), nrow = rows)
    colnames(m) <- letters[seq_len(cols)]

    a <- m[, "a"]
    b <- m[, "b"]
    c <- m[, "c"]
    d <- m[, "d"]
    e <- m[, "e"]

    res <- dig(m,
               f = function(condition, pp, pn, np, nn) {
                   list(cond = format_condition(sort(colnames(m)[condition])),
                        a_pp = pp[1], a_pn = pn[1], a_np = np[1], a_nn = nn[1],
                        b_pp = pp[2], b_pn = pn[2], b_np = np[2], b_nn = nn[2])
               },
               condition = c:e,
               focus = a:b)
    res <- lapply(res, as.data.frame)
    res <- do.call(rbind, res)
    rownames(res) <- res$cond
    res$cond <- NULL

    expect_true(is.data.frame(res))
    expect_equal(nrow(res), 8)
    expect_equal(ncol(res), 8)

    expect_equal(res["{}", "a_pp"], sum(a), tolerance = 1e-6)
    expect_equal(res["{}", "a_pn"], sum(!a), tolerance = 1e-6)
    expect_equal(res["{}", "a_np"], 0, tolerance = 1e-6)
    expect_equal(res["{}", "a_nn"], 0, tolerance = 1e-6)

    expect_equal(res["{}", "b_pp"], sum(b), tolerance = 1e-6)
    expect_equal(res["{}", "b_pn"], sum(!b), tolerance = 1e-6)
    expect_equal(res["{}", "b_np"], 0, tolerance = 1e-6)
    expect_equal(res["{}", "b_nn"], 0, tolerance = 1e-6)

    expect_equal(res["{d}", "a_pp"], sum(d & a), tolerance = 1e-6)
    expect_equal(res["{d}", "a_pn"], sum(d & !a), tolerance = 1e-6)
    expect_equal(res["{d}", "a_np"], sum(!d & a), tolerance = 1e-6)
    expect_equal(res["{d}", "a_nn"], sum(!d & !a), tolerance = 1e-6)

    expect_equal(res["{d}", "b_pp"], sum(d & b), tolerance = 1e-6)
    expect_equal(res["{d}", "b_pn"], sum(d & !b), tolerance = 1e-6)
    expect_equal(res["{d}", "b_np"], sum(!d & b), tolerance = 1e-6)
    expect_equal(res["{d}", "b_nn"], sum(!d & !b), tolerance = 1e-6)

    expect_equal(res["{d,e}", "a_pp"], sum(e & d & a), tolerance = 1e-6)
    expect_equal(res["{d,e}", "a_pn"], sum(e & d & !a), tolerance = 1e-6)
    expect_equal(res["{d,e}", "a_np"], sum(!(e & d) & a), tolerance = 1e-6)
    expect_equal(res["{d,e}", "a_nn"], sum(!(e & d) & !a), tolerance = 1e-6)

    expect_equal(res["{d,e}", "b_pp"], sum(e & d & b), tolerance = 1e-6)
    expect_equal(res["{d,e}", "b_pn"], sum(e & d & !b), tolerance = 1e-6)
    expect_equal(res["{d,e}", "b_np"], sum(!(e & d) & b), tolerance = 1e-6)
    expect_equal(res["{d,e}", "b_nn"], sum(!(e & d) & !b), tolerance = 1e-6)

    expect_equal(res["{c,d,e}", "a_pp"], sum(e & c & d & a), tolerance = 1e-6)
    expect_equal(res["{c,d,e}", "a_pn"], sum(e & c & d & !a), tolerance = 1e-6)
    expect_equal(res["{c,d,e}", "a_np"], sum(!(e & c & d) & a), tolerance = 1e-6)
    expect_equal(res["{c,d,e}", "a_nn"], sum(!(e & c & d) & !a), tolerance = 1e-6)

    expect_equal(res["{c,d,e}", "b_pp"], sum(e & c & d & b), tolerance = 1e-6)
    expect_equal(res["{c,d,e}", "b_pn"], sum(e & c & d & !b), tolerance = 1e-6)
    expect_equal(res["{c,d,e}", "b_np"], sum(!(e & c & d) & b), tolerance = 1e-6)
    expect_equal(res["{c,d,e}", "b_nn"], sum(!(e & c & d) & !b), tolerance = 1e-6)
})


test_that("complex contingency table test (numeric)", {
    set.seed(234)
    cols <- 5
    rows <- 65
    m <- matrix(sample(c(0:10) / 10, cols * rows, TRUE), nrow = rows)
    colnames(m) <- letters[seq_len(cols)]

    a <- m[, "a"]
    b <- m[, "b"]
    c <- m[, "c"]
    d <- m[, "d"]
    e <- m[, "e"]

    res <- dig(m,
               f = function(condition, pp, pn, np, nn) {
                   list(cond = format_condition(sort(colnames(m)[condition])),
                        a_pp = pp[1], a_pn = pn[1], a_np = np[1], a_nn = nn[1],
                        b_pp = pp[2], b_pn = pn[2], b_np = np[2], b_nn = nn[2])
               },
               condition = c:e,
               focus = a:b,
               t_norm = "goedel")
    res <- lapply(res, as.data.frame)
    res <- do.call(rbind, res)
    rownames(res) <- res$cond
    res$cond <- NULL

    expect_true(is.data.frame(res))
    expect_equal(nrow(res), 8)
    expect_equal(ncol(res), 8)

    expect_equal(res["{}", "a_pp"], sum(a), tolerance = 1e-2)
    expect_equal(res["{}", "a_pn"], sum(1 - a), tolerance = 1e-2)
    expect_equal(res["{}", "a_np"], 0, tolerance = 1e-2)
    expect_equal(res["{}", "a_nn"], 0, tolerance = 1e-2)

    expect_equal(res["{}", "b_pp"], sum(b), tolerance = 1e-2)
    expect_equal(res["{}", "b_pn"], sum(1 - b), tolerance = 1e-2)
    expect_equal(res["{}", "b_np"], 0, tolerance = 1e-2)
    expect_equal(res["{}", "b_nn"], 0, tolerance = 1e-2)

    pp <- sum(pmin(d, a))
    expect_equal(res["{d}", "a_pp"], pp, tolerance = 1e-2)
    expect_equal(res["{d}", "a_pn"], sum(d) - pp, tolerance = 1e-2)
    expect_equal(res["{d}", "a_np"], sum(a) - pp, tolerance = 1e-2)
    expect_equal(res["{d}", "a_nn"], nrow(m) - sum(d) - sum(a) + pp, tolerance = 1e-1)

    pp <- sum(pmin(d, b))
    expect_equal(res["{d}", "b_pp"], pp, tolerance = 1e-2)
    expect_equal(res["{d}", "b_pn"], sum(d) - pp, tolerance = 1e-2)
    expect_equal(res["{d}", "b_np"], sum(b) - pp, tolerance = 1e-2)
    expect_equal(res["{d}", "b_nn"], nrow(m) - sum(d) - sum(b) + pp, tolerance = 1e-1)

    pp <- sum(pmin(e, d, a))
    expect_equal(res["{d,e}", "a_pp"], pp, tolerance = 1e-1)
    expect_equal(res["{d,e}", "a_pn"], sum(pmin(e, d)) - pp, tolerance = 1e-2)
    expect_equal(res["{d,e}", "a_np"], sum(a) - pp, tolerance = 1e-2)
    expect_equal(res["{d,e}", "a_nn"], nrow(m) - sum(pmin(e, d)) - sum(a) + pp, tolerance = 1e-2)

    pp <- sum(pmin(e, d, b))
    expect_equal(res["{d,e}", "b_pp"], pp, tolerance = 1e-1)
    expect_equal(res["{d,e}", "b_pn"], sum(pmin(e, d)) - pp, tolerance = 1e-2)
    expect_equal(res["{d,e}", "b_np"], sum(b) - pp, tolerance = 1e-2)
    expect_equal(res["{d,e}", "b_nn"], nrow(m) - sum(pmin(e, d)) - sum(b) + pp, tolerance = 1e-2)

    pp <- sum(pmin(e, d, c, a))
    expect_equal(res["{c,d,e}", "a_pp"], pp, tolerance = 1e-1)
    expect_equal(res["{c,d,e}", "a_pn"], sum(pmin(e, c, d)) - pp, tolerance = 1e-2)
    expect_equal(res["{c,d,e}", "a_np"], sum(a) - pp, tolerance = 1e-2)
    expect_equal(res["{c,d,e}", "a_nn"], nrow(m) - sum(pmin(c, d, e)) - sum(a) + pp, tolerance = 1e-2)

    pp <- sum(pmin(e, d, c, b))
    expect_equal(res["{c,d,e}", "b_pp"], pp, tolerance = 1e-1)
    expect_equal(res["{c,d,e}", "b_pn"], sum(pmin(e, c, d)) - pp, tolerance = 1e-2)
    expect_equal(res["{c,d,e}", "b_np"], sum(b) - pp, tolerance = 1e-2)
    expect_equal(res["{c,d,e}", "b_nn"], nrow(m) - sum(pmin(c, d, e)) - sum(b) + pp, tolerance = 1e-2)
})


test_that("min_length filter", {
    m <- matrix(1:12 / 12, ncol = 2)

    res <- dig(m, function() 1, min_length = 0L)
    expect_true(is_nugget(res))
    expect_true(is.list(res))
    expect_equal(attr(res, "call_function"), "dig")
    expect_true(is.list(attr(res, "call_args")));
    expect_equal(attr(res, "call_args")$min_length, 0L)
    expect_equal(length(res), 4)

    res <- dig(m, function() 1, min_length = 1L)
    expect_true(is_nugget(res))
    expect_true(is.list(res))
    expect_equal(attr(res, "call_function"), "dig")
    expect_true(is.list(attr(res, "call_args")));
    expect_equal(attr(res, "call_args")$min_length, 1L)
    expect_equal(length(res), 3)

    res <- dig(m, function() 1, min_length = 2L)
    expect_true(is_nugget(res))
    expect_true(is.list(res))
    expect_equal(attr(res, "call_function"), "dig")
    expect_true(is.list(attr(res, "call_args")));
    expect_equal(attr(res, "call_args")$min_length, 2L)
    expect_equal(length(res), 1)

    res <- dig(m, function() 1, min_length = 3L)
    expect_true(is_nugget(res))
    expect_true(is.list(res))
    expect_equal(attr(res, "call_function"), "dig")
    expect_true(is.list(attr(res, "call_args")));
    expect_equal(attr(res, "call_args")$min_length, 3L)
    expect_equal(length(res), 0)
})


test_that("max_length filter", {
    m <- matrix(1:12 / 12, ncol = 2)

    res <- dig(m, function() 1, max_length = 0L)
    expect_true(is_nugget(res))
    expect_true(is.list(res))
    expect_equal(attr(res, "call_function"), "dig")
    expect_true(is.list(attr(res, "call_args")));
    expect_equal(attr(res, "call_args")$max_length, 0L)
    expect_equal(length(res), 1)

    res <- dig(m, function() 1, max_length = 1L)
    expect_true(is_nugget(res))
    expect_true(is.list(res))
    expect_equal(attr(res, "call_function"), "dig")
    expect_true(is.list(attr(res, "call_args")));
    expect_equal(attr(res, "call_args")$max_length, 1L)
    expect_equal(length(res), 3)

    res <- dig(m, function() 1, max_length = 2L)
    expect_true(is_nugget(res))
    expect_true(is.list(res))
    expect_equal(attr(res, "call_function"), "dig")
    expect_true(is.list(attr(res, "call_args")));
    expect_equal(attr(res, "call_args")$max_length, 2L)
    expect_equal(length(res), 4)

    res <- dig(m, function() 1, max_length = Inf)
    expect_true(is_nugget(res))
    expect_true(is.list(res))
    expect_equal(attr(res, "call_function"), "dig")
    expect_true(is.list(attr(res, "call_args")));
    expect_equal(attr(res, "call_args")$max_length, Inf)
    expect_equal(length(res), 4)
})


test_that("min_support filter", {
    m <- matrix(c(T,T,T,T,F,F, T,F,T,F,T,F), ncol = 2)

    res <- dig(m, function() 1, min_support = 0)
    expect_true(is_nugget(res))
    expect_true(is.list(res))
    expect_equal(attr(res, "call_function"), "dig")
    expect_true(is.list(attr(res, "call_args")));
    expect_equal(attr(res, "call_args")$min_support, 0)
    expect_equal(length(res), 4)

    res <- dig(m, function() 1, min_support = 0.001)
    expect_true(is_nugget(res))
    expect_true(is.list(res))
    expect_equal(attr(res, "call_function"), "dig")
    expect_true(is.list(attr(res, "call_args")));
    expect_equal(attr(res, "call_args")$min_support, 0.001)
    expect_equal(length(res), 4)

    res <- dig(m, function() 1, min_support = 0.5)
    expect_true(is_nugget(res))
    expect_true(is.list(res))
    expect_equal(attr(res, "call_function"), "dig")
    expect_true(is.list(attr(res, "call_args")));
    expect_equal(attr(res, "call_args")$min_support, 0.5)
    expect_equal(length(res), 3)

    res <- dig(m, function() 1, min_support = 0.6)
    expect_true(is_nugget(res))
    expect_true(is.list(res))
    expect_equal(attr(res, "call_function"), "dig")
    expect_true(is.list(attr(res, "call_args")));
    expect_equal(attr(res, "call_args")$min_support, 0.6)
    expect_equal(length(res), 2)

    res <- dig(m, function() 1, min_support = 1)
    expect_true(is_nugget(res))
    expect_true(is.list(res))
    expect_equal(attr(res, "call_function"), "dig")
    expect_true(is.list(attr(res, "call_args")));
    expect_equal(attr(res, "call_args")$min_support, 1)
    expect_equal(length(res), 1)
})


test_that("max_support filter", {
    m <- matrix(c(T,T,T,T,F,F, T,F,T,F,T,F), ncol = 2)

    res <- dig(m, function() 1, max_support = 1)
    expect_true(is_nugget(res))
    expect_true(is.list(res))
    expect_equal(attr(res, "call_function"), "dig")
    expect_true(is.list(attr(res, "call_args")));
    expect_equal(attr(res, "call_args")$max_support, 1)
    expect_equal(length(res), 4)

    res <- dig(m, function(condition, support) list(con=condition, sup=support), max_support = 0.7)
    expect_true(is_nugget(res))
    expect_true(is.list(res))
    expect_equal(attr(res, "call_function"), "dig")
    expect_true(is.list(attr(res, "call_args")));
    expect_equal(attr(res, "call_args")$max_support, 0.7)
    expect_equal(length(res), 3)

    res <- dig(m, function() 1, max_support = 0.6)
    expect_true(is_nugget(res))
    expect_true(is.list(res))
    expect_equal(attr(res, "call_function"), "dig")
    expect_true(is.list(attr(res, "call_args")));
    expect_equal(attr(res, "call_args")$max_support, 0.6)
    expect_equal(length(res), 2)

    res <- dig(m, function() 1, max_support = 0.4)
    expect_true(is_nugget(res))
    expect_true(is.list(res))
    expect_equal(attr(res, "call_function"), "dig")
    expect_true(is.list(attr(res, "call_args")));
    expect_equal(attr(res, "call_args")$max_support, 0.4)
    expect_equal(length(res), 1)

    res <- dig(m, function() 1, max_support = 0.3)
    expect_true(is_nugget(res))
    expect_true(is.list(res))
    expect_equal(attr(res, "call_function"), "dig")
    expect_true(is.list(attr(res, "call_args")));
    expect_equal(attr(res, "call_args")$max_support, 0.3)
    expect_equal(length(res), 0)
})


test_that("disjoint filter", {
    m <- matrix(T, ncol = 3)

    res <- dig(m, function() 1)
    expect_equal(length(res), 8)

    # disjoint 1, 2, 3
    res <- dig(m,
               function(condition) list(cond = condition),
               disjoint = c(1, 2, 3))

    expect_true(is_nugget(res))
    expect_true(is.list(res))
    expect_equal(attr(res, "call_function"), "dig")
    expect_true(is.list(attr(res, "call_args")));
    expect_equal(attr(res, "call_args")$disjoint, 1:3)
    expect_equal(length(res), 8)
    expect_setequal(res, list(list(cond = integer(0)),
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

    expect_true(is_nugget(res))
    expect_true(is.list(res))
    expect_equal(attr(res, "call_function"), "dig")
    expect_true(is.list(attr(res, "call_args")));
    expect_equal(attr(res, "call_args")$disjoint, c(1, 1, 2))
    expect_equal(length(res), 6)
    expect_setequal(res, list(list(cond = integer(0)),
                              list(cond = c("1"=1L)),
                              list(cond = c("2"=2L)),
                              list(cond = c("3"=3L)),
                              list(cond = c("1"=1L, "3"=3L)),
                              list(cond = c("2"=2L, "3"=3L))))

    # disjoint 1, 1, 1
    res <- dig(m,
               function(condition) list(cond = condition),
               disjoint = c(1, 1, 1))

    expect_true(is_nugget(res))
    expect_true(is.list(res))
    expect_equal(attr(res, "call_function"), "dig")
    expect_true(is.list(attr(res, "call_args")));
    expect_equal(attr(res, "call_args")$disjoint, c(1, 1, 1))
    expect_equal(length(res), 4)
    expect_setequal(res, list(list(cond = integer(0)),
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

    expect_true(is_nugget(res))
    expect_true(is.list(res))
    expect_equal(attr(res, "call_function"), "dig")
    expect_true(is.list(attr(res, "call_args")));
    expect_equal(attr(res, "call_args")$disjoint, c(1, 1, 2, 3, 4, 5))
    expect_equal(attr(res, "call_args")$condition, c("1", "2", "3"))
    expect_equal(attr(res, "call_args")$focus, c("4", "5", "6"))
    expect_equal(length(res), 6)
    expect_setequal(res, list(list(cond = integer(0)),
                              list(cond = c("1"=1L)),
                              list(cond = c("2"=2L)),
                              list(cond = c("3"=3L)),
                              list(cond = c("1"=1L, "3"=3L)),
                              list(cond = c("2"=2L, "3"=3L))))
})


test_that("disjoint is factor", {
    m <- matrix(T, ncol = 3)

    res <- dig(m, function() 1)
    expect_equal(length(res), 8)

    # disjoint 1, 2, 3
    res <- dig(m,
               function(condition) list(cond = condition),
               disjoint = factor(c(1, 2, 3)))

    expect_true(is_nugget(res))
    expect_true(is.list(res))
    expect_equal(attr(res, "call_function"), "dig")
    expect_true(is.list(attr(res, "call_args")));
    expect_equal(attr(res, "call_args")$disjoint, factor(c(1, 2, 3)))
    expect_equal(length(res), 8)
    expect_setequal(res, list(list(cond = integer(0)),
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
               disjoint = factor(c(1, 1, 2)))

    expect_true(is_nugget(res))
    expect_true(is.list(res))
    expect_equal(attr(res, "call_function"), "dig")
    expect_true(is.list(attr(res, "call_args")));
    expect_equal(attr(res, "call_args")$disjoint, factor(c(1, 1, 2)))
    expect_equal(length(res), 6)
    expect_setequal(res, list(list(cond = integer(0)),
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
              paste(sort(names(foci_supports)), collapse = "|"))
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
              paste(sort(names(foci_supports)), collapse = "|"))
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


test_that("exclude tautology 1", {
    d <- data.frame(a = c(T,    T, T, F, F),
                    b = c(T,    F, T, T, T),
                    c = c(T,    T, F, F, F),
                    d = c(T,    F, F, F, F),
                    x = c(1.0,  0.1, 0.2, 0.3, 0.4),
                    y = c(1.0,  0.9, 0.8, 0.7, 0.6),
                    z = c(1.0,  0.8, 0.6, 0.4, 0.2),
                    w = c(1.0,  0, 0, 0, 0))

    comb <- function(ante, n) {
        res <- combn(ante, n)
        apply(res, 2, function(w) {
            w <- sort(w)
            paste(w, collapse = " & ")
        })
    }

    comb2 <- function(ante, n, conseq) {
        result <- lapply(conseq, function(cc) {
            a <- setdiff(ante, cc)
            res <- comb(a, n)
            paste(res, "|", cc)
        })

        unlist(result)
    }

    f <- function(condition, foci_supports) {
        paste(paste(sort(names(condition)), collapse = " & "),
              "|",
              sort(names(foci_supports)))
    }

    sel <- c("a", "b", "c", "x", "y", "z")
    selnoX <- c("a", "b", "c", "y", "z")
    selnoC <- c("a", "b", "x", "y", "z")

    # no exclude
    expected <- c(comb2(sel, 1, sel),
                  comb2(sel, 2, sel),
                  comb2(sel, 3, sel))
    res <- dig(d,
               f,
               condition = c(a, b, c, x, y, z),
               focus = c(a, b, c, x, y, z),
               min_length = 1,
               max_length = 3)

    expect_true(is_nugget(res))
    expect_true(is.list(res))
    expect_equal(attr(res, "call_function"), "dig")
    expect_true(is.list(attr(res, "call_args")));
    expect_equal(attr(res, "call_args")$condition, c("a", "b", "c", "x", "y", "z"))
    expect_equal(attr(res, "call_args")$focus, c("a", "b", "c", "x", "y", "z"))
    expect_equal(attr(res, "call_args")$min_length, 1)
    expect_equal(attr(res, "call_args")$max_length, 3)
    expect_equal(attr(res, "call_args")$excluded, NULL)
    expect_equal(sort(unlist(res)), sort(expected))


    # exclude "-> x"
    expected <- c(comb2(selnoX, 1, selnoX),
                  comb2(selnoX, 2, selnoX),
                  comb2(selnoX, 3, selnoX))
    res <- dig(d,
               f,
               condition = c(a, b, c, x, y, z),
               focus = c(a, b, c, x, y, z),
               excluded = list(c("x")),
               min_length = 1,
               max_length = 3)

    expect_true(is_nugget(res))
    expect_true(is.list(res))
    expect_equal(attr(res, "call_function"), "dig")
    expect_true(is.list(attr(res, "call_args")));
    expect_equal(attr(res, "call_args")$condition, c("a", "b", "c", "x", "y", "z"))
    expect_equal(attr(res, "call_args")$focus, c("a", "b", "c", "x", "y", "z"))
    expect_equal(attr(res, "call_args")$min_length, 1)
    expect_equal(attr(res, "call_args")$max_length, 3)
    expect_equal(attr(res, "call_args")$excluded, list("x"))
    expect_equal(sort(unlist(res)), sort(expected))

    # exclude "c -> x"
    expected <- c(setdiff(comb2(sel, 1, sel),
                          c("c | x")),
                  setdiff(comb2(sel, 2, sel),
                          c("a & c | x", "b & c | x", "c & y | x", "c & z | x",
                            "c & x | a", "c & x | b", "c & x | y", "c & x | z")),
                  setdiff(comb2(sel, 3, sel),
                          c("a & b & c | x", "a & c & y | x", "a & c & z | x", "b & c & y | x", "b & c & z | x", "c & y & z | x",
                            "a & c & x | b", "a & c & x | y", "a & c & x | z",
                            "b & c & x | a", "b & c & x | y", "b & c & x | z",
                            "c & x & y | a", "c & x & y | b", "c & x & y | z",
                            "c & x & z | a", "c & x & z | b", "c & x & z | y")))

    res <- dig(d,
               f,
               condition = c(a, b, c, x, y, z),
               focus = c(a, b, c, x, y, z),
               excluded = list(c("c", "x")),
               min_length = 1,
               max_length = 3)

    expect_true(is_nugget(res))
    expect_true(is.list(res))
    expect_equal(attr(res, "call_function"), "dig")
    expect_true(is.list(attr(res, "call_args")));
    expect_equal(attr(res, "call_args")$condition, c("a", "b", "c", "x", "y", "z"))
    expect_equal(attr(res, "call_args")$focus, c("a", "b", "c", "x", "y", "z"))
    expect_equal(attr(res, "call_args")$min_length, 1)
    expect_equal(attr(res, "call_args")$max_length, 3)
    expect_equal(attr(res, "call_args")$excluded, list(c("c", "x")))
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

    expect_true(is_nugget(res))
    expect_true(is.list(res))
    expect_equal(attr(res, "call_function"), "dig")
    expect_true(is.list(attr(res, "call_args")));
    expect_equal(attr(res, "call_args")$t_norm, "goedel")

    attributes(res) <- NULL
    expect_equal(length(res), 1)
    expect_equal(res, list(list(w = pmin(c1, c2))),
                 tolerance = 1e-2)
})


test_that("t-norm goguen", {
    c1 <- c(0.0, 0.2, 0.4, 0.6, 0.8, 1.0)
    c2 <- c(0.5, 0.6, 0.7, 0.8, 0.9, 1.0)
    m <- matrix(c(c1, c2), ncol = 2)

    res <- dig(m,
               function(weights) list(w = weights),
               min_length = 2,
               t_norm = "goguen")

    expect_true(is_nugget(res))
    expect_true(is.list(res))
    expect_equal(attr(res, "call_function"), "dig")
    expect_true(is.list(attr(res, "call_args")));
    expect_equal(attr(res, "call_args")$t_norm, "goguen")

    attributes(res) <- NULL
    expect_equal(length(res), 1)
    expect_equal(res, list(list(w = c1 * c2)),
                 tolerance = 1e-2)
})


test_that("t-norm lukas", {
    c1 <- c(0.0, 0.2, 0.4, 0.6, 0.8, 1.0)
    c2 <- c(0.5, 0.6, 0.7, 0.8, 0.9, 1.0)
    m <- matrix(c(c1, c2), ncol = 2)

    res <- dig(m,
               function(weights) list(w = weights),
               min_length = 2,
               t_norm = "lukas")

    expect_true(is_nugget(res))
    expect_true(is.list(res))
    expect_equal(attr(res, "call_function"), "dig")
    expect_true(is.list(attr(res, "call_args")));
    expect_equal(attr(res, "call_args")$t_norm, "lukas")

    attributes(res) <- NULL
    expect_equal(length(res), 1)
    expect_equal(res, list(list(w = pmax(0, c1 + c2 - 1))),
                 tolerance = 0.018)
})


#test_that("multithread", {
#    m <- matrix(T, ncol = 10, nrow=100)
#
#    res <- dig(m, function() 1, threads = 24)
#    expect_equal(length(res), 1024)
#})


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

    expect_true(is_nugget(res))
    expect_true(is.list(res))
    expect_equal(attr(res, "call_function"), "dig")
    expect_true(is.list(attr(res, "call_args")));
    expect_equal(attr(res, "call_args")$min_support, 0.1)
    expect_equal(attr(res, "call_args")$min_focus_support, 0.5)
    expect_equal(attr(res, "call_args")$filter_empty_foci, FALSE)

    expect_setequal(unlist(res),
                    c(" = 0.7, 0.6", "1 = 0.5", "2 = 0.5", "1 & 2 = "))

    res <- dig(m,
               f,
               condition = 1:2,
               focus = 3:4,
               min_support = 0.1,
               min_focus_support = 0.5,
               filter_empty_foci = TRUE)

    expect_true(is_nugget(res))
    expect_true(is.list(res))
    expect_equal(attr(res, "call_function"), "dig")
    expect_true(is.list(attr(res, "call_args")));
    expect_equal(attr(res, "call_args")$min_support, 0.1)
    expect_equal(attr(res, "call_args")$min_focus_support, 0.5)
    expect_equal(attr(res, "call_args")$filter_empty_foci, TRUE)

    expect_setequal(unlist(res),
                    c(" = 0.7, 0.6", "1 = 0.5", "2 = 0.5"))
})


test_that("min_conditional_focus_support & filter_empty_foci", {
    m <- matrix(c(c(1,1,1,1,1,1,1,1,0,0),
                  c(1,1,1,1,1,1,0,0,1,1),
                  c(0,0,0,1,1,1,1,1,1,1),
                  c(0,0,0,0,1,1,1,1,1,1)), ncol = 4)

    f <- function(condition, support, foci_supports) {
       paste(paste(condition, collapse = " & "),
             ":", round(support, 1),
             "=",
             paste0(names(foci_supports), "/", round(foci_supports, 1), collapse = ", "))
    }

    res <- dig(m,
               f,
               condition = 1:2,
               focus = 3:4,
               min_support = 0.1,
               min_conditional_focus_support = 0.6,
               filter_empty_foci = FALSE)

    expect_true(is_nugget(res))
    expect_true(is.list(res))
    expect_equal(attr(res, "call_function"), "dig")
    expect_true(is.list(attr(res, "call_args")));
    expect_equal(attr(res, "call_args")$min_support, 0.1)
    expect_equal(attr(res, "call_args")$min_conditional_focus_support, 0.6)
    expect_equal(attr(res, "call_args")$filter_empty_foci, FALSE)

    expect_setequal(unlist(res),
                    c(" : 1 = 3/0.7, 4/0.6", "1 : 0.8 = 3/0.5", "2 : 0.8 = 3/0.5", "1 & 2 : 0.6 = /"))

    res <- dig(m,
               f,
               condition = 1:2,
               focus = 3:4,
               min_support = 0.1,
               min_conditional_focus_support = 0.6,
               filter_empty_foci = TRUE)

    expect_true(is_nugget(res))
    expect_true(is.list(res))
    expect_equal(attr(res, "call_function"), "dig")
    expect_true(is.list(attr(res, "call_args")));
    expect_equal(attr(res, "call_args")$min_support, 0.1)
    expect_equal(attr(res, "call_args")$min_conditional_focus_support, 0.6)
    expect_equal(attr(res, "call_args")$filter_empty_foci, TRUE)

    expect_setequal(unlist(res),
                    c(" : 1 = 3/0.7, 4/0.6", "1 : 0.8 = 3/0.5", "2 : 0.8 = 3/0.5"))
})


test_that("dig return object details", {
    d <- data.frame(a = c(T,    T, T, F, F),
                    b = c(T,    F, T, T, T),
                    c = c(T,    T, F, F, F),
                    d = c(T,    F, F, F, F),
                    x = c(1.0,  0.1, 0.2, 0.3, 0.4),
                    y = c(1.0,  0.9, 0.8, 0.7, 0.6),
                    z = c(1.0,  0.8, 0.6, 0.4, 0.2),
                    w = c(1.0,  0, 0, 0, 0))

    res <- dig(d,
               f = function(condition) list(cond = condition),
               condition = a:d,
               focus = x:z,
               disjoint = c(1, 1, 2, 3, 5, 5, 6, 7),
               excluded = list(c("x")),
               min_length = 1,
               max_length = 3,
               min_support = 0.1,
               min_focus_support = 0.5,
               min_conditional_focus_support = 0.6,
               max_support = 0.99,
               filter_empty_foci = TRUE,
               t_norm = "goedel",
               max_results = 1000,
               verbose = TRUE,
               threads = 1)

    expect_true(is_nugget(res))
    expect_true(is.list(res))
    expect_equal(attr(res, "call_function"), "dig")
    expect_true(is.list(attr(res, "call_args")));
    expect_equal(attr(res, "call_args")$condition, c("a", "b", "c", "d"))
    expect_equal(attr(res, "call_args")$focus, c("x", "y", "z"))
    expect_equal(attr(res, "call_args")$disjoint, c(1, 1, 2, 3, 5, 5, 6, 7))
    expect_equal(attr(res, "call_args")$excluded, list("x"))
    expect_equal(attr(res, "call_args")$min_length, 1)
    expect_equal(attr(res, "call_args")$max_length, 3)
    expect_equal(attr(res, "call_args")$min_support, 0.1)
    expect_equal(attr(res, "call_args")$min_focus_support, 0.5)
    expect_equal(attr(res, "call_args")$min_conditional_focus_support, 0.6)
    expect_equal(attr(res, "call_args")$max_support, 0.99)
    expect_equal(attr(res, "call_args")$filter_empty_foci, TRUE)
    expect_equal(attr(res, "call_args")$t_norm, "goedel")
    expect_equal(attr(res, "call_args")$max_results, 1000)
    expect_equal(attr(res, "call_args")$verbose, TRUE)
    expect_equal(attr(res, "call_args")$threads, 1)
})


test_that("errors", {
    f <- function(condition) { list() }
    d <- data.frame(n = 1:5 / 5, l = TRUE, i = 1:5, s = letters[1:5])

    expect_error(dig(list(), f), "`x` must be a matrix or a data frame.")
    expect_error(dig(matrix(0, nrow = 5, ncol = 0), f), "`x` must have at least one column.")
    expect_error(dig(matrix(0, nrow = 0, ncol = 5), f), "`x` must have at least one row.")

    expect_true(is.list(dig(d, f, condition = c(n, l))))
    expect_error(dig(d, f, condition = c(n, l, i)),
                 "All columns selected by `condition` must be logical or numeric")
    expect_error(dig(d, f, condition = c(n, l, s)),
                 "All columns selected by `condition` must be logical or numeric")

    expect_true(is.list(dig(d, f, condition = c(n, l), focus = c(n, l))))
    expect_error(dig(d, f, condition = c(n, l), focus = c(n, l, i)),
                 "All columns selected by `focus` must be logical or numeric")
    expect_error(dig(d, f, condition = c(n, l), focus = c(n, l, s)),
                 "All columns selected by `focus` must be logical or numeric")

    expect_error(dig(d, f = "x", condition = n),
                 "`f` must be a function.")
    expect_error(dig(d, f = function(a) { }, condition = n),
                 "Function `f` is allowed to have the following arguments")
    expect_error(dig(d, f, condition = n, disjoint = list("x")),
                 "`disjoint` must be a plain vector")
    expect_error(dig(d, f, condition = n, excluded = 3),
                 "`excluded` must be a list or NULL.")
    expect_error(dig(d, f, condition = n, excluded = list(3)),
                 "`excluded` must be a list of character vectors.")
    expect_error(dig(d, f, condition = n, disjoint = "x"),
                 "The length of `disjoint` must be 0 or must be equal to the number of columns in `x`.")
    expect_error(dig(d, f, condition = n, min_length = "x"),
                 "`min_length` must be an integerish scalar.")
    expect_error(dig(d, f, condition = n, min_length = Inf),
                 "`min_length` must be finite.")
    expect_error(dig(d, f, condition = n, min_length = -1),
                 "`min_length` must be >= 0.")
    expect_error(dig(d, f, condition = n, max_length = "x"),
                 "`max_length` must be an integerish scalar.")
    expect_error(dig(d, f, condition = n, max_length = -1),
                 "`max_length` must be >= 0.")
    expect_error(dig(d, f, condition = n, min_length = 5, max_length = 4),
                 "`max_length` must be greater or equal to `min_length`.")
    expect_error(dig(d, f, condition = n, min_support = "x"),
                 "`min_support` must be a double scalar.")
    expect_error(dig(d, f, condition = n, min_support = 1.1),
                 "`min_support` must be between 0 and 1.")
    expect_error(dig(d, f, condition = n, min_focus_support = "x"),
                 "`min_focus_support` must be a double scalar.")
    expect_error(dig(d, f, condition = n, min_focus_support = 1.1),
                 "`min_focus_support` must be between 0 and 1.")
    expect_error(dig(d, f, condition = n, filter_empty_foci = "x"),
                 "`filter_empty_foci` must be a flag")
    expect_error(dig(d, f, condition = n, t_norm = "x"),
                 "`t_norm` must be equal to one of:")
    expect_error(dig(d, f, condition = n, max_results = -1),
                 "`max_results` must be >= 1.")
    expect_error(dig(d, f, condition = n, verbose = "x"),
                 "`verbose` must be a flag")
    expect_error(dig(d, f, condition = n, threads = "x"),
                 "`threads` must be an integerish scalar.")
    expect_error(dig(d, f, condition = n, threads = 0),
                 "`threads` must be >= 1.")
    expect_error(dig(d, f, condition = n, excluded = FALSE),
                 "`excluded` must be a list or NULL.")
    expect_error(dig(d, f, condition = n, excluded = list(c(FALSE, TRUE))),
                 "`excluded` must be a list of character vectors.")
    expect_error(dig(d, f, condition = n, excluded = list(c("n", "l", "foo"))),
                 "Can't find some column names in `x` that correspond to all predicates in `excluded`.")
})


test_that("bug on mixed logical and numeric chains", {
    fuzzyCO2 <- CO2 |>
        partition(Plant:Treatment) |>
        partition(conc, .method = "triangle", .breaks = c(-Inf, 175, 350, 675, Inf)) |>
        partition(uptake, .method = "triangle", .breaks = c(-Inf, 18, 28, 37, Inf))

    disj <- sub("=.*", "", colnames(fuzzyCO2))

    result <- dig_associations(fuzzyCO2,
                               antecedent = !starts_with("Treatment"),
                               consequent = starts_with("Treatment"),
                               disjoint = disj,
                               min_support = 0.02,
                               min_confidence = 0.8)

    expect_true(is_tibble(result))
})

