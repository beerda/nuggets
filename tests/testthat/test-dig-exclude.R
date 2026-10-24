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


test_that("exclude tautology 1", {
    d <- data.frame(a = c(T,    T, T, F, F),
                    b = c(T,    F, T, T, T),
                    c = c(T,    T, F, F, F),
                    d = c(T,    F, F, F, F),
                    x = c(1.0,  0.1, 0.2, 0.3, 0.4),
                    y = c(1.0,  0.9, 0.8, 0.7, 0.6),
                    z = c(1.0,  0.8, 0.6, 0.4, 0.2),
                    w = c(1.0,  0, 0, 0, 0))

    comb <- function(ante, n) {
        res <- combn(ante, n)
        apply(res, 2, function(w) {
            w <- sort(w)
            paste(w, collapse = " & ")
        })
    }

    comb2 <- function(ante, n, conseq) {
        result <- lapply(conseq, function(cc) {
            a <- setdiff(ante, cc)
            res <- comb(a, n)
            paste(res, "|", cc)
        })

        unlist(result)
    }

    f <- function(condition, pp) {
        paste(paste(sort(names(condition)), collapse = " & "),
              "|",
              sort(names(pp)))
    }

    sel <- c("a", "b", "c", "x", "y", "z")
    selnoX <- c("a", "b", "c", "y", "z")
    selnoC <- c("a", "b", "x", "y", "z")

    # no exclude
    expected <- c(comb2(sel, 1, sel),
                  comb2(sel, 2, sel),
                  comb2(sel, 3, sel))
    res <- dig(d,
               f,
               condition = c(a, b, c, x, y, z),
               focus = c(a, b, c, x, y, z),
               min_length = 1,
               max_length = 3)

    expect_true(is_nugget(res))
    expect_true(is.list(res))
    expect_equal(attr(res, "call_function"), "dig")
    expect_true(is.list(attr(res, "call_data")))
    expect_equal(attr(res, "call_data")$nrow, nrow(d))
    expect_equal(attr(res, "call_data")$ncol, ncol(d))
    expect_equal(attr(res, "call_data")$colnames, as.character(colnames(d)))
    expect_true(is.list(attr(res, "call_args")))
    expect_equal(attr(res, "call_args")$x, "d")
    expect_equal(attr(res, "call_args")$condition, c("a", "b", "c", "x", "y", "z"))
    expect_equal(attr(res, "call_args")$focus, c("a", "b", "c", "x", "y", "z"))
    expect_equal(attr(res, "call_args")$min_length, 1)
    expect_equal(attr(res, "call_args")$max_length, 3)
    expect_equal(attr(res, "call_args")$excluded, NULL)
    expect_equal(sort(unlist(res)), sort(expected))


    # exclude "-> x"
    expected <- c(comb2(selnoX, 1, selnoX),
                  comb2(selnoX, 2, selnoX),
                  comb2(selnoX, 3, selnoX))
    res <- dig(d,
               f,
               condition = c(a, b, c, x, y, z),
               focus = c(a, b, c, x, y, z),
               excluded = list(c("x")),
               min_length = 1,
               max_length = 3)

    expect_true(is_nugget(res))
    expect_true(is.list(res))
    expect_equal(attr(res, "call_function"), "dig")
    expect_true(is.list(attr(res, "call_data")))
    expect_equal(attr(res, "call_data")$nrow, nrow(d))
    expect_equal(attr(res, "call_data")$ncol, ncol(d))
    expect_equal(attr(res, "call_data")$colnames, as.character(colnames(d)))
    expect_true(is.list(attr(res, "call_args")))
    expect_equal(attr(res, "call_args")$x, "d")
    expect_equal(attr(res, "call_args")$condition, c("a", "b", "c", "x", "y", "z"))
    expect_equal(attr(res, "call_args")$focus, c("a", "b", "c", "x", "y", "z"))
    expect_equal(attr(res, "call_args")$min_length, 1)
    expect_equal(attr(res, "call_args")$max_length, 3)
    expect_equal(attr(res, "call_args")$excluded, list("x"))
    expect_equal(sort(unlist(res)), sort(expected))

    # exclude "c -> x"
    expected <- c(setdiff(comb2(sel, 1, sel),
                          c("c | x")),
                  setdiff(comb2(sel, 2, sel),
                          c("a & c | x", "b & c | x", "c & y | x", "c & z | x",
                            "c & x | a", "c & x | b", "c & x | y", "c & x | z")),
                  setdiff(comb2(sel, 3, sel),
                          c("a & b & c | x", "a & c & y | x", "a & c & z | x", "b & c & y | x", "b & c & z | x", "c & y & z | x",
                            "a & c & x | b", "a & c & x | y", "a & c & x | z",
                            "b & c & x | a", "b & c & x | y", "b & c & x | z",
                            "c & x & y | a", "c & x & y | b", "c & x & y | z",
                            "c & x & z | a", "c & x & z | b", "c & x & z | y")))

    res <- dig(d,
               f,
               #             1  2  3  5  6  7
               condition = c(a, b, c, x, y, z),
               focus = c(a, b, c, x, y, z),
               excluded = list(c("c", "x")),
               min_length = 1,
               max_length = 3)

    expect_true(is_nugget(res))
    expect_true(is.list(res))
    expect_equal(attr(res, "call_function"), "dig")
    expect_true(is.list(attr(res, "call_data")))
    expect_equal(attr(res, "call_data")$nrow, nrow(d))
    expect_equal(attr(res, "call_data")$ncol, ncol(d))
    expect_equal(attr(res, "call_data")$colnames, as.character(colnames(d)))
    expect_true(is.list(attr(res, "call_args")))
    expect_equal(attr(res, "call_args")$x, "d")
    expect_equal(attr(res, "call_args")$condition, c("a", "b", "c", "x", "y", "z"))
    expect_equal(attr(res, "call_args")$focus, c("a", "b", "c", "x", "y", "z"))
    expect_equal(attr(res, "call_args")$min_length, 1)
    expect_equal(attr(res, "call_args")$max_length, 3)
    expect_equal(attr(res, "call_args")$excluded, list(c("c", "x")))
    expect_equal(sort(unlist(res)), sort(expected))
})


