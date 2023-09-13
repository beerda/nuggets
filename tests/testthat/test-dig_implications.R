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
    expect_equal(nrow(res), 4)
    expect_equal(colnames(res),
                 c("antecedent", "consequent", "support", "confidence"))
    expect_true(is.character(res$antecedent))
    expect_true(is.character(res$consequent))
    expect_true(is.double(res$support))
    expect_true(is.double(res$confidence))
})
