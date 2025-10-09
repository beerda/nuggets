test_that("partition basics", {
    expect_equal(partition(data.frame()),
                 tibble())

    expect_equal(partition(data.frame(a = c(T, T, F, F)), where(is.raw)),
                 tibble(a = c(T, T, F, F)))

    expect_equal(partition(data.frame(a = c(T, T, F, F)),
                           .keep = FALSE),
                 tibble("a=T" = c(T, T, F, F),
                        "a=F" = c(F, F, T, T)))

    expect_equal(partition(data.frame(`a=b,c{x}` = c(T, T, F, F), check.names = FALSE),
                           .keep = FALSE),
                 tibble("a_b_c_x_=T" = c(T, T, F, F),
                        "a_b_c_x_=F" = c(F, F, T, T)))

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

    expect_equal(partition(data.frame(a = factor(c("a=a", "{b}", "{b}", "c,d"))),
                           .keep = FALSE),
                 tibble("a=a_a" = c(T, F, F, F),
                        "a=c_d" = c(F, F, F, T),
                        "a=_b_" = c(F, T, T, F)))

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
                 tibble(a = c(T, T, F, F),
                        d = factor(c("a", "b", "b", "c")),
                        "b=T" = c(F, F, F, F),
                        "b=F" = c(T, T, T, T),
                        "c=T" = c(T, T, T, T),
                        "c=F" = c(F, F, F, F)))

    expect_equal(partition(data.frame(a = c(T, T, F, F),
                                      b = c(F, F, F, F),
                                      c = c(T, T, T, T),
                                      d = factor(c("a", "b", "b", "c"))),
                           b, c,
                           .keep = FALSE),
                 tibble(a = c(T, T, F, F),
                        d = factor(c("a", "b", "b", "c")),
                        "b=T" = c(F, F, F, F),
                        "b=F" = c(T, T, T, T),
                        "c=T" = c(T, T, T, T),
                        "c=F" = c(F, F, F, F)))

    expect_equal(partition(data.frame(a = c(T, T, F, F),
                                      b = c(F, F, F, F),
                                      c = c(T, T, T, T),
                                      d = factor(c("a", "b", "b", "c"))),
                           b, c,
                           .keep = TRUE),
                 tibble(a = c(T, T, F, F),
                        b = c(F, F, F, F),
                        c = c(T, T, T, T),
                        d = factor(c("a", "b", "b", "c")),
                        "b=T" = c(F, F, F, F),
                        "b=F" = c(T, T, T, T),
                        "c=T" = c(T, T, T, T),
                        "c=F" = c(F, F, F, F)))
})


test_that("partition dummy", {
    expect_equal(partition(data.frame(a = 1:3),
                           .keep = FALSE,
                           .method = "dummy"),
                 tibble("a=1" = c(T,F,F),
                        "a=2" = c(F,T,F),
                        "a=3" = c(F,F,T)))

    expect_equal(partition(data.frame(a = c(1.0, 1.2, 1.2, 1.0, NA)),
                           .keep = FALSE,
                           .na = TRUE,
                           .method = "dummy"),
                 tibble("a=1" = c(T,F,F,T,F),
                        "a=1.2" = c(F,T,T,F,F),
                        "a=NA"  = c(F,F,F,F,T)))

    expect_equal(partition(data.frame(a = c(1.0, 1.2, 1.2, 1.0, NA)),
                           .keep = FALSE,
                           .na = FALSE,
                           .method = "dummy"),
                 tibble("a=1" = c(T,F,F,T,F),
                        "a=1.2" = c(F,T,T,F,F)))
})


