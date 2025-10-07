test_that("dig_associations without contingency table", {
    d <- data.frame(a = c(T, T, F, F, F),
                    b = c(T, T, T, T, F),
                    c = c(F, F, F, T, T))

    res <- dig_associations(d,
                            antecedent = everything(),
                            consequent = everything(),
                            min_support = 0.0001,
                            min_confidence = 0.0001,
                            contingency_table = FALSE)

    res <- res[order(res$antecedent_length, res$antecedent, res$consequent), ]

    expect_true(is_nugget(res, "associations"))
    expect_true(is_tibble(res))
    expect_equal(attr(res, "call_function"), "dig_associations")
    expect_true(is.list(attr(res, "call_args")))
    expect_equal(attr(res, "call_args")$antecedent, c("a", "b", "c"))
    expect_equal(attr(res, "call_args")$consequent, c("a", "b", "c"))
    expect_equal(attr(res, "call_args")$min_support, 0.0001)
    expect_equal(attr(res, "call_args")$min_confidence, 0.0001)
    expect_equal(attr(res, "call_args")$contingency_table, FALSE)
    expect_true(is_tibble(res))
    expect_equal(nrow(res), 7)
    expect_equal(colnames(res),
                 c("antecedent", "consequent", "support", "confidence",
                   "coverage", "conseq_support", "count", "antecedent_length"))
    expect_true(is.character(res$antecedent))
    expect_true(is.character(res$consequent))
    expect_true(is.double(res$support))
    expect_true(is.double(res$confidence))
    expect_equal(res$antecedent,
                 c("{}", "{}", "{}", "{a}", "{b}", "{b}", "{c}"))
    expect_equal(res$consequent,
                 c("{a}", "{b}", "{c}", "{b}", "{a}", "{c}", "{b}"))
    expect_equal(round(res$support, 6),
                 c(0.4, 0.8, 0.4, 0.4, 0.4, 0.2, 0.2))
    expect_equal(round(res$conseq_support, 6),
                 c(0.4, 0.8, 0.4, 0.8, 0.4, 0.4, 0.8))
    expect_equal(round(res$confidence, 6),
                 c(0.4, 0.8, 0.4, 1.0, 0.50, 0.25, 0.5))
    expect_equal(res$antecedent_length,
                 c(0, 0, 0, 1, 1, 1, 1))
})


test_that("dig_associations with contingency table", {
    d <- data.frame(a = c(T, T, F, F, F),
                    b = c(T, T, T, T, F),
                    c = c(F, F, F, T, T))

    res <- dig_associations(d,
                            antecedent = everything(),
                            consequent = everything(),
                            min_support = 0.0001,
                            min_confidence = 0.0001,
                            contingency_table = TRUE)

    res <- res[order(res$antecedent_length, res$antecedent, res$consequent), ]

    expect_true(is_nugget(res, "associations"))
    expect_true(is_tibble(res))
    expect_equal(attr(res, "call_function"), "dig_associations")
    expect_true(is.list(attr(res, "call_args")))
    expect_equal(attr(res, "call_args")$antecedent, c("a", "b", "c"))
    expect_equal(attr(res, "call_args")$consequent, c("a", "b", "c"))
    expect_equal(attr(res, "call_args")$min_support, 0.0001)
    expect_equal(attr(res, "call_args")$min_confidence, 0.0001)
    expect_equal(attr(res, "call_args")$contingency_table, TRUE)
    expect_true(is_tibble(res))
    expect_equal(nrow(res), 7)
    expect_equal(colnames(res),
                 c("antecedent", "consequent", "support", "confidence",
                   "coverage", "conseq_support", "count", "antecedent_length",
                   "pp", "pn", "np", "nn"))
    expect_true(is.character(res$antecedent))
    expect_true(is.character(res$consequent))
    expect_true(is.double(res$support))
    expect_true(is.double(res$confidence))
    expect_equal(res$antecedent,
                 c( "{}",  "{}",  "{}", "{a}", "{b}", "{b}", "{c}"))
    expect_equal(res$consequent,
                 c("{a}", "{b}", "{c}", "{b}", "{a}", "{c}", "{b}"))
    expect_equal(round(res$support, 6),
                 c(0.4, 0.8, 0.4, 0.4, 0.4, 0.2, 0.2))
    expect_equal(round(res$conseq_support, 6),
                 c(0.4, 0.8, 0.4, 0.8, 0.4, 0.4, 0.8))
    expect_equal(round(res$confidence, 6),
                 c(0.4, 0.8, 0.4, 1.0, 0.5, 0.25, 0.5))
    expect_equal(res$antecedent_length,
                 c(0, 0, 0, 1, 1, 1, 1))
    expect_equal(res$pp,
                 c(2, 4, 2, 2, 2, 1, 1))
    expect_equal(res$np,
                 c(0, 0, 0, 2, 0, 1, 3))
    expect_equal(res$pn,
                 c(3, 1, 3, 0, 2, 3, 1))
    expect_equal(res$nn,
                 c(0, 0, 0, 1, 1, 0, 0))
})


