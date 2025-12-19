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


test_that("dig_tautologies max_length 0", {
    d <- data.frame(
        a = c(TRUE, TRUE, FALSE, FALSE, FALSE),
        b = c(TRUE, TRUE, TRUE, TRUE, FALSE),
        c = c(FALSE, FALSE, FALSE, TRUE, TRUE)
    )

    res <- dig_tautologies(d,
                           antecedent = everything(),
                           consequent = everything(),
                           min_support = 0.0001,
                           min_confidence = 0.0001,
                           max_length = 0)

    expect_true(is_nugget(res, "associations"))
    expect_true(is_tibble(res))
    expect_equal(attr(res, "call_function"), "dig_tautologies")
    expect_true(is.list(attr(res, "call_data")))
    expect_equal(attr(res, "call_data")$nrow, nrow(d))
    expect_equal(attr(res, "call_data")$ncol, ncol(d))
    expect_equal(attr(res, "call_data")$colnames, as.character(colnames(d)))
    expect_true(is.list(attr(res, "call_args")))
    expect_equal(attr(res, "call_args")$x, "d")
    args <- attr(res, "call_args")
    expect_equal(args$antecedent, c("a", "b", "c"))
    expect_equal(args$consequent, c("a", "b", "c"))
    expect_equal(args$max_length, 0)
    expect_equal(args$min_support, 0.0001)
    expect_equal(args$min_confidence, 0.0001)
    expect_equal(args$t_norm, "goguen")

    expect_true(all(c("antecedent", "consequent", "support", "confidence") %in% names(res)))
    expect_true(nrow(res) == 3)

    res <- dig_tautologies(d,
                           antecedent = everything(),
                           consequent = everything(),
                           min_support = 0.0001,
                           min_confidence = 0.5,
                           max_length = 0)

    expect_true(is_nugget(res, "associations"))
    expect_true(is_tibble(res))
    expect_true(nrow(res) == 1)
    expect_equal(attr(res, "call_function"), "dig_tautologies")
    expect_true(is.list(attr(res, "call_data")))
    expect_true(is.list(attr(res, "call_args")))

    res <- dig_tautologies(d,
                           antecedent = everything(),
                           consequent = everything(),
                           min_support = 0.0001,
                           min_confidence = 0.0001,
                           max_results = 2,
                           max_length = 0)

    expect_true(is_nugget(res, "associations"))
    expect_true(is_tibble(res))
    expect_true(nrow(res) == 2)
    expect_equal(attr(res, "call_function"), "dig_tautologies")
    expect_true(is.list(attr(res, "call_data")))
    expect_true(is.list(attr(res, "call_args")))
    expect_true(is.list(attr(res, "call_args")))
})


test_that("dig_tautologies max_length 1", {
    d <- data.frame(
        a = c(TRUE, TRUE, FALSE, FALSE, FALSE),
        b = c(TRUE, TRUE, TRUE, TRUE, FALSE),
        c = c(TRUE, FALSE, FALSE, FALSE, FALSE)
    )

    res <- dig_tautologies(d,
                           antecedent = everything(),
                           consequent = everything(),
                           min_support = 0.0001,
                           min_confidence = 0.5,
                           max_length = 1)

    expect_true(is_nugget(res, "associations"))
    expect_true(is_tibble(res))
    expect_equal(attr(res, "call_function"), "dig_tautologies")
    expect_true(is.list(attr(res, "call_data")))
    expect_equal(attr(res, "call_data")$nrow, nrow(d))
    expect_equal(attr(res, "call_data")$ncol, ncol(d))
    expect_equal(attr(res, "call_data")$colnames, as.character(colnames(d)))
    expect_true(is.list(attr(res, "call_args")))
    expect_equal(attr(res, "call_args")$x, "d")

    args <- attr(res, "call_args")
    expect_equal(args$antecedent, c("a", "b", "c"))
    expect_equal(args$consequent, c("a", "b", "c"))
    expect_equal(args$max_length, 1)
    expect_equal(args$min_support, 0.0001)
    expect_equal(args$min_confidence, 0.5)
    expect_equal(args$t_norm, "goguen")

    expect_true(all(c("antecedent", "consequent", "support", "confidence") %in% names(res)))
    expect_true(nrow(res) == 3)

    res <- dig_tautologies(d,
                           antecedent = everything(),
                           consequent = everything(),
                           min_support = 0.0001,
                           min_confidence = 0.5,
                           max_results = 2,
                           max_length = 1)

    expect_true(is_nugget(res, "associations"))
    expect_true(is_tibble(res))
    expect_equal(attr(res, "call_function"), "dig_tautologies")
    expect_true(is.list(attr(res, "call_data")))
    expect_equal(attr(res, "call_data")$nrow, nrow(d))
    expect_equal(attr(res, "call_data")$ncol, ncol(d))
    expect_equal(attr(res, "call_data")$colnames, as.character(colnames(d)))
    expect_true(is.list(attr(res, "call_args")))
    expect_equal(attr(res, "call_args")$x, "d")
    args <- attr(res, "call_args")
    expect_equal(args$antecedent, c("a", "b", "c"))
    expect_equal(args$consequent, c("a", "b", "c"))
    expect_equal(args$max_length, 1)
    expect_equal(args$max_results, 2)
    expect_equal(args$min_support, 0.0001)
    expect_equal(args$min_confidence, 0.5)
    expect_equal(args$t_norm, "goguen")

    expect_true(all(c("antecedent", "consequent", "support", "confidence") %in% names(res)))
    expect_true(nrow(res) == 2)
})


