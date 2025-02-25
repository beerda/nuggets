test_that("dig_baseline_contrasts t", {
    d <- partition(CO2, Plant:Treatment)

    res <- dig_baseline_contrasts(d,
                         condition = where(is.logical),
                         vars = conc:uptake,
                         min_support = 0.1)

    expect_true(is_tibble(res))
    expect_equal(nrow(res), 18)
    expect_equal(ncol(res), 15)
    expect_true(is.character(res$condition))
    expect_equal(res$support, c(1, 1, rep(0.5, 8), rep(0.25, 8)))
    expect_equal(res$var, rep(c("conc", "uptake"), 9))

    res <- dig_baseline_contrasts(d,
                         condition = where(is.logical),
                         vars = conc:uptake,
                         min_support = 0.1,
                         max_p_value = 1e-20)

    expect_true(is_tibble(res))
    expect_equal(nrow(res), 4)
    expect_equal(ncol(res), 15)
})

test_that("dig_baseline_contrasts wilcox", {
    d <- partition(CO2, Plant:Treatment)

    res <- dig_baseline_contrasts(d,
                         condition = where(is.logical),
                         vars = conc:uptake,
                         method = "wilcox",
                         min_support = 0.1)

    expect_true(is_tibble(res))
    expect_equal(nrow(res), 18)
    expect_equal(ncol(res), 13)
    expect_equal(res$support, c(1, 1, rep(0.5, 8), rep(0.25, 8)))
    expect_equal(res$var, rep(c("conc", "uptake"), 9))

    res <- dig_baseline_contrasts(d,
                         condition = where(is.logical),
                         vars = conc:uptake,
                         method = "wilcox",
                         min_support = 0.1,
                         max_p_value = 1e-5)

    expect_true(is_tibble(res))
    expect_equal(nrow(res), 10)
    expect_equal(ncol(res), 13)
})

test_that("dig_paired contrasts errors", {
    d <- data.frame(n = 1:5 / 5, l = TRUE, i = 1:5, s = letters[1:5])

    expect_error(dig_baseline_contrasts(x = 1:5),
                 "`x` must be a matrix or a data frame")
    expect_error(dig_baseline_contrasts(d, condition = n:l),
                 "All columns selected by `condition` must be logical.")
    expect_error(dig_baseline_contrasts(d, vars = s),
                 "All columns selected by `vars` must be numeric.")
    expect_error(dig_baseline_contrasts(d, method = "foo"),
                 '`method` must be equal to one of: "t", "wilcox".')
    expect_error(dig_baseline_contrasts(d, alternative = "foo"),
                 '`alternative` must be equal to one of: "two.sided", "less", "greater".')
    expect_error(dig_baseline_contrasts(d, min_length = "x"),
                 "`min_length` must be an integerish scalar.")
})
