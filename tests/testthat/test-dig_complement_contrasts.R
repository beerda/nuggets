test_that("dig_complement_contrasts t", {
    d <- partition(CO2, Plant:Treatment)

    res <- dig_complement_contrasts(d,
                         condition = where(is.logical),
                         vars = conc:uptake,
                         min_support = 0.1)

    expect_true(is_nugget(res, flavour = "complement_contrasts"))
    expect_true(is_tibble(res))
    expect_equal(nrow(res), 7)
    expect_equal(ncol(res), 17)
    expect_true(is.character(res$condition))
    expect_setequal(res$support, c(0.5, 0.5, 0.5, 0.5, 0.25, 0.25, 0.25))
    expect_setequal(res$var, rep(c("uptake"), 7))

    res <- dig_complement_contrasts(d,
                         condition = where(is.logical),
                         vars = conc:uptake,
                         min_support = 0.1,
                         max_p_value = 1e-8)

    expect_true(is_nugget(res, flavour = "complement_contrasts"))
    expect_true(is_tibble(res))
    expect_equal(nrow(res), 3)
    expect_equal(ncol(res), 17)
})

test_that("dig_complement_contrasts wilcox", {
    d <- partition(CO2, Plant:Treatment)

    res <- dig_complement_contrasts(d,
                         condition = where(is.logical),
                         vars = conc:uptake,
                         method = "wilcox",
                         min_support = 0.1)

    expect_true(is_nugget(res, flavour = "complement_contrasts"))
    expect_true(is_tibble(res))
    expect_equal(nrow(res), 7)
    expect_equal(ncol(res), 14)
    expect_setequal(res$support, c(0.5, 0.5, 0.5, 0.5, 0.25, 0.25, 0.25))
    expect_setequal(res$var, rep(c("uptake"), 7))

    res <- dig_complement_contrasts(d,
                         condition = where(is.logical),
                         vars = conc:uptake,
                         method = "wilcox",
                         min_support = 0.1,
                         max_p_value = 1e-7)

    expect_true(is_nugget(res, flavour = "complement_contrasts"))
    expect_true(is_tibble(res))
    expect_equal(nrow(res), 3)
    expect_equal(ncol(res), 14)
})

test_that("dig_complement_contrasts call args", {
    d <- partition(CO2, Plant:Treatment)

    res <- dig_complement_contrasts(d,
                         condition = where(is.logical),
                         vars = conc:uptake,
                         disjoint = var_names(colnames(d)),
                         excluded = list("Plant=Qn1"),
                         min_length = 1L,
                         max_length = 2L,
                         min_support = 0.1,
                         max_support = 0.9,
                         method = "wilcox",
                         alternative = "greater",
                         h0 = 1,
                         conf_level = 0.9,
                         max_p_value = 0.01,
                         t_var_equal = TRUE,
                         wilcox_exact = TRUE,
                         wilcox_correct = FALSE,
                         wilcox_tol_root = 1e-3,
                         wilcox_digits_rank = 5,
                         max_results = 100,
                         verbose = TRUE,
                         threads = 1)

    expect_true(is_nugget(res, flavour = "complement_contrasts"))
    expect_true(is_tibble(res))
    expect_equal(attr(res, "call_function"), "dig_complement_contrasts")
    expect_true(is.list(attr(res, "call_data")))
    expect_equal(attr(res, "call_data")$nrow, nrow(d))
    expect_equal(attr(res, "call_data")$ncol, ncol(d))
    expect_equal(attr(res, "call_data")$colnames, as.character(colnames(d)))
    expect_true(is.list(attr(res, "call_args")))
    expect_equal(attr(res, "call_args")$x, "d")
    expect_equal(attr(res, "call_args")$condition,
                 c("Plant=Qn1", "Plant=Qn2", "Plant=Qn3",
                   "Plant=Qc1", "Plant=Qc3", "Plant=Qc2",
                   "Plant=Mn3", "Plant=Mn2", "Plant=Mn1",
                   "Plant=Mc2", "Plant=Mc3", "Plant=Mc1",
                   "Type=Quebec", "Type=Mississippi",
                   "Treatment=nonchilled", "Treatment=chilled"))
    expect_equal(attr(res, "call_args")$vars, c("conc", "uptake"))
    expect_equal(attr(res, "call_args")$disjoint,
                 c("conc", "uptake", "Plant", "Plant", "Plant",
                   "Plant", "Plant", "Plant", "Plant", "Plant", "Plant",
                   "Plant", "Plant", "Plant", "Type", "Type",
                   "Treatment", "Treatment"))
    expect_equal(attr(res, "call_args")$excluded, list("Plant=Qn1"))
    expect_equal(attr(res, "call_args")$min_length, 1L)
    expect_equal(attr(res, "call_args")$max_length, 2L)
    expect_equal(attr(res, "call_args")$min_support, 0.1)
    expect_equal(attr(res, "call_args")$max_support, 0.9)
    expect_equal(attr(res, "call_args")$method, "wilcox")
    expect_equal(attr(res, "call_args")$alternative, "greater")
    expect_equal(attr(res, "call_args")$h0, 1)
    expect_equal(attr(res, "call_args")$conf_level, 0.9)
    expect_equal(attr(res, "call_args")$max_p_value, 0.01)
    expect_true(attr(res, "call_args")$t_var_equal)
    expect_true(attr(res, "call_args")$wilcox_exact)
    expect_false(attr(res, "call_args")$wilcox_correct)
    expect_equal(attr(res, "call_args")$wilcox_tol_root, 1e-3)
    expect_equal(attr(res, "call_args")$wilcox_digits_rank, 5)
    expect_equal(attr(res, "call_args")$max_results, 100)
    expect_equal(attr(res, "call_args")$verbose, TRUE)
    expect_equal(attr(res, "call_args")$threads, 1L)
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
