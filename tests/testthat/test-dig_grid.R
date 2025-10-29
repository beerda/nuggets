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


test_that("dig_grid empty condition", {
    d <- data.frame(a = TRUE,
                    b = c(TRUE, FALSE),
                    x = letters[1:10],
                    y = letters[11:20],
                    z = LETTERS[1:10])

    f <- function(pd) {
        paste(paste(pd[[1]], collapse = "|"),
              paste(pd[[2]], collapse = "|"))
    }

    res <- dig_grid(x = d,
                    f = f,
                    type = "crisp",
                    condition = NULL,
                    xvars = where(is.character),
                    yvars = where(is.character))

    expect_true(is_nugget(res))
    expect_true(is_tibble(res))
    res <- res[order(res$condition_length, res$condition), ]

    expect_equal(nrow(res), 3)
    expect_equal(colnames(res),
                 c("condition", "support", "xvar", "yvar", "value", "condition_length"))
    expect_equal(res$condition, rep("{}", 3))
    expect_equal(res$xvar, c("x", "x", "y"))
    expect_equal(res$yvar, c("y", "z", "z"))
    expect_equal(res$support, rep(1.0, 3))
    expect_equal(res$condition_length, rep(0, 3))

    v1 <- list(x = "a|b|c|d|e|f|g|h|i|j",
               y = "k|l|m|n|o|p|q|r|s|t",
               z = "A|B|C|D|E|F|G|H|I|J")
    v2 <- list(x = "a|c|e|g|i",
               y = "k|m|o|q|s",
               z = "A|C|E|G|I")
    for (i in seq_len(nrow(res))) {
        cond <- res$condition[i]
        x <- res$xvar[i]
        y <- res$yvar[i]
        value <- res$value[i]

        expect_equal(value, paste(v1[[x]], v1[[y]]))
    }
})

test_that("dig_grid crisp", {
    d <- data.frame(a = TRUE,
                    b = c(TRUE, FALSE),
                    x = letters[1:10],
                    y = letters[11:20],
                    z = LETTERS[1:10])

    f <- function(pd) {
        paste(paste(pd[[1]], collapse = "|"),
              paste(pd[[2]], collapse = "|"))
    }

    res <- dig_grid(x = d,
                    f = f,
                    type = "crisp",
                    condition = where(is.logical),
                    xvars = where(is.character),
                    yvars = where(is.character))

    expect_true(is_nugget(res))
    expect_true(is_tibble(res))
    res <- res[order(res$condition_length, res$condition), ]

    expect_equal(nrow(res), 12)
    expect_equal(colnames(res),
                 c("condition", "support", "xvar", "yvar", "value", "condition_length"))
    expect_equal(res$condition,
                 c(rep("{}", 3), rep("{a}", 3), rep("{b}", 3), rep("{a,b}", 3)))
    expect_equal(res$xvar,
                 rep(c("x", "x", "y"), 4))
    expect_equal(res$yvar,
                 rep(c("y", "z", "z"), 4))
    expect_equal(res$support,
                 c(rep(100, 6), rep(50, 6)) / 100)

    v1 <- list(x = "a|b|c|d|e|f|g|h|i|j",
               y = "k|l|m|n|o|p|q|r|s|t",
               z = "A|B|C|D|E|F|G|H|I|J")
    v2 <- list(x = "a|c|e|g|i",
               y = "k|m|o|q|s",
               z = "A|C|E|G|I")
    for (i in seq_len(nrow(res))) {
        cond <- res$condition[i]
        x <- res$xvar[i]
        y <- res$yvar[i]
        value <- res$value[i]

        if (cond == "{}" || cond == "{a}") {
            expect_equal(value, paste(v1[[x]], v1[[y]]))
        } else if (cond == "{b}" || cond == "{a,b}") {
            expect_equal(value, paste(v2[[x]], v2[[y]]))
        } else {
            expect_true(FALSE);
        }
    }
})


