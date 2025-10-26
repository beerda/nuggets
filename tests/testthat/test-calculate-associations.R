test_that("compare calculate.associations to arules::interestMeasure", {
    skip_if_not_installed("arules")
    set.seed(2123)
    rows <- 100
    cols <- 5
    d <- matrix(sample(c(T, F), rows * cols, replace = TRUE),
                nrow = rows,
                ncol = cols)
    colnames(d) <- letters[seq_len(cols)]

    afit <- arules::apriori(d, parameter = list(minlen = 1,
                                        maxlen = 6,
                                        supp=0.001,
                                        conf = 0.5),
                    control = list(verbose = FALSE))

    expected <- arules::DATAFRAME(afit)
    expected$LHS <- as.character(expected$LHS)
    expected$RHS <- as.character(expected$RHS)

    to_camel <- function(x) {
        parts <- strsplit(x, "_")[[1]]
        res <- sapply(parts[-1], function(p) {
            paste0(toupper(substring(p, 1,1)), substring(p, 2))
        })
        paste0(parts[1], paste0(res, collapse = ""))
    }

    expected_no_smoothing <- expected
    expected_smooth1 <- expected
    rm(expected)

    expect_true(length(names(.arules_association_measures)) > 0)
    for (m in names(.arules_association_measures)) {
        expected_no_smoothing[[m]] <- arules::interestMeasure(afit, to_camel(m))
        expected_smooth1[[m]] <- arules::interestMeasure(afit, to_camel(m), smoothCount = 1)
    }

    expected_no_smoothing <- expected_no_smoothing[order(expected_no_smoothing$LHS, expected_no_smoothing$RHS), ]
    expected_smooth1 <- expected_smooth1[order(expected_smooth1$LHS, expected_smooth1$RHS), ]

    fit <- dig_associations(d,
                            min_support = 0.001,
                            min_length = 0,
                            max_length = 5,
                            min_confidence = 0.5,
                            contingency_table = TRUE)

    # no smoothing
    res <- calculate(fit,
                     measure = names(.arules_association_measures))

    expect_true(is_nugget(res, "associations"))
    expect_true(is_tibble(res))
    res <- res[order(res$antecedent, res$consequent), ]

    expect_equal(res$antecedent, expected_no_smoothing$LHS)
    expect_equal(res$consequent, expected_no_smoothing$RHS)
    for (m in names(.arules_association_measures)) {
        expect_equal(res[[!!m]], !!(expected_no_smoothing[[m]]), tolerance = 1e-7)
    }

    # smoothing = 1
    res <- calculate(fit,
                     measure = names(.arules_association_measures),
                     smooth_counts = 1)

    expect_true(is_nugget(res, "associations"))
    expect_true(is_tibble(res))
    res <- res[order(res$antecedent, res$consequent), ]

    expect_equal(res$antecedent, expected_smooth1$LHS)
    expect_equal(res$consequent, expected_smooth1$RHS)
    for (m in names(.arules_association_measures)) {
        expect_equal(res[[!!m]], !!(expected_smooth1[[m]]), tolerance = 1e-7)
    }

})