test_that("dig_associations with disjoint", {
    d <- data.frame(a = c(T, T, F, F, F),
                    b = c(T, T, T, T, F),
                    c = c(F, F, F, T, T))

    res <- dig_associations(d,
                            antecedent = everything(),
                            consequent = everything(),
                            disjoint = c(1, 2, 2),
                            min_support = 0.0001,
                            min_confidence = 0.0001)

    expect_true(is_nugget(res, "associations"))
    expect_true(is_tibble(res))
    expect_equal(attr(res, "call_function"), "dig_associations")
    expect_true(is.list(attr(res, "call_args")))
    expect_equal(attr(res, "call_args")$antecedent, c("a", "b", "c"))
    expect_equal(attr(res, "call_args")$consequent, c("a", "b", "c"))
    expect_equal(attr(res, "call_args")$min_support, 0.0001)
    expect_equal(attr(res, "call_args")$min_confidence, 0.0001)
    expect_equal(attr(res, "call_args")$disjoint, c(1, 2, 2))
    expect_true(is_tibble(res))
    expect_equal(nrow(res), 5)
    expect_equal(colnames(res),
                 c("antecedent", "consequent", "support", "confidence",
                   "coverage", "conseq_support", "count", "antecedent_length"))
    expect_true(is.character(res$antecedent))
    expect_true(is.character(res$consequent))
    expect_true(is.double(res$support))
    expect_true(is.double(res$confidence))
    expect_equal(res$antecedent,
                 c("{}", "{}", "{}", "{b}", "{a}"))
    expect_equal(res$consequent,
                 c("{b}", "{a}", "{c}", "{a}", "{b}"))
    expect_equal(res$support,
                 c(0.8, 0.4, 0.4, 0.4, 0.4))
    expect_equal(round(res$conseq_support, 6),
                 c(0.8, 0.4, 0.4, 0.4, 0.8))
    expect_equal(res$confidence,
                 c(0.8, 0.4, 0.4, 0.5, 1.0))
    expect_equal(res$antecedent_length,
                 c(0, 0, 0, 1, 1))
})