test_that("dig_grid crisp nd", {
    d <- data.frame(a = TRUE,
                    b = c(TRUE, FALSE),
                    x = letters[1:10],
                    y = letters[11:20],
                    z = LETTERS[1:10])

    f <- function(pd, nd) {
        list(p = paste(paste(pd[[1]], collapse = "|"),
                       paste(pd[[2]], collapse = "|")),
             n = paste(paste(nd[[1]], collapse = "|"),
                       paste(nd[[2]], collapse = "|")))
    }

    res <- dig_grid(x = d,
                    f = f,
                    type = "crisp",
                    condition = where(is.logical),
                    xvars = where(is.character),
                    yvars = where(is.character))

    expect_true(is_nugget(res))
    expect_true(is_tibble(res))
    res <- res[order(res$condition_length, res$condition), ]

    expect_equal(nrow(res), 12)
    expect_equal(colnames(res),
                 c("condition", "support", "xvar", "yvar", "p", "n", "condition_length"))
    expect_equal(res$condition,
                 c(rep("{}", 3), rep("{a}", 3), rep("{b}", 3), rep("{a,b}", 3)))
    expect_equal(res$xvar,
                 rep(c("x", "x", "y"), 4))
    expect_equal(res$yvar,
                 rep(c("y", "z", "z"), 4))
    expect_equal(res$support,
                 c(rep(100, 6), rep(50, 6)) / 100)

    v1 <- list(x = "a|b|c|d|e|f|g|h|i|j",
               y = "k|l|m|n|o|p|q|r|s|t",
               z = "A|B|C|D|E|F|G|H|I|J")
    v2 <- list(x = "a|c|e|g|i",
               y = "k|m|o|q|s",
               z = "A|C|E|G|I")
    v3 <- list(x = "b|d|f|h|j",
               y = "l|n|p|r|t",
               z = "B|D|F|H|J")
    for (i in seq_len(nrow(res))) {
        cond <- res$condition[i]
        x <- res$xvar[i]
        y <- res$yvar[i]
        p <- res$p[i]
        n <- res$n[i]

        if (cond == "{}" || cond == "{a}") {
            expect_equal(p, paste(v1[[x]], v1[[y]]))
            expect_equal(n, " ")
        } else if (cond == "{b}" || cond == "{a,b}") {
            expect_equal(p, paste(v2[[x]], v2[[y]]))
            expect_equal(n, paste(v3[[x]], v3[[y]]))
        } else {
            expect_true(FALSE);
        }
    }
})


test_that("dig_grid crisp with NA", {
    d <- data.frame(a = TRUE,
                    b = c(TRUE, FALSE),
                    x = letters[1:10],
                    y = letters[11:20],
                    z = LETTERS[1:10])
    d[1, "x"] <- NA
    d[2, "y"] <- NA

    f <- function(pd) {
        paste(paste(pd[[1]], collapse = "|"),
              paste(pd[[2]], collapse = "|"))
    }

    res <- dig_grid(x = d,
                    f = f,
                    type = "crisp",
                    na_rm = TRUE,
                    condition = where(is.logical),
                    xvars = where(is.character),
                    yvars = where(is.character))

    expect_true(is_nugget(res))
    expect_true(is_tibble(res))
    res <- res[order(res$condition_length, res$condition), ]

    expect_equal(nrow(res), 12)
    expect_equal(colnames(res),
                 c("condition", "support", "xvar", "yvar", "value", "condition_length"))
    expect_equal(res$condition,
                 c(rep("{}", 3), rep("{a}", 3), rep("{b}", 3), rep("{a,b}", 3)))
    expect_equal(res$xvar,
                 rep(c("x", "x", "y"), 4))
    expect_equal(res$yvar,
                 rep(c("y", "z", "z"), 4))
    expect_equal(res$support,
                 c(rep(100, 6), rep(50, 6)) / 100)
    expect_equal(res$value,
                 c("c|d|e|f|g|h|i|j m|n|o|p|q|r|s|t",
                   "b|c|d|e|f|g|h|i|j B|C|D|E|F|G|H|I|J",
                   "k|m|n|o|p|q|r|s|t A|C|D|E|F|G|H|I|J",
                   "c|d|e|f|g|h|i|j m|n|o|p|q|r|s|t",
                   "b|c|d|e|f|g|h|i|j B|C|D|E|F|G|H|I|J",
                   "k|m|n|o|p|q|r|s|t A|C|D|E|F|G|H|I|J",
                   "c|e|g|i m|o|q|s",
                   "c|e|g|i C|E|G|I",
                   "k|m|o|q|s A|C|E|G|I",
                   "c|e|g|i m|o|q|s",
                   "c|e|g|i C|E|G|I",
                   "k|m|o|q|s A|C|E|G|I"))
})


