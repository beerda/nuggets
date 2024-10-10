test_that("dig_implications without contingency table", {
    d <- data.frame(a = c(T, T, F, F, F),
                    b = c(T, T, T, T, F),
                    c = c(F, F, F, T, T))

    res <- dig_implications(d,
                            antecedent = everything(),
                            consequent = everything(),
                            min_support = 0.0001,
                            min_confidence = 0.0001,
                            contingency_table = FALSE)

    expect_true(is_tibble(res))
    expect_equal(nrow(res), 7)
    expect_equal(colnames(res),
                 c("antecedent", "consequent", "support", "confidence", "coverage", "conseq_support", "count"))
    expect_true(is.character(res$antecedent))
    expect_true(is.character(res$consequent))
    expect_true(is.double(res$support))
    expect_true(is.double(res$confidence))
    expect_equal(res$antecedent,
                 c("{}", "{}", "{}", "{b}", "{b}", "{a}", "{c}"))
    expect_equal(res$consequent,
                 c("{a}", "{b}", "{c}", "{a}", "{c}", "{b}", "{b}"))
    expect_equal(round(res$support, 6),
                 c(0.4, 0.8, 0.4, 0.4, 0.2, 0.4, 0.2))
    expect_equal(round(res$conseq_support, 6),
                 c(0.4, 0.8, 0.4, 0.4, 0.4, 0.8, 0.8))
    expect_equal(round(res$confidence, 6),
                 c(0.4, 0.8, 0.4, 0.5, 0.25, 1.0, 0.5))
})


test_that("dig_implications with contingency table", {
    d <- data.frame(a = c(T, T, F, F, F),
                    b = c(T, T, T, T, F),
                    c = c(F, F, F, T, T))

    res <- dig_implications(d,
                            antecedent = everything(),
                            consequent = everything(),
                            min_support = 0.0001,
                            min_confidence = 0.0001,
                            contingency_table = TRUE)

    expect_true(is_tibble(res))
    expect_equal(nrow(res), 7)
    expect_equal(colnames(res),
                 c("antecedent", "consequent", "support", "confidence", "coverage", "conseq_support", "count",
                   "pp", "pn", "np", "nn"))
    expect_true(is.character(res$antecedent))
    expect_true(is.character(res$consequent))
    expect_true(is.double(res$support))
    expect_true(is.double(res$confidence))
    expect_equal(res$antecedent,
                 c("{}", "{}", "{}", "{b}", "{b}", "{a}", "{c}"))
    expect_equal(res$consequent,
                 c("{a}", "{b}", "{c}", "{a}", "{c}", "{b}", "{b}"))
    expect_equal(round(res$support, 6),
                 c(0.4, 0.8, 0.4, 0.4, 0.2, 0.4, 0.2))
    expect_equal(round(res$conseq_support, 6),
                 c(0.4, 0.8, 0.4, 0.4, 0.4, 0.8, 0.8))
    expect_equal(round(res$confidence, 6),
                 c(0.4, 0.8, 0.4, 0.5, 0.25, 1.0, 0.5))
    expect_equal(round(res$pp, 6),
                 c(0.4, 0.8, 0.4, 0.4, 0.2, 0.4, 0.2))
    expect_equal(round(res$np, 6),
                 c(0.0, 0.0, 0.0, 0.0, 0.2, 0.4, 0.6))
    expect_equal(round(res$pn, 6),
                 c(0.6, 0.2, 0.6, 0.4, 0.6, 0.0, 0.2))
    expect_equal(round(res$nn, 6),
                 c(0.0, 0.0, 0.0, 0.2, 0.0, 0.2, 0.0))
})


test_that("dig_implications with disjoint", {
    d <- data.frame(a = c(T, T, F, F, F),
                    b = c(T, T, T, T, F),
                    c = c(F, F, F, T, T))

    res <- dig_implications(d,
                            antecedent = everything(),
                            consequent = everything(),
                            disjoint = c(1, 2, 2),
                            min_support = 0.0001,
                            min_confidence = 0.0001)

    expect_true(is_tibble(res))
    expect_equal(nrow(res), 5)
    expect_equal(colnames(res),
                 c("antecedent", "consequent", "support", "confidence", "coverage", "conseq_support", "count"))
    expect_true(is.character(res$antecedent))
    expect_true(is.character(res$consequent))
    expect_true(is.double(res$support))
    expect_true(is.double(res$confidence))
    expect_equal(res$antecedent,
                 c("{}", "{}", "{}", "{b}", "{a}"))
    expect_equal(res$consequent,
                 c("{a}", "{b}", "{c}", "{a}", "{b}"))
    expect_equal(res$support,
                 c(0.4, 0.8, 0.4, 0.4, 0.4))
    expect_equal(round(res$conseq_support, 6),
                 c(0.4, 0.8, 0.4, 0.4, 0.8))
    expect_equal(res$confidence,
                 c(0.4, 0.8, 0.4, 0.5, 1.0))
})


