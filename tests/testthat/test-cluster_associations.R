test_that("cluster_associations()", {
    d <- data.frame(antecedent = c("{a,b}", "{a,c}", "{b,d}", "{d}", "{b,c}"),
                    consequent = c("{x}", "{x}", "{y}", "{y}", "{x}"),
                    support = c(0.5, 0.4, 0.3, 0.2, 0.6),
                    confidence = c(0.8, 0.7, 0.6, 0.5, 0.9),
                    lift = c(1.5, 1.4, 1.3, 1.2, 1.6))
    d <- nugget(d, "associations",
                call_function = "dig_associations",
                call_data = list(),
                call_args = list())

    res <- cluster_associations(d, 2, lift, predicates_in_label = 3)
    expect_true(is_tibble(res))
    expect_equal(nrow(res), 2)
    expect_equal(ncol(res), 6)
    expect_equal(colnames(res), c("cluster", "cluster_label", "consequent", "support", "confidence", "lift"))
    expect_equal(res$cluster, 1:2)
    expect_equal(as.character(res$cluster_label), c("3 rules: {a, b, c}", "2 rules: {d, b}"))
    expect_equal(as.character(res$consequent), c("{x}", "{y}"))
    expect_equal(res$support, c(0.5, 0.25))
    expect_equal(res$confidence, c(0.8, 0.55))
    expect_equal(res$lift, c(1.5, 1.25))

    cluster_predicates <- attr(res, "cluster_predicates")
    cluster_size <- attr(res, "cluster_size")
    expect_equal(as.list(cluster_predicates[[1]]), list(a = 2, b = 2, c = 2))
    expect_equal(as.list(cluster_predicates[[2]]), list(d = 2, b = 1))
    expect_equal(cluster_size, c("1" = 3, "2" = 2))
})


test_that("cluster_associations() is order invariant", {
    d <- data.frame(antecedent = c("{a,b}", "{a,c}", "{b,d}", "{d}", "{b,c}"),
                    consequent = c("{x}", "{x}", "{y}", "{y}", "{x}"),
                    support = c(0.5, 0.4, 0.3, 0.2, 0.6),
                    confidence = c(0.8, 0.7, 0.6, 0.5, 0.9),
                    lift = c(1.5, 1.4, 1.3, 1.2, 1.6))
    d <- nugget(d, "associations",
                call_function = "dig_associations",
                call_data = list(),
                call_args = list())
    d <- d[rev(seq_len(nrow(d))), ]

    res <- cluster_associations(d, 2, lift, predicates_in_label = 3)
    expect_true(is_tibble(res))
    expect_equal(nrow(res), 2)
    expect_equal(ncol(res), 6)
    expect_equal(colnames(res), c("cluster", "cluster_label", "consequent", "support", "confidence", "lift"))
    expect_equal(res$cluster, 1:2)
    expect_equal(as.character(res$cluster_label), c("3 rules: {a, b, c}", "2 rules: {d, b}"))
    expect_equal(as.character(res$consequent), c("{x}", "{y}"))
    expect_equal(res$support, c(0.5, 0.25))
    expect_equal(res$confidence, c(0.8, 0.55))
    expect_equal(res$lift, c(1.5, 1.25))

    cluster_predicates <- attr(res, "cluster_predicates")
    cluster_size <- attr(res, "cluster_size")
    expect_equal(as.list(cluster_predicates[[1]]), list(a = 2, b = 2, c = 2))
    expect_equal(as.list(cluster_predicates[[2]]), list(d = 2, b = 1))
    expect_equal(cluster_size, c("1" = 3, "2" = 2))
})


test_that("cluster_associations() predicates_in_label", {
    d <- data.frame(antecedent = c("{a,b}", "{a,c}", "{b,d}", "{d}", "{b,c}"),
                    consequent = c("{x}", "{x}", "{y}", "{y}", "{x}"),
                    support = c(0.5, 0.4, 0.3, 0.2, 0.6),
                    confidence = c(0.8, 0.7, 0.6, 0.5, 0.9),
                    lift = c(1.5, 1.4, 1.3, 1.2, 1.6))
    d <- nugget(d, "associations",
                call_function = "dig_associations",
                call_data = list(),
                call_args = list())

    res <- cluster_associations(d, 2, lift, predicates_in_label = 2)
    expect_true(is_tibble(res))
    expect_equal(nrow(res), 2)
    expect_equal(ncol(res), 6)
    expect_equal(as.character(res$cluster_label), c("3 rules: {a, b, +1 item}", "2 rules: {d, b}"))
})
