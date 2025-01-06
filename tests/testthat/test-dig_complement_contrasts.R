test_that("dig_complement_contrasts t", {
    d <- partition(CO2, Plant:Treatment)

    res <- dig_complement_contrasts(d,
                         condition = where(is.logical),
                         vars = conc:uptake,
                         min_support = 0.1)

    expect_true(is_tibble(res))
    expect_equal(nrow(res), 7)
    expect_equal(ncol(res), 16)
    expect_true(is.character(res$condition))
    expect_equal(res$support, c(0.5, 0.5, 0.5, 0.5, 0.25, 0.25, 0.25))
    expect_equal(res$var, rep(c("uptake"), 7))

    res <- dig_complement_contrasts(d,
                         condition = where(is.logical),
                         vars = conc:uptake,
                         min_support = 0.1,
                         max_p_value = 1e-8)

    expect_true(is_tibble(res))
    expect_equal(nrow(res), 3)
    expect_equal(ncol(res), 16)
})

test_that("dig_complement_contrasts wilcox", {
    d <- partition(CO2, Plant:Treatment)

    res <- dig_complement_contrasts(d,
                         condition = where(is.logical),
                         vars = conc:uptake,
                         method = "wilcox",
                         min_support = 0.1)

    expect_true(is_tibble(res))
    expect_equal(nrow(res), 7)
    expect_equal(ncol(res), 13)
    expect_equal(res$support, c(0.5, 0.5, 0.5, 0.5, 0.25, 0.25, 0.25))
    expect_equal(res$var, rep(c("uptake"), 7))

    res <- dig_complement_contrasts(d,
                         condition = where(is.logical),
                         vars = conc:uptake,
                         method = "wilcox",
                         min_support = 0.1,
                         max_p_value = 1e-7)

    expect_true(is_tibble(res))
    expect_equal(nrow(res), 3)
    expect_equal(ncol(res), 13)
})

test_that("dig_paired contrasts errors", {
    d <- data.frame(n = 1:5 / 5, l = TRUE, i = 1:5, s = letters[1:5])

    expect_error(dig_complement_contrasts(x = 1:5),
                 "`x` must be a matrix or a data frame")
    expect_error(dig_complement_contrasts(d, condition = n:l),
                 "All columns selected by `condition` must be logical.")
    expect_error(dig_complement_contrasts(d, vars = s),
                 "All columns selected by `vars` must be numeric.")
    expect_error(dig_complement_contrasts(d, method = "foo"),
                 '`method` must be equal to one of: "t", "wilcox".')
    expect_error(dig_complement_contrasts(d, alternative = "foo"),
                 '`alternative` must be equal to one of: "two.sided", "less", "greater".')
    expect_error(dig_complement_contrasts(d, min_length = "x"),
                 "`min_length` must be an integerish scalar.")
})
