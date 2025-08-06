test_that("bound_range", {
    expect_equal(bound_range(NULL),
                 NULL)
    expect_equal(bound_range(numeric()),
                 NULL)
    expect_equal(bound_range(c(1, 2, 3)),
                 c(1, 3))
    expect_equal(bound_range(c(1, Inf, -3)),
                 c(-3, Inf))
    expect_equal(bound_range(c(1, -3, NA)),
                 c(NA_real_, NA_real_))
    expect_equal(bound_range(c(1, -3, NA), na_rm = TRUE),
                 c(-3, 1))
    expect_equal(bound_range(c(1, -Inf, NA), na_rm = TRUE),
                 c(-Inf, 1))
    expect_equal(bound_range(c(100.123, 200.189, 300.129), digits = 0),
                 c(100, 301))
    expect_equal(bound_range(c(100.129, 200.189, 300.149), digits = 1),
                 c(100.1, 300.2))
    expect_equal(bound_range(c(100.123, 200.189, 300.129), digits = 2),
                 c(100.12, 300.13))
    expect_equal(bound_range(c(190.123, 200.189, 301.129), digits = -2),
                 c(100, 400))
})