test_that("partition crisp", {
    expect_equal(partition(data.frame(a = 0:10),
                           .breaks = 2,
                           .keep = FALSE,
                           .method = "crisp"),
                 tibble("a=(-Inf;5]" = c(T,T,T,T,T,T,F,F,F,F,F),
                        "a=(5;Inf]"  = c(F,F,F,F,F,F,T,T,T,T,T)))

    expect_equal(partition(data.frame(b = 1:10),
                           .breaks = 3,
                           .keep = FALSE,
                           .method = "crisp"),
                 tibble("b=(-Inf;4]" = c(T,T,T,T,F,F,F,F,F,F),
                        "b=(4;7]"    = c(F,F,F,F,T,T,T,F,F,F),
                        "b=(7;Inf]"  = c(F,F,F,F,F,F,F,T,T,T)))

    expect_equal(partition(data.frame(b = 1:10),
                           .breaks = c(-Inf, 4, 7, Inf),
                           .keep = FALSE,
                           .method = "crisp",
                           .right = TRUE),
                 tibble("b=(-Inf;4]" = c(T,T,T,T,F,F,F,F,F,F),
                        "b=(4;7]"    = c(F,F,F,F,T,T,T,F,F,F),
                        "b=(7;Inf]"  = c(F,F,F,F,F,F,F,T,T,T)))

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

    expect_equal(partition(data.frame(b = 1:10),
                           .breaks = 3,
                           .keep = FALSE,
                           .method = "crisp",
                           .labels = c("A", "BBB", "cc"),
                           .right = TRUE),
                 tibble("b=A"   = c(T,T,T,T,F,F,F,F,F,F),
                        "b=BBB" = c(F,F,F,F,T,T,T,F,F,F),
                        "b=cc"  = c(F,F,F,F,F,F,F,T,T,T)))

    expect_equal(partition(data.frame(b = 1:10),
                           .breaks = c(1, 3, 5, 7, 10),
                           .keep = FALSE,
                           .method = "crisp",
                           .right = TRUE,
                           .span = 2),
                 tibble("b=(1;5]"  = c(F,T,T,T,T,F,F,F,F,F),
                        "b=(3;7]"  = c(F,F,F,T,T,T,T,F,F,F),
                        "b=(5;10]" = c(F,F,F,F,F,T,T,T,T,T)))

    expect_equal(partition(data.frame(b = 1:10),
                           .breaks = c(1, 3, 5, 7, 10),
                           .keep = FALSE,
                           .method = "crisp",
                           .right = TRUE,
                           .span = 2,
                           .inc = 2),
                 tibble("b=(1;5]"  = c(F,T,T,T,T,F,F,F,F,F),
                        "b=(5;10]" = c(F,F,F,F,F,T,T,T,T,T)))

    expect_equal(partition(data.frame(b = 1:10),
                           .breaks = 1:9,
                           .keep = FALSE,
                           .method = "crisp",
                           .right = TRUE,
                           .span = 2,
                           .inc = 3),
                 tibble("b=(1;3]"  = c(F,T,T,F,F,F,F,F,F,F),
                        "b=(4;6]" = c(F,F,F,F,T,T,F,F,F,F),
                        "b=(7;9]" = c(F,F,F,F,F,F,F,T,T,F)))

    expect_equal(partition(data.frame(b = 1:10),
                           .breaks = c(-Inf, 4, 7, Inf),
                           .keep = FALSE,
                           .method = "crisp",
                           .right = TRUE,
                           .inc = 2),
                 tibble("b=(-Inf;4]" = c(T,T,T,T,F,F,F,F,F,F),
                        "b=(7;Inf]"  = c(F,F,F,F,F,F,F,T,T,T)))


    expect_error(partition(data.frame(a = 0:10),
                           .method = "crisp"),
                 "`.breaks` must not be NULL in order to partition numeric column `a`")

    expect_error(partition(data.frame(a = 0:10),
                           .breaks = -1,
                           .method = "crisp"),
                 "If `.breaks` is a single value, it must be a natural number greater than 1.")

    expect_error(partition(data.frame(a = 0:10),
                           .breaks = 1,
                           .method = "crisp"),
                 "If `.breaks` is a single value, it must be a natural number greater than 1.")

    expect_error(partition(data.frame(a = 0:10),
                           .breaks = 1.5,
                           .method = "crisp"),
                 "If `.breaks` is a single value, it must be a natural number greater than 1.")

    expect_error(partition(data.frame(b = 1:10),
                           .breaks = 2,
                           .method = "crisp",
                           .labels = c("A", "BBB", "cc")),
                 "If `.breaks` is scalar, the length of `.labels` must be equal to the value of `.breaks`.")

    expect_error(partition(data.frame(b = 1:10),
                           .breaks = c(-Inf, 4, 7, Inf),
                           .method = "crisp",
                           .labels = c("A", "cc")),
                 "If `.breaks` is non-scalar, the length of `.labels` must be equal to")
})