test_that("dig_implications min_support", {
    # min_support is the support of the whole rule
    d <- data.frame(a = c(T, T, F, F, F),
                    b = c(T, T, T, T, F),
                    c = c(T, F, F, T, T))

    res <- dig_implications(d,
                            antecedent = everything(),
                            consequent = everything(),
                            disjoint = c(1, 2, 3),
                            min_support = 0.2,
                            min_confidence = 0.0001)
    expect_true(is_tibble(res))
    expect_equal(nrow(res), 12)

    res <- dig_implications(d,
                            antecedent = everything(),
                            consequent = everything(),
                            disjoint = c(1, 2, 3),
                            min_support = 0.3,
                            min_confidence = 0.0001)
    expect_true(is_tibble(res))
    expect_equal(nrow(res), 7)

    res <- dig_implications(d,
                            antecedent = everything(),
                            consequent = everything(),
                            disjoint = c(1, 2, 3),
                            min_support = 0.8,
                            min_confidence = 0.0001)
    expect_true(is_tibble(res))
    expect_equal(nrow(res), 1)

    res <- dig_implications(d,
                            antecedent = everything(),
                            consequent = everything(),
                            disjoint = c(1, 2, 3),
                            min_support = 0.81,
                            min_confidence = 0.0001)
    expect_true(is_tibble(res))
    expect_equal(nrow(res), 0)
})


test_that("dig_implications min_coverage", {
    # min_coverage is the support of the antecedent
    d <- data.frame(a = c(T, T, F, F, F),
                    b = c(T, T, T, T, F),
                    c = c(T, F, F, T, T))

    res <- dig_implications(d,
                            antecedent = everything(),
                            consequent = everything(),
                            disjoint = c(1, 2, 3),
                            min_coverage = 0.2,
                            min_confidence = 0.0001)
    expect_true(is_tibble(res))
    expect_equal(nrow(res), 12)

    res <- dig_implications(d,
                            antecedent = everything(),
                            consequent = everything(),
                            disjoint = c(1, 2, 3),
                            min_coverage = 0.3,
                            min_confidence = 0.0001)
    expect_true(is_tibble(res))
    expect_equal(nrow(res), 11)

    res <- dig_implications(d,
                            antecedent = everything(),
                            consequent = everything(),
                            disjoint = c(1, 2, 3),
                            min_coverage = 0.8,
                            min_confidence = 0.0001)
    expect_true(is_tibble(res))
    expect_equal(nrow(res), 5)

    res <- dig_implications(d,
                            antecedent = everything(),
                            consequent = everything(),
                            disjoint = c(1, 2, 3),
                            min_coverage = 1,
                            min_confidence = 0.0001)
    expect_true(is_tibble(res))
    expect_equal(nrow(res), 3)
})


test_that("compare dig_implications to arules::apriori", {
    set.seed(2123)
    rows <- 100
    cols <- 5
    m <- matrix(sample(c(T, F), rows * cols, replace = TRUE),
                nrow = rows,
                ncol = cols)
    colnames(m) <- letters[seq_len(cols)]

    afit <- arules::apriori(m, parameter = list(minlen = 1,
                                        maxlen = 6,
                                        supp=0.001,
                                        conf = 0.5),
                    control = list(verbose = FALSE))

    expected <- arules::DATAFRAME(afit)
    expected$LHS <- as.character(expected$LHS)
    expected$RHS <- as.character(expected$RHS)

    for (inter in c("addedValue")) {
        expected[[inter]] <- arules::interestMeasure(afit, inter)
    }
    expected <- expected[order(expected$LHS, expected$RHS), ]

    res <- dig_implications(m,
                            min_support = 0.001,
                            min_length = 0,
                            max_length = 5,
                            min_confidence = 0.5,
                            measures = c("lift",
                                         "added_value"))
    res <- res[order(res$antecedent, res$consequent), ]

    expect_equal(res$antecedent, expected$LHS)
    expect_equal(res$consequent, expected$RHS)
    expect_equal(res$support, expected$support, tolerance = 1e-6)
    expect_equal(res$confidence, expected$confidence, tolerance = 1e-6)
    expect_equal(res$coverage, expected$coverage, tolerance = 1e-6)
    expect_equal(res$lift, expected$lift, tolerance = 1e-6)
    expect_equal(res$added_value, expected$addedValue, tolerance = 1e-6)
    expect_equal(res$count, expected$count)
})
