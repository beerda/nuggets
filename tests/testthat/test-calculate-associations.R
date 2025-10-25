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

    expect_true(length(names(.arules_association_measures)) > 0)
    for (m in names(.arules_association_measures)) {
        expected[[m]] <- arules::interestMeasure(afit, to_camel(m))
    }

    expected <- expected[order(expected$LHS, expected$RHS), ]

    res <- dig_associations(d,
                            min_support = 0.001,
                            min_length = 0,
                            max_length = 5,
                            min_confidence = 0.5,
                            contingency_table = TRUE)
    res <- calculate(res, measure = names(.arules_association_measures))

    expect_true(is_nugget(res, "associations"))
    expect_true(is_tibble(res))
    res <- res[order(res$antecedent, res$consequent), ]

    expect_equal(res$antecedent, expected$LHS)
    expect_equal(res$consequent, expected$RHS)
    for (m in names(.arules_association_measures)) {
        expect_equal(res[[!!m]], !!(expected[[m]]), tolerance = 1e-7)
    }
})
