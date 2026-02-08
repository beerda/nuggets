#######################################################################
# nuggets: An R framework for exploration of patterns in data
# Copyright (C) 2025 Michal Burda
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program. If not, see <https://www.gnu.org/licenses/>.
#######################################################################


test_that("measure names are equal in internal lists", {
    m <- .get_supported_association_measures()
    n <- .get_supported_association_measure_names()

    expect_equal(names(m), names(n))
})


test_that("add_interest.associations(measures = NULL)", {
    set.seed(2123)
    rows <- 100
    cols <- 5
    d <- matrix(sample(c(T, F), rows * cols, replace = TRUE),
                nrow = rows,
                ncol = cols)
    colnames(d) <- letters[seq_len(cols)]

    fit <- dig_associations(d,
                            min_support = 0.001,
                            min_length = 0,
                            max_length = 5,
                            min_confidence = 0.5)

    res <- add_interest(fit, measures = NULL)
    expect_true(is_nugget(res, "associations"))
    expect_true(is_tibble(res))
    expect_equal(attr(res, "call_function"), "dig_associations")
    expect_true(is.list(attr(res, "call_data")))
    expect_true(is.list(attr(res, "call_args")))
    expect_equal(ncol(res),
                 ncol(fit) +
                     length(names(.arules_association_measures)) +
                     length(names(.guha_association_measures)))
})


test_that("add_interest.associations() test GUHA quantifiers", {
    set.seed(2123)
    rows <- 100
    cols <- 5
    d <- matrix(sample(c(T, F), rows * cols, replace = TRUE),
                nrow = rows,
                ncol = cols)
    colnames(d) <- letters[seq_len(cols)]

    fit <- dig_associations(d,
                            min_support = 0.001,
                            min_length = 0,
                            max_length = 5,
                            min_confidence = 0.5)

    guha <- c("fi", "dfi", "fe", "lci", "uci", "dlci", "duci", "lce", "uce")
    p <- 0.8
    a <- fit$pp
    b <- fit$pn
    c <- fit$np
    d <- fit$nn

    res <- add_interest(fit, measures = guha, p = p)

    expect_true(is_nugget(res, "associations"))
    expect_true(is_tibble(res))
    expect_true(all(guha %in% colnames(res)))

    expect_equal(res$fi, a / (a + b))
    expect_equal(res$dfi, a / (a + b + c))
    expect_equal(res$fe, (a + d) / (a + b + c + d))

    lci_fun <- function(a, b, c, d) {
        i <- seq(a, a+b)
        res <- factorial(a+b) * p^i * (1-p)^(a+b - i) / (factorial(i) * factorial(a+b - i))
        sum(res)
    }
    expect_equal(res$lci, mapply(lci_fun, a, b, c, d))

    uci_fun <- function(a, b, c, d) {
        i <- seq(0, a)
        res <- factorial(a+b) * p^i * (1-p)^(a+b - i) / (factorial(i) * factorial(a+b - i))
        sum(res)
    }
    expect_equal(res$uci, mapply(uci_fun, a, b, c, d))

    dlci_fun <- function(a, b, c, d) {
        i <- seq(a, a+b+c)
        res <- factorial(a+b+c) * p^i * (1-p)^(a+b+c - i) / (factorial(i) * factorial(a+b+c - i))
        sum(res)
    }
    expect_equal(res$dlci, mapply(dlci_fun, a, b, c, d))

    duci_fun <- function(a, b, c, d) {
        i <- seq(0, a)
        res <- factorial(a+b+c) * p^i * (1-p)^(a+b+c - i) / (factorial(i) * factorial(a+b+c - i))
        sum(res)
    }
    expect_equal(res$duci, mapply(duci_fun, a, b, c, d))

    lce_fun <- function(a, b, c, d) {
        i <- seq(a, a+b+c+d)
        res <- factorial(a+b+c+d) * p^i * (1-p)^(a+b+c+d - i) / (factorial(i) * factorial(a+b+c+d - i))
        sum(res)
    }
    expect_equal(res$lce, mapply(lce_fun, a, b, c, d))

    uce_fun <- function(a, b, c, d) {
        i <- seq(0, a)
        res <- factorial(a+b+c+d) * p^i * (1-p)^(a+b+c+d - i) / (factorial(i) * factorial(a+b+c+d - i))
        sum(res)
    }
    expect_equal(res$uce, mapply(uce_fun, a, b, c, d))
})


test_that("compare add_interest.associations to arules::interestMeasure", {
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
                            min_confidence = 0.5)

    # no smoothing
    res <- add_interest(fit,
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
    res <- add_interest(fit,
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
