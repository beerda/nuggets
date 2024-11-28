test_that("dig_grid empty condition", {
    d <- data.frame(a = TRUE,
                    b = c(TRUE, FALSE),
                    x = letters[1:10],
                    y = letters[11:20],
                    z = LETTERS[1:10])

    f <- function(d) {
        paste(paste(d[[1]], collapse = "|"),
              paste(d[[2]], collapse = "|"))
    }

    res <- dig_grid(x = d,
                    f = f,
                    type = "crisp",
                    condition = NULL,
                    xvars = where(is.character),
                    yvars = where(is.character))

    expect_true(is_tibble(res))
    expect_equal(nrow(res), 3)
    expect_equal(colnames(res),
                 c("condition", "support", "xvar", "yvar", "value"))
    expect_equal(res$condition, rep("{}", 3))
    expect_equal(res$xvar, c("x", "x", "y"))
    expect_equal(res$yvar, c("y", "z", "z"))
    expect_equal(res$support, rep(1.0, 3))

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

    f <- function(d) {
        paste(paste(d[[1]], collapse = "|"),
              paste(d[[2]], collapse = "|"))
    }

    res <- dig_grid(x = d,
                    f = f,
                    type = "crisp",
                    condition = where(is.logical),
                    xvars = where(is.character),
                    yvars = where(is.character))

    expect_true(is_tibble(res))
    expect_equal(nrow(res), 12)
    expect_equal(colnames(res),
                 c("condition", "support", "xvar", "yvar", "value"))
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


test_that("dig_grid crisp with NA", {
    d <- data.frame(a = TRUE,
                    b = c(TRUE, FALSE),
                    x = letters[1:10],
                    y = letters[11:20],
                    z = LETTERS[1:10])
    d[1, "x"] <- NA
    d[2, "y"] <- NA

    f <- function(d) {
        paste(paste(d[[1]], collapse = "|"),
              paste(d[[2]], collapse = "|"))
    }

    res <- dig_grid(x = d,
                    f = f,
                    type = "crisp",
                    na_rm = TRUE,
                    condition = where(is.logical),
                    xvars = where(is.character),
                    yvars = where(is.character))

    expect_true(is_tibble(res))
    expect_equal(nrow(res), 12)
    expect_equal(colnames(res),
                 c("condition", "support", "xvar", "yvar", "value"))
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

    expect_true(is_tibble(res))
    expect_equal(nrow(res), 12)
    expect_equal(colnames(res),
                 c("condition", "support", "xvar", "yvar", "value"))
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


test_that("errors", {
    d <- data.frame(n = 1:5 / 5, l = TRUE, i = 1:5, s = letters[1:5])
    l <- as.list(d)
    fb <- function(d) { 1 }
    ff <- function(d, weights) { 1 }

    expect_true(is.data.frame(dig_grid(d, f = fb, type = "crisp", condition = c(l))))
    expect_error(dig_grid(d, f = ff, type = "crisp", condition = c(l)),
                 "`f` must have the following arguments: `d`.")
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
})