test_that("dig_associations min_support", {
    # min_support is the support of the whole rule
    d <- data.frame(a = c(T, T, F, F, F),
                    b = c(T, T, T, T, F),
                    c = c(T, F, F, T, T))

    res <- dig_associations(d,
                            antecedent = everything(),
                            consequent = everything(),
                            disjoint = c(1, 2, 3),
                            min_support = 0.2,
                            min_confidence = 0.0001)
    expect_true(is_tibble(res))
    expect_equal(nrow(res), 12)

    res <- dig_associations(d,
                            antecedent = everything(),
                            consequent = everything(),
                            disjoint = c(1, 2, 3),
                            min_support = 0.3,
                            min_confidence = 0.0001)
    expect_true(is_nugget(res, "associations"))
    expect_true(is_tibble(res))
    expect_equal(attr(res, "call_function"), "dig_associations")
    expect_true(is.list(attr(res, "call_args")))
    expect_equal(attr(res, "call_args")$antecedent, c("a", "b", "c"))
    expect_equal(attr(res, "call_args")$consequent, c("a", "b", "c"))
    expect_equal(attr(res, "call_args")$min_support, 0.3)
    expect_equal(attr(res, "call_args")$min_confidence, 0.0001)
    expect_equal(attr(res, "call_args")$disjoint, c(1, 2, 3))
    expect_true(is_tibble(res))
    expect_equal(nrow(res), 7)

    res <- dig_associations(d,
                            antecedent = everything(),
                            consequent = everything(),
                            disjoint = c(1, 2, 3),
                            min_support = 0.8,
                            min_confidence = 0.0001)
    expect_true(is_nugget(res, "associations"))
    expect_true(is_tibble(res))
    expect_equal(attr(res, "call_function"), "dig_associations")
    expect_true(is.list(attr(res, "call_args")))
    expect_equal(attr(res, "call_args")$antecedent, c("a", "b", "c"))
    expect_equal(attr(res, "call_args")$consequent, c("a", "b", "c"))
    expect_equal(attr(res, "call_args")$min_support, 0.8)
    expect_equal(attr(res, "call_args")$min_confidence, 0.0001)
    expect_equal(attr(res, "call_args")$disjoint, c(1, 2, 3))
    expect_true(is_tibble(res))
    expect_equal(nrow(res), 1)

    res <- dig_associations(d,
                            antecedent = everything(),
                            consequent = everything(),
                            disjoint = c(1, 2, 3),
                            min_support = 0.81,
                            min_confidence = 0.0001)
    expect_true(is_nugget(res, "associations"))
    expect_true(is_tibble(res))
    expect_equal(attr(res, "call_function"), "dig_associations")
    expect_true(is.list(attr(res, "call_args")))
    expect_equal(attr(res, "call_args")$antecedent, c("a", "b", "c"))
    expect_equal(attr(res, "call_args")$consequent, c("a", "b", "c"))
    expect_equal(attr(res, "call_args")$min_support, 0.81)
    expect_equal(attr(res, "call_args")$min_confidence, 0.0001)
    expect_equal(attr(res, "call_args")$disjoint, c(1, 2, 3))
    expect_true(is_tibble(res))
    expect_equal(nrow(res), 0)
})