test_that("dig_grid with NULL results", {
    d <- data.frame(a = c(TRUE, FALSE),
                    b = c(TRUE, TRUE, FALSE),
                    x = letters[1:12],
                    y = letters[11:22],
                    z = LETTERS[1:12])

    f <- function(pd) {
        if (all(names(pd) == c("x", "y"))) {
            return(NULL)
        }
        list(value = 1)
    }

    res <- dig_grid(x = d,
                    f = f,
                    type = "crisp",
                    na_rm = TRUE,
                    condition = where(is.logical),
                    xvars = where(is.character),
                    yvars = where(is.character))

    expect_true(is_nugget(res))
    expect_true(is_tibble(res))
    res <- res[order(res$condition_length, res$condition), ]

    expect_equal(nrow(res), 8)
    expect_equal(colnames(res),
                 c("condition", "support", "xvar", "yvar", "value", "condition_length"))
    expect_equal(res$condition,
                 c(rep("{}", 2), rep("{a}", 2), rep("{b}", 2), rep("{a,b}", 2)))
    expect_equal(res$xvar,
                 rep(c("x", "y"), 4))
    expect_equal(res$yvar,
                 rep(c("z", "z"), 4))
    expect_equal(res$support,
                 c(1, 1, 1/2, 1/2, 2/3, 2/3, 1/3, 1/3), tolerance = 1e-3)
    expect_equal(res$value,
                 rep(1, 8))

    f <- function(pd, nd) {
        if (all(names(pd) == c("x", "y"))) {
            return(NULL)
        }
        list(value = 1)
    }

    res <- dig_grid(x = d,
                    f = f,
                    type = "crisp",
                    na_rm = TRUE,
                    condition = where(is.logical),
                    xvars = where(is.character),
                    yvars = where(is.character))
    res <- res[order(res$condition_length, res$condition), ]

    expect_true(is_nugget(res))
    expect_true(is_tibble(res))
    expect_equal(nrow(res), 8)
    expect_equal(colnames(res),
                 c("condition", "support", "xvar", "yvar", "value", "condition_length"))
    expect_equal(res$condition,
                 c(rep("{}", 2), rep("{a}", 2), rep("{b}", 2), rep("{a,b}", 2)))
    expect_equal(res$xvar,
                 rep(c("x", "y"), 4))
    expect_equal(res$yvar,
                 rep(c("z", "z"), 4))
    expect_equal(res$support,
                 c(1, 1, 1/2, 1/2, 2/3, 2/3, 1/3, 1/3), tolerance = 1e-3)
    expect_equal(res$value,
                 rep(1, 8))

    f <- function(d, weights) {
        if (all(names(d) == c("x", "y"))) {
            return(NULL)
        }
        list(value = 1)
    }

    res <- dig_grid(x = d,
                    f = f,
                    type = "fuzzy",
                    na_rm = TRUE,
                    condition = where(is.logical),
                    xvars = where(is.character),
                    yvars = where(is.character))

    expect_true(is_nugget(res))
    expect_true(is_tibble(res))
    res <- res[order(res$condition_length, res$condition), ]

    expect_equal(nrow(res), 8)
    expect_equal(colnames(res),
                 c("condition", "support", "xvar", "yvar", "value", "condition_length"))
    expect_equal(res$condition,
                 c(rep("{}", 2), rep("{a}", 2), rep("{b}", 2), rep("{a,b}", 2)))
    expect_equal(res$xvar,
                 rep(c("x", "y"), 4))
    expect_equal(res$yvar,
                 rep(c("z", "z"), 4))
    expect_equal(res$support,
                 c(1, 1, 1/2, 1/2, 2/3, 2/3, 1/3, 1/3), tolerance = 1e-3)
    expect_equal(res$value,
                 rep(1, 8))
})

