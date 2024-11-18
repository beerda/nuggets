test_that("dig_paired_contrasts t", {
    d <- partition(CO2, Plant:Treatment)

    res <- dig_paired_contrasts(d,
                         condition = where(is.logical),
                         xvars = conc,
                         yvars = uptake,
                         min_support = 0.1)

    expect_true(is_tibble(res))
    expect_equal(nrow(res), 9)
    expect_equal(ncol(res), 15)
    expect_true(is.character(res$condition))
    expect_equal(res$support, c(1, 0.5, 0.5, 0.5, 0.5, 0.25, 0.25, 0.25, 0.25))
    expect_equal(res$xvar, rep("conc", 9))
    expect_equal(res$yvar, rep("uptake", 9))

    res <- dig_paired_contrasts(d,
                         condition = where(is.logical),
                         xvars = conc,
                         yvars = uptake,
                         min_support = 0.1,
                         max_p_value = 1e-7)

    expect_true(is_tibble(res))
    expect_equal(nrow(res), 5)
    expect_equal(ncol(res), 15)
})

test_that("dig_paired_contrasts wilcox", {
    d <- partition(CO2, Plant:Treatment)

    res <- dig_paired_contrasts(d,
                         condition = where(is.logical),
                         xvars = conc,
                         yvars = uptake,
                         method = "wilcox",
                         min_support = 0.1)

    expect_true(is_tibble(res))
    expect_equal(nrow(res), 9)
    expect_equal(ncol(res), 12)
    expect_equal(res$support, c(1, 0.5, 0.5, 0.5, 0.5, 0.25, 0.25, 0.25, 0.25))
    expect_equal(res$xvar, rep("conc", 9))
    expect_equal(res$yvar, rep("uptake", 9))

    res <- dig_paired_contrasts(d,
                         condition = where(is.logical),
                         xvars = conc,
                         yvars = uptake,
                         method = "wilcox",
                         min_support = 0.1,
                         max_p_value = 1e-5)

    expect_true(is_tibble(res))
    expect_equal(nrow(res), 5)
    expect_equal(ncol(res), 12)
})

test_that("dig_paired_contrasts var", {
    d <- partition(CO2, Plant:Treatment)

    res <- dig_paired_contrasts(d,
                         condition = where(is.logical),
                         xvars = conc,
                         yvars = uptake,
                         method = "var",
                         min_support = 0.1)

    expect_true(is_tibble(res))
    expect_equal(nrow(res), 9)
    expect_equal(ncol(res), 14)
    expect_equal(res$support, c(1, 0.5, 0.5, 0.5, 0.5, 0.25, 0.25, 0.25, 0.25))
    expect_equal(res$xvar, rep("conc", 9))
    expect_equal(res$yvar, rep("uptake", 9))
    expect_equal(res$p_value, rep(0, 9))
})