test_that("dig_associations min_coverage", {
    # min_coverage is the support of the antecedent
    d <- data.frame(a = c(T, T, F, F, F),
                    b = c(T, T, T, T, F),
                    c = c(T, F, F, T, T))

    res <- dig_associations(d,
                            antecedent = everything(),
                            consequent = everything(),
                            disjoint = c(1, 2, 3),
                            min_coverage = 0.2,
                            min_confidence = 0.0001)
    expect_true(is_nugget(res, "associations"))
    expect_true(is_tibble(res))
    expect_equal(attr(res, "call_function"), "dig_associations")
    expect_true(is.list(attr(res, "call_args")))
    expect_equal(attr(res, "call_args")$antecedent, c("a", "b", "c"))
    expect_equal(attr(res, "call_args")$consequent, c("a", "b", "c"))
    expect_equal(attr(res, "call_args")$min_coverage, 0.2)
    expect_equal(attr(res, "call_args")$min_confidence, 0.0001)
    expect_equal(attr(res, "call_args")$disjoint, c(1, 2, 3))
    expect_true(is_tibble(res))
    expect_equal(nrow(res), 12)

    res <- dig_associations(d,
                            antecedent = everything(),
                            consequent = everything(),
                            disjoint = c(1, 2, 3),
                            min_coverage = 0.3,
                            min_confidence = 0.0001)
    expect_true(is_nugget(res, "associations"))
    expect_true(is_tibble(res))
    expect_equal(attr(res, "call_function"), "dig_associations")
    expect_true(is.list(attr(res, "call_args")))
    expect_equal(attr(res, "call_args")$antecedent, c("a", "b", "c"))
    expect_equal(attr(res, "call_args")$consequent, c("a", "b", "c"))
    expect_equal(attr(res, "call_args")$min_coverage, 0.3)
    expect_equal(attr(res, "call_args")$min_confidence, 0.0001)
    expect_equal(attr(res, "call_args")$disjoint, c(1, 2, 3))
    expect_true(is_tibble(res))
    expect_equal(nrow(res), 11)

    res <- dig_associations(d,
                            antecedent = everything(),
                            consequent = everything(),
                            disjoint = c(1, 2, 3),
                            min_coverage = 0.8,
                            min_confidence = 0.0001)
    expect_true(is_nugget(res, "associations"))
    expect_true(is_tibble(res))
    expect_equal(attr(res, "call_function"), "dig_associations")
    expect_true(is.list(attr(res, "call_args")))
    expect_equal(attr(res, "call_args")$antecedent, c("a", "b", "c"))
    expect_equal(attr(res, "call_args")$consequent, c("a", "b", "c"))
    expect_equal(attr(res, "call_args")$min_coverage, 0.8)
    expect_equal(attr(res, "call_args")$min_confidence, 0.0001)
    expect_equal(attr(res, "call_args")$disjoint, c(1, 2, 3))
    expect_true(is_tibble(res))
    expect_equal(nrow(res), 5)

    res <- dig_associations(d,
                            antecedent = everything(),
                            consequent = everything(),
                            disjoint = c(1, 2, 3),
                            min_coverage = 1,
                            min_confidence = 0.0001)
    expect_true(is_nugget(res, "associations"))
    expect_true(is_tibble(res))
    expect_equal(attr(res, "call_function"), "dig_associations")
    expect_true(is.list(attr(res, "call_args")))
    expect_equal(attr(res, "call_args")$antecedent, c("a", "b", "c"))
    expect_equal(attr(res, "call_args")$consequent, c("a", "b", "c"))
    expect_equal(attr(res, "call_args")$min_coverage, 1)
    expect_equal(attr(res, "call_args")$min_confidence, 0.0001)
    expect_equal(attr(res, "call_args")$disjoint, c(1, 2, 3))
    expect_true(is_tibble(res))
    expect_equal(nrow(res), 3)
})


test_that("compare dig_associations to arules::apriori", {
    skip_if_not_installed("arules")
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

    for (inter in c("addedValue", "centeredConfidence", "conviction")) {
        expected[[inter]] <- arules::interestMeasure(afit, inter)
    }

    expected <- expected[order(expected$LHS, expected$RHS), ]

    res <- dig_associations(m,
                            min_support = 0.001,
                            min_length = 0,
                            max_length = 5,
                            min_confidence = 0.5,
                            measures = c("lift",
                                         "conviction",
                                         "added_value"))
    expect_true(is_nugget(res, "associations"))
    expect_true(is_tibble(res))
    expect_equal(attr(res, "call_function"), "dig_associations")
    expect_true(is.list(attr(res, "call_args")))
    expect_equal(attr(res, "call_args")$min_support, 0.001)
    expect_equal(attr(res, "call_args")$min_length, 0)
    expect_equal(attr(res, "call_args")$max_length, 5)
    expect_equal(attr(res, "call_args")$min_confidence, 0.5)
    expect_equal(attr(res, "call_args")$measures, c("lift", "conviction", "added_value"))
    expect_true(is_tibble(res))

    res <- res[order(res$antecedent, res$consequent), ]

    expect_equal(res$antecedent, expected$LHS)
    expect_equal(res$consequent, expected$RHS)
    expect_equal(res$support, expected$support, tolerance = 1e-6)
    expect_equal(res$confidence, expected$confidence, tolerance = 1e-6)
    expect_equal(res$coverage, expected$coverage, tolerance = 1e-6)
    expect_equal(res$lift, expected$lift, tolerance = 1e-6)
    expect_equal(res$conviction, expected$conviction, tolerance = 1e-6)
    expect_equal(res$added_value, expected$addedValue, tolerance = 1e-6)
    expect_equal(res$count, expected$count)
})