test_that("dig_grid fuzzy", {
    d <- data.frame(a = 1.0,
                    b = 1:10 / 10,
                    x = letters[1:10],
                    y = letters[11:20],
                    z = LETTERS[1:10])

    f <- function(d, weights) {
        paste(paste(d[[1]], collapse = "|"),
              paste(d[[2]], collapse = "|"),
              sum(round(weights, 2)))
    }

    res <- dig_grid(x = d,
                    f = f,
                    type = "fuzzy",
                    condition = where(is.numeric),
                    xvars = where(is.character),
                    yvars = where(is.character))

    expect_true(is_nugget(res))
    expect_true(is_tibble(res))
    res <- res[order(res$condition_length, res$condition), ]

    expect_equal(nrow(res), 12)
    expect_equal(colnames(res),
                 c("condition", "support", "xvar", "yvar", "value", "condition_length"))
    expect_equal(res$condition,
                 c(rep("{}", 3), rep("{a}", 3), rep("{b}", 3), rep("{a,b}", 3)))
    expect_equal(res$xvar,
                 rep(c("x", "x", "y"), 4))
    expect_equal(res$yvar,
                 rep(c("y", "z", "z"), 4))
    expect_equal(round(res$support, 2),
                 round(c(rep(100, 6), rep(55, 6)) / 100, 2))

    v1 <- list(x = "a|b|c|d|e|f|g|h|i|j",
               y = "k|l|m|n|o|p|q|r|s|t",
               z = "A|B|C|D|E|F|G|H|I|J")
    for (i in seq_len(nrow(res))) {
        cond <- res$condition[i]
        x <- res$xvar[i]
        y <- res$yvar[i]
        value <- res$value[i]

        if (cond == "{}" || cond == "{a}") {
            expect_equal(value, paste(v1[[x]], v1[[y]], "10"))
        } else if (cond == "{b}" || cond == "{a,b}") {
            expect_equal(value, paste(v1[[x]], v1[[y]], "5.5"))
        } else {
            expect_true(FALSE);
        }
    }
})


test_that("dig_grid number of columns in data frames", {
    d <- data.frame(a = TRUE,
                    b = c(TRUE, FALSE),
                    x = letters[1:10],
                    y = letters[11:20],
                    z = LETTERS[1:10])

    # crisp / xvars & yvars / pd
    res <- dig_grid(x = d,
                    f = function(pd) { ncol(pd) },
                    type = "crisp",
                    condition = NULL,
                    xvars = where(is.character),
                    yvars = where(is.character))

    expect_true(is_nugget(res))
    expect_true(is_tibble(res))
    expect_equal(nrow(res), 3)
    expect_equal(res$value, rep(2, 3))

    # crisp / xvars & yvars / pd & nd
    res <- dig_grid(x = d,
                    f = function(pd, nd) { paste(ncol(pd), ncol(nd)) },
                    type = "crisp",
                    condition = NULL,
                    xvars = where(is.character),
                    yvars = where(is.character))

    expect_true(is_nugget(res))
    expect_true(is_tibble(res))
    expect_equal(nrow(res), 3)
    expect_equal(res$value, rep("2 2", 3))

    # fuzzy / xvars & yvars / d
    res <- dig_grid(x = d,
                    f = function(d, weights) { ncol(d) },
                    type = "fuzzy",
                    condition = NULL,
                    xvars = where(is.character),
                    yvars = where(is.character))

    expect_true(is_nugget(res))
    expect_true(is_tibble(res))
    expect_equal(nrow(res), 3)
    expect_equal(res$value, rep(2, 3))

    # crisp / xvars only / pd
    res <- dig_grid(x = d,
                    f = function(pd) { ncol(pd) },
                    type = "crisp",
                    condition = NULL,
                    xvars = where(is.character),
                    yvars = NULL)

    expect_true(is_nugget(res))
    expect_true(is_tibble(res))
    expect_equal(nrow(res), 3)
    expect_equal(res$value, rep(1, 3))

    # crisp / xvars only / pd & nd
    res <- dig_grid(x = d,
                    f = function(pd, nd) { paste(ncol(pd), ncol(nd)) },
                    type = "crisp",
                    condition = NULL,
                    xvars = where(is.character),
                    yvars = NULL)

    expect_true(is_nugget(res))
    expect_true(is_tibble(res))
    expect_equal(nrow(res), 3)
    expect_equal(res$value, rep("1 1", 3))

    # fuzzy / xvars only / d
    res <- dig_grid(x = d,
                    f = function(d, weights) { ncol(d) },
                    type = "fuzzy",
                    condition = NULL,
                    xvars = where(is.character),
                    yvars = NULL)

    expect_true(is_nugget(res))
    expect_true(is_tibble(res))
    expect_equal(nrow(res), 3)
    expect_equal(res$value, rep(1, 3))
})

