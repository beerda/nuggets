test_that(".extract_cols", {
    x <- list(a = c(T,T,F), b = 1:3 / 3, c = c(F,T,F), d = 3:1 / 3)

    expect_equal(.extract_cols(x,
                               a:b,
                               allow_numeric = TRUE,
                               allow_empty = FALSE),
                 list(logicals = list(a = c(T,T,F)),
                      doubles = list(b = 1:3 / 3),
                      indices = c(a = 1, b = 2),
                      selected = c(T, T, F, F)))

    expect_equal(.extract_cols(x,
                               where(is.factor),
                               allow_numeric = TRUE,
                               allow_empty = TRUE),
                 list(logicals = structure(list(), names = character()),
                      doubles = structure(list(), names = character()),
                      indices = integer(),
                      selected = c(F, F, F, F)))

    expect_error(.extract_cols(x,
                               a:b,
                               allow_numeric = FALSE,
                               allow_empty = FALSE),
                 "All columns selected by .* must be logical.")

    expect_error(.extract_cols(x,
                               where(is.factor),
                               allow_numeric = FALSE,
                               allow_empty = FALSE),
                 "must select non-empty list of columns")

    x <- list(a = c(T,T,F), b = 1:3, c = c(F,T,F), d = 3:1)
    expect_error(.extract_cols(x,
                               a:b,
                               allow_numeric = TRUE,
                               allow_empty = FALSE),
                 "All columns selected by .* must be logical or numeric from the interval")

    x <- list(a = c(T,T,F), b = 1:3, c = c(F,T,F), d = c(0.1, 0.2, 10.1))
    expect_error(.extract_cols(x,
                               c:d,
                               allow_numeric = TRUE,
                               allow_empty = FALSE),
                 "All columns selected by .* must be logical or numeric from the interval")
})