test_that("exclude tautology in full combinations", {
    f <- function(condition, pp) {
        paste(paste(sort(names(condition)), collapse = "&"),
              "|",
              paste(sort(names(pp)), collapse = ","))
    }

    orig_data <- data.frame(a = rep(T, 10),
                            b = rep(T, 10),
                            c = rep(T, 10))

    permutations <- permute(seq_len(ncol(orig_data)))

    # loop through all permutations of columns
    for (row in seq_len(nrow(permutations))) {
        d <- orig_data[, permutations[row, ], drop = FALSE]

        # full list of combinations
        res <- dig(d,
                   f = f,
                   condition = everything(),
                   focus = everything(),
                   filter_empty_foci = FALSE,
                   excluded = NULL,
                   min_support = 0.0001)
        res <- unlist(res)
        expect_equal(sort(res),
                     sort(c(" | a,b,c",
                            "a | b,c", "b | a,c", "c | a,b",
                            "a&b | c", "a&c | b", "b&c | a",
                            "a&b&c | ")))

        # filter empty foci only
        res <- dig(d,
                   f = f,
                   condition = everything(),
                   focus = everything(),
                   filter_empty_foci = TRUE,
                   excluded = NULL,
                   min_support = 0.0001)
        res <- unlist(res)
        expect_equal(sort(res),
                     sort(c(" | a,b,c",
                            "a | b,c", "b | a,c", "c | a,b",
                            "a&b | c", "a&c | b", "b&c | a")))

        # filter by tautology ( => a)
        res <- dig(d,
                   f = f,
                   condition = everything(),
                   focus = everything(),
                   filter_empty_foci = FALSE,
                   excluded = list(c("a")),
                   min_support = 0.0001)
        res <- unlist(res)
        expect_equal(sort(res),
                     sort(c(" | b,c",
                            "b | c", "c | b",
                            "b&c | ")))


        # filter by tautology (a => b)
        res <- dig(d,
                   f = f,
                   condition = everything(),
                   focus = everything(),
                   filter_empty_foci = FALSE,
                   excluded = list(c("a", "b")),
                   min_support = 0.0001)
        res <- unlist(res)
        expect_equal(info = as.character(row),
                     sort(res),
                     sort(c(" | a,b,c",
                            "a | c", "b | a,c", "c | a,b",
                            "a&c | ", "b&c | a")))

        # filter by tautology (a => b) and empty foci
        res <- dig(d,
                   f = f,
                   condition = everything(),
                   focus = everything(),
                   filter_empty_foci = TRUE,
                   excluded = list(c("a", "b")),
                   min_support = 0.0001)
        res <- unlist(res)
        expect_equal(sort(res),
                     sort(c(" | a,b,c",
                            "a | c", "b | a,c", "c | a,b",
                            "b&c | a")))
    }
})