test_that("disjoint is applied on xvars/yvars combinations", {
    d <- data.frame(a = TRUE,
                    b = c(TRUE, FALSE),
                    x = letters[1:10],
                    y = letters[11:20],
                    z = LETTERS[1:10])

    f <- function(pd) {
        return(list(res=1))
    }

    res <- dig_grid(x = d,
                    f = f,
                    type = "crisp",
                    disjoint = c("a", "b", "xz", "y", "xz"),
                    condition = where(is.logical),
                    xvars = where(is.character),
                    yvars = where(is.character))
    res <- res[order(res$condition_length, res$condition), ]

    expect_true(is_nugget(res))
    expect_true(is_tibble(res))
    expect_equal(nrow(res), 8)
    expect_equal(colnames(res),
                 c("condition", "support", "xvar", "yvar", "res", "condition_length"))
    expect_equal(res$condition,
                 c(rep("{}", 2), rep("{a}", 2), rep("{b}", 2), rep("{a,b}", 2)))
    expect_equal(res$xvar,
                 rep(c("x", "y"), 4))
    expect_equal(res$yvar,
                 rep(c("y", "z"), 4))
    expect_equal(res$support,
                 c(rep(1, 4), rep(0.5, 4)))
    expect_equal(res$res,
                 rep(1, 8))
    expect_equal(res$condition_length,
                 c(0, 0, 1, 1, 1, 1, 2, 2))
})

test_that("dig_grid call args", {
    d <- data.frame(a = TRUE,
                    b = c(TRUE, FALSE),
                    x = letters[1:10],
                    y = letters[11:20],
                    z = LETTERS[1:10])

    f <- function(pd) { return(list(res=1)) }

    res <- dig_grid(x = d,
                    f = f,
                    condition = where(is.logical),
                    xvars = x:y,
                    yvars = y:z,
                    disjoint = c("a", "b", "xz", "y", "xz"),
                    excluded = list("x"),
                    allow = "all",
                    na_rm = TRUE,
                    type = "crisp",
                    min_length = 1L,
                    max_length = 2L,
                    min_support = 0.1,
                    max_support = 0.9,
                    max_results = 100L,
                    verbose = TRUE,
                    threads = 1L)

    expect_true(is_nugget(res))
    expect_true(is_tibble(res))
    expect_equal(attr(res, "call_function"), "dig_grid")
    expect_true(is.list(attr(res, "call_data")))
    expect_equal(attr(res, "call_data")$nrow, nrow(d))
    expect_equal(attr(res, "call_data")$ncol, ncol(d))
    expect_equal(attr(res, "call_data")$colnames, as.character(colnames(d)))
    expect_true(is.list(attr(res, "call_args")))
    expect_equal(attr(res, "call_args")$x, "d")
    expect_equal(attr(res, "call_args")$condition, c("a", "b"))
    expect_equal(attr(res, "call_args")$xvars, c("x", "y"))
    expect_equal(attr(res, "call_args")$yvars, c("y", "z"))
    expect_equal(attr(res, "call_args")$disjoint, c("a", "b", "xz", "y", "xz"))
    expect_equal(attr(res, "call_args")$excluded, list("x"))
    expect_equal(attr(res, "call_args")$allow, "all")
    expect_true(attr(res, "call_args")$na_rm)
    expect_equal(attr(res, "call_args")$type, "crisp")
    expect_equal(attr(res, "call_args")$min_length, 1L)
    expect_equal(attr(res, "call_args")$max_length, 2L)
    expect_equal(attr(res, "call_args")$min_support, 0.1)
    expect_equal(attr(res, "call_args")$max_support, 0.9)
    expect_equal(attr(res, "call_args")$max_results, 100L)
    expect_equal(attr(res, "call_args")$verbose, TRUE)
    expect_equal(attr(res, "call_args")$threads, 1L)
})

