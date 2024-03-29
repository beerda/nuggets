test_that("dichotomize", {
    expect_equal(dichotomize(data.frame()),
                 tibble())

    expect_equal(dichotomize(data.frame(a = c(T, T, F, F)),
                             .keep = FALSE),
                 tibble("a=T" = c(T, T, F, F),
                        "a=F" = c(F, F, T, T)))

    expect_equal(dichotomize(data.frame(a = c(T, T, F, F)),
                             .keep = TRUE),
                 tibble("a" = c(T, T, F, F),
                        "a=T" = c(T, T, F, F),
                        "a=F" = c(F, F, T, T)))

    expect_equal(dichotomize(data.frame(a = factor(c("a", "b", "b", "c"))),
                             .keep = FALSE),
                 tibble("a=a" = c(T, F, F, F),
                        "a=b" = c(F, T, T, F),
                        "a=c" = c(F, F, F, T)))

    expect_equal(dichotomize(data.frame(a = factor(c("a", "b", "b", "c"))),
                             .keep = TRUE),
                 tibble("a" = factor(c("a", "b", "b", "c")),
                        "a=a" = c(T, F, F, F),
                        "a=b" = c(F, T, T, F),
                        "a=c" = c(F, F, F, T)))

    expect_equal(dichotomize(data.frame(a = c(T, T, F, F),
                                        b = c(F, F, F, F),
                                        c = c(T, T, T, T),
                                        d = factor(c("a", "b", "b", "c"))),
                             b:c,
                             .keep = FALSE),
                 tibble("b=T" = c(F, F, F, F),
                        "b=F" = c(T, T, T, T),
                        "c=T" = c(T, T, T, T),
                        "c=F" = c(F, F, F, F)))

    expect_equal(dichotomize(data.frame(a = c(T, T, F, F),
                                        b = c(F, F, F, F),
                                        c = c(T, T, T, T),
                                        d = factor(c("a", "b", "b", "c"))),
                             b, c,
                             .keep = FALSE),
                 tibble("b=T" = c(F, F, F, F),
                        "b=F" = c(T, T, T, T),
                        "c=T" = c(T, T, T, T),
                        "c=F" = c(F, F, F, F)))
})


test_that("dichotomize selected", {
    d <- tibble(a = 1:6,
                b = c(T, T, T, F, F, F),
                c = c(T, F, T, F, T, F),
                d = letters[1:6])

    expect_equal(dichotomize(d, what = b, .keep = FALSE, .other = FALSE),
                 tibble("b=T" = c(T, T, T, F, F, F),
                        "b=F" = c(F, F, F, T, T, T)))

    expect_equal(dichotomize(d, what = b, .keep = FALSE, .other = TRUE),
                 tibble(a = 1:6,
                        c = c(T, F, T, F, T, F),
                        d = letters[1:6],
                        "b=T" = c(T, T, T, F, F, F),
                        "b=F" = c(F, F, F, T, T, T)))

    expect_equal(dichotomize(d, what = b, .keep = TRUE, .other = TRUE),
                 tibble(a = 1:6,
                        c = c(T, F, T, F, T, F),
                        d = letters[1:6],
                        b = c(T, T, T, F, F, F),
                        "b=T" = c(T, T, T, F, F, F),
                        "b=F" = c(F, F, F, T, T, T)))
})
