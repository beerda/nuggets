test_that("dig_grid bool", {
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
                    type = "bool",
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


test_that("dig_grid bool with NA", {
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
                    type = "bool",
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
    fb <- function(d) { 1 }
    ff <- function(d, weights) { 1 }

    expect_true(is.data.frame(dig_grid(d, f = fb, type = "bool", condition = c(l))))
    expect_error(dig_grid(d, f = ff, type = "bool", condition = c(l)),
                 "must have the following arguments")
    expect_error(dig_grid(d, f = fb, type = "bool", condition = c(l, n)),
                 "columns selected by .* must be logical.")
    expect_error(dig_grid(d, f = fb, type = "bool", condition = c(l, s)),
                 "columns selected by .* must be logical.")
    expect_error(dig_grid(d, f = fb, type = "bool", condition = c(l, i)),
                 "columns selected by .* must be logical.")

    expect_true(is.data.frame(dig_grid(d, f = ff, type = "fuzzy", condition = c(l, n))))
    expect_error(dig_grid(d, f = fb, type = "fuzzy", condition = c(l)),
                 "must have the following arguments")
    expect_error(dig_grid(d, f = ff, type = "fuzzy", condition = c(l, i)),
                 "columns selected by .* must be logical or numeric from the interval")
    expect_error(dig_grid(d, f = ff, type = "fuzzy", condition = c(l, s)),
                 "columns selected by .* must be logical or numeric from the interval")
})
