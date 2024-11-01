test_that("partition basics", {
    expect_equal(partition(data.frame()),
                 tibble())

    expect_equal(partition(data.frame(a = c(T, T, F, F)),
                           .keep = FALSE),
                 tibble("a=T" = c(T, T, F, F),
                        "a=F" = c(F, F, T, T)))

    expect_equal(partition(data.frame(a = c(T, T, F, NA)),
                           .na = TRUE,
                           .keep = FALSE),
                 tibble("a=T" = c(T, T, F, F),
                        "a=F" = c(F, F, T, F),
                        "a=NA" = c(F, F, F, T)))

    expect_equal(partition(data.frame(a = c(T, T, F, NA)),
                           .na = FALSE,
                           .keep = FALSE),
                 tibble("a=T" = c(T, T, F, F),
                        "a=F" = c(F, F, T, F)))

    expect_equal(partition(data.frame(a = c(T, T, F, F)),
                           .keep = TRUE),
                 tibble("a" = c(T, T, F, F),
                        "a=T" = c(T, T, F, F),
                        "a=F" = c(F, F, T, T)))

    expect_equal(partition(data.frame(a = factor(c("a", "b", "b", "c"))),
                           .keep = FALSE),
                 tibble("a=a" = c(T, F, F, F),
                        "a=b" = c(F, T, T, F),
                        "a=c" = c(F, F, F, T)))

    expect_equal(partition(data.frame(a = factor(c("a", "b", "b", "c"))),
                           .keep = TRUE),
                 tibble("a" = factor(c("a", "b", "b", "c")),
                        "a=a" = c(T, F, F, F),
                        "a=b" = c(F, T, T, F),
                        "a=c" = c(F, F, F, T)))

    expect_equal(partition(data.frame(a = c(T, T, F, F),
                                      b = c(F, F, F, F),
                                      c = c(T, T, T, T),
                                      d = factor(c("a", "b", "b", "c"))),
                           b:c,
                           .keep = FALSE),
                 tibble("b=T" = c(F, F, F, F),
                        "b=F" = c(T, T, T, T),
                        "c=T" = c(T, T, T, T),
                        "c=F" = c(F, F, F, F)))

    expect_equal(partition(data.frame(a = c(T, T, F, F),
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


test_that("partition crisp", {
    expect_equal(partition(data.frame(a = 0:10),
                           .breaks = 2,
                           .keep = FALSE,
                           .method = "crisp"),
                 tibble("a=(-Inf;5]" = c(T,T,T,T,T,T,F,F,F,F,F),
                        "a=(5;Inf)"  = c(F,F,F,F,F,F,T,T,T,T,T)))

    expect_equal(partition(data.frame(b = 1:10),
                           .breaks = 3,
                           .keep = FALSE,
                           .method = "crisp"),
                 tibble("b=(-Inf;4]" = c(T,T,T,T,F,F,F,F,F,F),
                        "b=(4;7]"    = c(F,F,F,F,T,T,T,F,F,F),
                        "b=(7;Inf)"  = c(F,F,F,F,F,F,F,T,T,T)))

    expect_equal(partition(data.frame(b = 1:10),
                           .breaks = c(-Inf, 4, 7, Inf),
                           .keep = FALSE,
                           .method = "crisp",
                           .right = TRUE),
                 tibble("b=(-Inf;4]" = c(T,T,T,T,F,F,F,F,F,F),
                        "b=(4;7]"    = c(F,F,F,F,T,T,T,F,F,F),
                        "b=(7;Inf)"  = c(F,F,F,F,F,F,F,T,T,T)))

    expect_equal(partition(data.frame(b = 1:10),
                           .breaks = c(4, 7),
                           .keep = FALSE,
                           .na = TRUE,
                           .method = "crisp",
                           .right = FALSE),
                 tibble("b=[4;7)" = c(F,F,F,T,T,T,F,F,F,F)))

    expect_equal(partition(data.frame(b = c(1:10, NA, NA)),
                           .breaks = c(4, 7),
                           .keep = FALSE,
                           .na = TRUE,
                           .method = "crisp",
                           .right = FALSE),
                 tibble("b=[4;7)" = c(F,F,F,T,T,T,F,F,F,F,F,F),
                        "b=NA"    = c(F,F,F,F,F,F,F,F,F,F,T,T)))

    expect_equal(partition(data.frame(b = c(1:10, NA, NA)),
                           .breaks = c(4, 7),
                           .keep = FALSE,
                           .na = FALSE,
                           .method = "crisp",
                           .right = FALSE),
                 tibble("b=[4;7)" = c(F,F,F,T,T,T,F,F,F,F,F,F)))

    expect_equal(partition(data.frame(b = 1:10),
                           .breaks = c(-Inf, 4, 7, Inf),
                           .keep = FALSE,
                           .method = "crisp",
                           .labels = c("A", "BBB", "cc"),
                           .right = TRUE),
                 tibble("b=A"   = c(T,T,T,T,F,F,F,F,F,F),
                        "b=BBB" = c(F,F,F,F,T,T,T,F,F,F),
                        "b=cc"  = c(F,F,F,F,F,F,F,T,T,T)))

})