test_that("errors", {
    d <- data.frame(n = 1:5 / 5, l = TRUE, i = 1:5, s = letters[1:5])
    l <- as.list(d)
    fb <- function(pd) { 1 }
    ff <- function(d, weights) { 1 }

    expect_true(is.data.frame(dig_grid(d, f = fb, type = "crisp", condition = c(l))))
    expect_error(dig_grid(d, f = ff, type = "crisp", condition = c(l)),
                 "Function `f` must have the following arguments: `pd`.")
    expect_error(dig_grid(d, f = fb, type = "crisp", condition = c(l, n)),
                 "All columns selected by `condition` must be logical.")
    expect_error(dig_grid(d, f = fb, type = "crisp", condition = c(l, s)),
                 "All columns selected by `condition` must be logical.")
    expect_error(dig_grid(d, f = fb, type = "crisp", condition = c(l, i)),
                 "All columns selected by `condition` must be logical.")

    expect_true(is.data.frame(dig_grid(d, f = ff, type = "fuzzy", condition = c(l, n))))
    expect_error(dig_grid(d, f = fb, type = "fuzzy", condition = c(l)),
                 "`f` must have the following arguments: `d`, `weights`.")
    expect_error(dig_grid(d, f = ff, type = "fuzzy", condition = c(l, i)),
                 "All columns selected by `condition` must be logical or numeric from the interval")
    expect_error(dig_grid(d, f = ff, type = "fuzzy", condition = c(l, s)),
                 "All columns selected by `condition` must be logical or numeric from the interval")

    expect_error(dig_grid(l, f = fb, type = "crisp", condition = c(l)),
                 "`x` must be a matrix or a data frame")
    expect_error(dig_grid(l, f = 1, type = "crisp", condition = c(l)),
                 "`f` must be a function")
    expect_error(dig_grid(d, f = fb, type = "crisp", condition = xxx),
                 "Column `xxx` doesn't exist")
    expect_error(dig_grid(d, f = fb, type = "crisp", condition = l, na_rm = 3),
                 "`na_rm` must be a flag")
    expect_error(dig_grid(d, f = fb, type = "foo", condition = l),
                 "`type` must be equal to one of: \"crisp\", \"fuzzy\".")
    expect_error(dig_grid(d, f = fb, type = "crisp", condition = l, min_length = "x"),
                 "`min_length` must be an integerish scalar")
    expect_error(dig_grid(d, f = fb, type = "crisp", condition = l, max_length = "x"),
                 "`max_length` must be an integerish scalar")
    expect_error(dig_grid(d, f = fb, type = "crisp", condition = l, min_support = "x"),
                 "`min_support` must be a double scalar")
    expect_error(dig_grid(d, f = fb, type = "crisp", condition = l, threads = "x"),
                 "`threads` must be an integerish scalar")

    expect_error(dig_grid(d, f = fb, disjoint = list("x")),
                 "`disjoint` must be a plain vector")
    expect_error(dig_grid(d, f = fb, disjoint = "x"),
                 "The length of `disjoint` must be 0 or must be equal to the number of columns in `x`.")
})