test_that("partition crisp styles", {
    x <- c(1.0, 2.2, 2.4, 2.6, 3, 4, 5, 6, 9)
    expect_equal(partition(data.frame(a = x),
                           .breaks = 2,
                           .keep = FALSE,
                           .method = "crisp",
                           .style = "equal"),
                 tibble("a=(-Inf;5]" = c(T,T,T,T,T,T,T,F,F),
                        "a=(5;Inf]"  = c(F,F,F,F,F,F,F,T,T)))

    expect_equal(partition(data.frame(a = x),
                           .breaks = 2,
                           .keep = FALSE,
                           .method = "crisp",
                           .style = "quantile"),
                 tibble("a=(-Inf;3]" = c(T,T,T,T,T,F,F,F,F),
                        "a=(3;Inf]"  = c(F,F,F,F,F,T,T,T,T)))

    expect_equal(partition(data.frame(a = x),
                           .breaks = 2,
                           .keep = FALSE,
                           .method = "crisp",
                           .style = "kmeans"),
                 tibble("a=(-Inf;4.5]" = c(T,T,T,T,T,T,F,F,F),
                        "a=(4.5;Inf]"  = c(F,F,F,F,F,F,T,T,T)))
})


test_that("partition triangle", {
    expect_equal(partition(data.frame(a = 0:10),
                           .breaks = 2,
                           .keep = FALSE,
                           .method = "triangle"),
                 tibble("a=(-Inf;0;10)" = seq(1, 0, length.out = 11),
                        "a=(0;10;Inf)"  = seq(0, 1, length.out = 11)))

    expect_equal(partition(data.frame(a = 0:10),
                           .breaks = 3,
                           .keep = FALSE,
                           .method = "triangle"),
                 tibble("a=(-Inf;0;5)" = c(1.0, 0.8, 0.6, 0.4, 0.2, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0),
                        "a=(0;5;10)"   = c(0.0, 0.2, 0.4, 0.6, 0.8, 1.0, 0.8, 0.6, 0.4, 0.2, 0.0),
                        "a=(5;10;Inf)" = c(0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.2, 0.4, 0.6, 0.8, 1.0)))

    expect_equal(partition(data.frame(b = 0:10),
                           .breaks = c(1, 3, 5, 7, 10),
                           .keep = FALSE,
                           .method = "triangle",
                           .right = TRUE,
                           .span = 2),
                 tibble("b=(1;3;5;7)"  = c(0, 0, 0.5, 1, 1, 1, 0.5, 0, 0, 0, 0),
                        "b=(3;5;7;10)"  = c(0, 0, 0, 0, 0.5, 1, 1, 1, 0.66667, 0.33333, 0)),
                 tolerance = 1e-3)

    expect_equal(partition(data.frame(b = 0:10),
                           .breaks = c(1, 3, 5, 7, 9, 10),
                           .keep = FALSE,
                           .method = "triangle",
                           .right = TRUE,
                           .span = 2,
                           .inc = 2),
                 tibble("b=(1;3;5;7)"  = c(0, 0, 0.5, 1, 1, 1, 0.5, 0, 0, 0, 0),
                        "b=(5;7;9;10)" = c(0, 0, 0, 0, 0, 0, 0.5, 1, 1, 1, 0)))

    expect_equal(partition(data.frame(b = 0:11),
                           .breaks = 1:10,
                           .keep = FALSE,
                           .method = "triangle",
                           .right = TRUE,
                           .span = 2,
                           .inc = 3),
                 tibble("b=(1;2;3;4)"  = c(0, 0, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0),
                        "b=(4;5;6;7)"  = c(0, 0, 0, 0, 0, 1, 1, 0, 0, 0, 0, 0),
                        "b=(7;8;9;10)" = c(0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 0, 0)))

    expect_equal(partition(data.frame(b = 0:10),
                           .breaks = c(-Inf, 3, 6, 9, Inf),
                           .keep = FALSE,
                           .method = "triangle",
                           .right = TRUE,
                           .inc = 2),
                 tibble("b=(-Inf;3;6)" = c(1, 1, 1, 1, 0.6667, 0.3333, 0, 0, 0, 0, 0),
                        "b=(6;9;Inf)"  = c(0, 0, 0, 0, 0, 0, 0, 0.3333, 0.6667, 1, 1)),
                 tolerance = 1e-3)


    expect_error(partition(data.frame(a = 0:10),
                           .breaks = 1,
                           .keep = FALSE,
                           .method = "triangle"),
                 "If `.breaks` is a single value, it must be a natural number greater than 1.")

    expect_error(partition(data.frame(a = 0:10),
                           .breaks = c(2, 5),
                           .keep = FALSE,
                           .method = "triangle"),
                 "If `.breaks` is non-scalar, it must be a vector with at least 3 elements.")

    expect_error(partition(data.frame(b = 1:10),
                           .breaks = 2,
                           .method = "triangle",
                           .labels = c("A", "BBB", "cc")),
                 "If `.breaks` is scalar, the length of `.labels` must be equal to the value of `.breaks`.")

    expect_error(partition(data.frame(b = 1:10),
                           .breaks = c(-Inf, 4, 7, Inf),
                           .method = "triangle",
                           .labels = c("A", "b", "cc")),
                 "If `.breaks` is non-scalar, the length of `.labels` must be equal to")
})