test_that("complex exclude tautology test", {
    f <- function(condition, pp) {
        paste(paste(sort(names(condition)), collapse = "&"),
              "|",
              paste(sort(names(pp)), collapse = ","))
    }

    excl <- list(c("a", "b", "c"),
                 c("c", "d"))

    orig_data <- data.frame(a = rep(T, 10),
                            b = rep(T, 10),
                            c = rep(T, 10),
                            d = rep(T, 10),
                            e = rep(T, 10))

    permutations <- permute(seq_len(ncol(orig_data)))

    # loop through all permutations of columns
    for (row in seq_len(nrow(permutations))) {
        d <- orig_data[, permutations[row, ], drop = FALSE]

        res <- dig(d,
                   f = f,
                   condition = everything(),
                   focus = everything(),
                   filter_empty_foci = TRUE,
                   excluded = excl,
                   min_support = 0.0001)
        res <- sort(unlist(res))
        expect_equal(res,
                     sort(c(" | a,b,c,d,e",
                            "a | b,c,d,e", "b | a,c,d,e", "c | a,b,e", "d | a,b,c,e", "e | a,b,c,d",
                            "a&b | e", "a&c | b,e", "a&d | b,c,e", "a&e | b,c,d",
                            "b&c | a,e", "b&d | a,c,e", "b&e | a,c,d",
                            "c&e | a,b",
                            "d&e | a,b,c",
                            "a&c&e | b", "a&d&e | b,c",
                            "b&c&e | a", "b&d&e | a,c")))

        res <- dig(d,
                   f = f,
                   condition = c(a, b, c),
                   focus = everything(),
                   filter_empty_foci = TRUE,
                   excluded = excl,
                   min_support = 0.0001)
        res <- sort(unlist(res))
        expect_equal(res,
                     sort(c(" | a,b,c,d,e",
                            "a | b,c,d,e", "b | a,c,d,e", "c | a,b,e",
                            "a&b | e", "a&c | b,e",
                            "b&c | a,e")))

        res <- dig(d,
                   f = f,
                   condition = everything(),
                   focus = c(d, e),
                   filter_empty_foci = TRUE,
                   excluded = excl,
                   min_support = 0.0001)
        res <- sort(unlist(res))
        expect_equal(res,
                     sort(c(" | d,e",
                            "a | d,e", "b | d,e", "c | e", "d | e", "e | d",
                            "a&b | e", "a&c | e", "a&d | e", "a&e | d",
                            "b&c | e", "b&d | e", "b&e | d")))

        res <- dig(d,
                   f = f,
                   condition = c(a, b, c),
                   focus = c(d, e),
                   filter_empty_foci = TRUE,
                   excluded = excl,
                   min_support = 0.0001)
        res <- sort(unlist(res))
        expect_equal(res,
                     sort(c(" | d,e",
                            "a | d,e", "b | d,e", "c | e",
                            "a&b | e", "a&c | e",
                            "b&c | e")),
                     info = as.character(row))

    }
})


