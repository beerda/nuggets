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