test_that("partition raisedcos", {
    res <- partition(data.frame(a = 0:10),
                     .breaks = 2,
                     .keep = FALSE,
                     .method = "raisedcos")

    expect_equal(names(res), c("a=(-Inf;0;10)", "a=(0;10;Inf)"))
    expect_equal(res[[1]],
                 c(1.00000000, 0.97552826, 0.90450850, 0.79389263, 0.65450850,
                   0.50000000, 0.34549150, 0.20610737, 0.09549150, 0.02447174,
                   0.00000000))
    expect_equal(res[[2]],
                 c(0.00000000, 0.02447174, 0.09549150, 0.20610737, 0.34549150,
                   0.50000000, 0.65450850, 0.79389263, 0.90450850, 0.97552826,
                   1.00000000))

    expect_error(partition(data.frame(a = 0:10),
                           .breaks = 1,
                           .keep = FALSE,
                           .method = "raisedcos"),
                 "If `.breaks` is a single value, it must be a natural number greater than 1.")

    expect_error(partition(data.frame(a = 0:10),
                           .breaks = c(2, 5),
                           .keep = FALSE,
                           .method = "raisedcos"),
                 "If `.breaks` is non-scalar, it must be a vector with at least 3 elements.")

    expect_error(partition(data.frame(b = 1:10),
                           .breaks = 2,
                           .method = "raisedcos",
                           .labels = c("A", "BBB", "cc")),
                 "If `.breaks` is scalar, the length of `.labels` must be equal to the value of `.breaks`.")

    expect_error(partition(data.frame(b = 1:10),
                           .breaks = c(-Inf, 4, 7, Inf),
                           .method = "raisedcos",
                           .labels = c("A", "b", "cc")),
                 "If `.breaks` is non-scalar, the length of `.labels` must be equal to")
})


test_that("partition errors", {
    d <- data.frame(a = factor(c("a", "a", "b", "b", "a")))

    expect_error(partition(as.list(d), a),
                 "`.data` must be a data frame")
    expect_error(partition(d, x),
                 "Can't select columns that don't exist")
    expect_error(partition(data.frame(a = 0:10),
                           .breaks = "x",
                           .method = "crisp"),
                 "`.breaks` must be a numeric vector or NULL")
    expect_error(partition(d, a, .labels = 1:5),
                 "`.labels` must be a character vector")
    expect_error(partition(d, a, .na = "TRUE"),
                 "`.na` must be a flag")
    expect_error(partition(d, a, .keep = "TRUE"),
                 "`.keep` must be a flag")
    expect_error(partition(d, a, .right = "TRUE"),
                 "`.right` must be a flag")
    expect_error(partition(d, a, .method = "foo"),
                 '`.method` must be equal to one of: "dummy", "crisp", "triangle", "raisedcos".')

})