test_that("complex exclude tautology test based on condition/focus variants", {
    f <- function(condition, pp) {
        res <- list()
        for (focus in names(pp)) {
            res <- c(res,
                     paste(paste0("c_", sort(names(condition)), collapse = " "),
                           "|",
                           paste0("f_", focus)))
        }

        res
    }

    excl <- list(c("a", "b"))

    orig_expected <- c("c_ | f_a", "c_ | f_b", "c_ | f_c", "c_ | f_d", "c_ | f_e",
                       "c_a | f_c", "c_a | f_d", "c_a | f_e",
                       "c_b | f_a", "c_b | f_c", "c_b | f_d", "c_b | f_e",
                       "c_c | f_a", "c_c | f_b", "c_c | f_d", "c_c | f_e",
                       "c_d | f_a", "c_d | f_b", "c_d | f_c", "c_d | f_e",
                       "c_a c_c | f_d", "c_a c_c | f_e",
                       "c_a c_d | f_c", "c_a c_d | f_e",
                       "c_b c_c | f_a", "c_b c_c | f_d", "c_b c_c | f_e",
                       "c_b c_d | f_a", "c_b c_d | f_c", "c_b c_d | f_e",
                       "c_c c_d | f_a", "c_c c_d | f_b", "c_c c_d | f_e",
                       "c_a c_c c_d | f_e",
                       "c_b c_c c_d | f_a", "c_b c_c c_d | f_e")

    orig_data <- data.frame(a = rep(T, 10),
                            b = rep(T, 10),
                            c = rep(T, 10),
                            d = rep(T, 10),
                            e = rep(T, 10))

    permutations <- permute(seq_len(ncol(orig_data)))
    selected_permutations <- seq(from = 1,
                                 to = nrow(permutations),
                                 length.out = min(10, nrow(permutations)))
    selected_permutations <- unique(round(selected_permutations))

    # Uncomment this for all permutations:
    # selected_permutations <- seq_len(nrow(permutations))

    # loop through all permutations of columns
    for (row in selected_permutations) {
        d <- orig_data[, permutations[row, ], drop = FALSE]

        for (a_type in 1:3) {
            for (b_type in 1:3) {
                for (c_type in 1:3) {
                    for (d_type in 1:3) {
                        cond <- NULL
                        focus <- "e"
                        if (a_type == 1 || a_type == 2) cond <- c(cond, "a")
                        if (a_type == 2 || a_type == 3) focus <- c(focus, "a")
                        if (b_type == 1 || b_type == 2) cond <- c(cond, "b")
                        if (b_type == 2 || b_type == 3) focus <- c(focus, "b")
                        if (c_type == 1 || c_type == 2) cond <- c(cond, "c")
                        if (c_type == 2 || c_type == 3) focus <- c(focus, "c")
                        if (d_type == 1 || d_type == 2) cond <- c(cond, "d")
                        if (d_type == 2 || d_type == 3) focus <- c(focus, "d")

                        res <- dig(d,
                                   f = f,
                                   condition = all_of(cond),
                                   focus = all_of(focus),
                                   filter_empty_foci = TRUE,
                                   excluded = excl,
                                   min_support = 0.0001)
                        res <- sort(unlist(res))

                        expected <- orig_expected
                        if (!"a" %in% cond) expected <- expected[!grepl("c_a", expected)]
                        if (!"b" %in% cond) expected <- expected[!grepl("c_b", expected)]
                        if (!"c" %in% cond) expected <- expected[!grepl("c_c", expected)]
                        if (!"d" %in% cond) expected <- expected[!grepl("c_d", expected)]
                        if (!"a" %in% focus) expected <- expected[!grepl("f_a", expected)]
                        if (!"b" %in% focus) expected <- expected[!grepl("f_b", expected)]
                        if (!"c" %in% focus) expected <- expected[!grepl("f_c", expected)]
                        if (!"d" %in% focus) expected <- expected[!grepl("f_d", expected)]
                        if (!"e" %in% focus) expected <- expected[!grepl("f_e", expected)]

                        expect_equal(res, sort(expected),
                                     info = paste0("row=", row, ", a_type=", a_type, ", b_type=", b_type, ", c_type=", c_type))
                    }
                }
            }
        }
    }
})