test_that("dig_tautologies stops when dig_associations returns empty", {
    d <- data.frame(a = c(TRUE, FALSE, FALSE, FALSE),
                    b = c(FALSE, FALSE, FALSE, FALSE))

    res <- dig_tautologies(d,
                           antecedent = everything(),
                           consequent = everything(),
                           min_support = 1,
                           min_confidence = 1)

    expect_true(is_nugget(res, "associations"))
    expect_true(is_tibble(res))
    expect_equal(nrow(res), 0)
})

test_that("dig_tautologies argument forwarding and attributes", {
    d <- data.frame(
        a = c(TRUE, TRUE, FALSE, FALSE, FALSE),
        b = c(TRUE, TRUE, TRUE, TRUE, FALSE)
    )

    suppressWarnings(
        res <- dig_tautologies(
            d,
            antecedent = a,
            consequent = b,
            disjoint = c(1, 2),
            max_length = 2,
            min_support = 0.1,
            min_confidence = 0.2,
            t_norm = "lukas",
            max_results = 5,
            verbose = FALSE,
            threads = 1
        )
    )

    expect_true(is_nugget(res, "associations"))
    expect_equal(attr(res, "call_function"), "dig_tautologies")
    expect_true(is.list(attr(res, "call_data")))
    expect_equal(attr(res, "call_data")$nrow, nrow(d))
    expect_equal(attr(res, "call_data")$ncol, ncol(d))
    expect_equal(attr(res, "call_data")$colnames, as.character(colnames(d)))
    expect_true(is.list(attr(res, "call_args")))
    expect_equal(attr(res, "call_args")$x, "d")
    args <- attr(res, "call_args")
    expect_equal(args$disjoint, c(1, 2))
    expect_equal(args$max_length, 2)
    expect_equal(args$min_support, 0.1)
    expect_equal(args$min_confidence, 0.2)
    expect_equal(args$t_norm, "lukas")
    expect_equal(args$max_results, 5)
    expect_true(is_tibble(res))
})

test_that("dig_tautologies handles invalid arguments", {
    d <- data.frame(a = c(T, T, F, F, F),
                    b = c(T, T, T, T, F),
                    c = c(T, F, F, T, T))
    d2 <- data.frame(a = c(T, T, F, F, F),
                     b = c(T, T, T, T, F),
                     c = as.character(c(T, F, F, T, T)))


    expect_error(dig_tautologies(as.list(d)),
                 "`x` must be a matrix or a data frame.")
    expect_error(dig_tautologies(d2, antecedent = b:c, consequent = a),
                 "All columns selected by `antecedent` must be logical or numeric from the interval")
    expect_error(dig_tautologies(d2, antecedent = a:b, consequent = c),
                 "All columns selected by `consequent` must be logical or numeric from the interval")
    expect_error(dig_tautologies(d, disjoint = "foo"),
                 "The length of `disjoint` must be 0 or must be equal to the number of columns in `x`")
    expect_error(dig_tautologies(d, max_length = "x"),
                 "`max_length` must be an integerish scalar.")
    expect_error(dig_tautologies(d, min_coverage = "x"),
                 "`min_coverage` must be a double scalar.")
    expect_error(dig_tautologies(d, min_support = "x"),
                 "`min_support` must be a double scalar.")
    expect_error(dig_tautologies(d, min_confidence = "x"),
                 "`min_confidence` must be a double scalar.")
    expect_error(dig_tautologies(d, t_norm = "x"),
                 "`t_norm` must be equal to one of")
    expect_error(dig_tautologies(d, max_results = "x"),
                 "`max_results` must be an integerish scalar.")
    expect_error(dig_tautologies(d, verbose = "x"),
                 "`verbose` must be a flag.")
    expect_error(dig_tautologies(d, threads = "x"),
                 "`threads` must be an integerish scalar.")
})
