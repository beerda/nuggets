test_that("dig_implications", {
    d <- data.frame(a = c(T, T, F, F, F),
                    b = c(T, T, T, T, F),
                    c = c(F, F, F, T, T))

    res <- dig_implications(d,
                            antecedent = everything(),
                            consequent = everything(),
                            min_support = 0.0001,
                            min_confidence = 0.0001)

    expect_true(is_tibble(res))
    expect_equal(nrow(res), 7)
    expect_equal(colnames(res),
                 c("antecedent", "consequent", "support", "confidence", "coverage", "lift", "count"))
    expect_true(is.character(res$antecedent))
    expect_true(is.character(res$consequent))
    expect_true(is.double(res$support))
    expect_true(is.double(res$confidence))
    expect_equal(res$antecedent,
                 c("{}", "{}", "{}", "{a}", "{b}", "{b}", "{c}"))
    expect_equal(res$consequent,
                 c("{a}", "{b}", "{c}", "{b}", "{a}", "{c}", "{b}"))
    expect_equal(res$support,
                 c(0.4, 0.8, 0.4, 0.4, 0.4, 0.2, 0.2))
    expect_equal(res$confidence,
                 c(0.4, 0.8, 0.4, 1, 0.5, 0.25, 0.5))
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
                 c("antecedent", "consequent", "support", "confidence", "coverage", "lift", "count"))
    expect_true(is.character(res$antecedent))
    expect_true(is.character(res$consequent))
    expect_true(is.double(res$support))
    expect_true(is.double(res$confidence))
    expect_equal(res$antecedent,
                 c("{}", "{}", "{}", "{a}", "{b}"))
    expect_equal(res$consequent,
                 c("{a}", "{b}", "{c}", "{b}", "{a}"))
    expect_equal(res$support,
                 c(0.4, 0.8, 0.4, 0.4, 0.4))
    expect_equal(res$confidence,
                 c(0.4, 0.8, 0.4, 1, 0.5))
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