test_that("dig_associations return object details", {
    d <- data.frame(a = c(T, T, F, F, F),
                    b = c(T, T, T, T, F),
                    c = c(T, F, F, T, T))

    res <- dig_associations(d,
                            antecedent = a:b,
                            consequent = b:c,
                            disjoint = c(1, 2, 2),
                            excluded = list("a"),
                            min_length = 1L,
                            max_length = Inf,
                            min_coverage = 0.2,
                            min_support = 0.3,
                            min_confidence = 0.5,
                            contingency_table = TRUE,
                            measures = c("lift", "conviction"),
                            t_norm = "lukas",
                            max_results = 10,
                            threads = 1)

    expect_true(is_nugget(res, "associations"))
    expect_true(is_tibble(res))
    expect_equal(attr(res, "call_function"), "dig_associations")
    expect_true(is.list(attr(res, "call_args")))
    expect_equal(attr(res, "call_args")$antecedent, c("a", "b"))
    expect_equal(attr(res, "call_args")$consequent, c("b", "c"))
    expect_equal(attr(res, "call_args")$disjoint, c(1, 2, 2))
    expect_equal(attr(res, "call_args")$excluded, list("a"))
    expect_equal(attr(res, "call_args")$min_length, 1)
    expect_equal(attr(res, "call_args")$max_length, Inf)
    expect_equal(attr(res, "call_args")$min_coverage, 0.2)
    expect_equal(attr(res, "call_args")$min_support, 0.3)
    expect_equal(attr(res, "call_args")$min_confidence, 0.5)
    expect_equal(attr(res, "call_args")$contingency_table, TRUE)
    expect_equal(attr(res, "call_args")$measures, c("lift", "conviction"))
    expect_equal(attr(res, "call_args")$t_norm, "lukas")
    expect_equal(attr(res, "call_args")$max_results, 10)
    expect_equal(attr(res, "call_args")$threads, 1)
    expect_true(is_tibble(res))
})


test_that("dig_associations errors", {
    d <- data.frame(a = c(T, T, F, F, F),
                    b = c(T, T, T, T, F),
                    c = c(T, F, F, T, T))
    d2 <- data.frame(a = c(T, T, F, F, F),
                     b = c(T, T, T, T, F),
                     c = as.character(c(T, F, F, T, T)))

    expect_error(dig_associations(as.list(d)),
                 "`x` must be a matrix or a data frame.")
    expect_error(dig_associations(d2, antecedent = b:c, consequent = a),
                 "All columns selected by `antecedent` must be logical or numeric from the interval")
    expect_error(dig_associations(d2, antecedent = a:b, consequent = c),
                 "All columns selected by `consequent` must be logical or numeric from the interval")
    expect_error(dig_associations(d, min_length = "x"),
                 "`min_length` must be an integerish scalar.")
    expect_error(dig_associations(d, max_length = "x"),
                 "`max_length` must be an integerish scalar.")
    expect_error(dig_associations(d, min_coverage = "x"),
                 "`min_coverage` must be a double scalar.")
    expect_error(dig_associations(d, min_support = "x"),
                 "`min_support` must be a double scalar.")
    expect_error(dig_associations(d, min_confidence = "x"),
                 "`min_confidence` must be a double scalar.")
})

test_that("dig_associations return nothing", {
    d <- data.frame(a = c(T, T, F, F, F),
                    b = c(T, T, T, T, F))

    res <- dig_associations(d,
                            antecedent = a,
                            consequent = b,
                            min_length = 3,
                            max_length = 3,
                            disjoint = c(1, 2),
                            min_support = 0.1,
                            min_confidence = 0.2,
                            measures = "lift",
                            t_norm = "lukas",
                            max_results = 5,
                            verbose = FALSE,
                            threads = 1)

    expect_true(is_nugget(res, "associations"))
    expect_true(is_tibble(res))
    expect_equal(nrow(res), 0)
    expect_equal(attr(res, "call_function"), "dig_associations")
    expect_true(is.list(attr(res, "call_args")))
})
