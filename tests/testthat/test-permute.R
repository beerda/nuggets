test_that("permute", {
    expect_equal(permute(NULL), matrix(nrow = 0, ncol = 0))
    expect_equal(permute(1), matrix(1, ncol = 1))
    expect_equal(permute(1:2), matrix(c(1, 2, 2, 1), ncol = 2))
    expect_equal(permute(1:3), matrix(c(1, 2, 3,
                                        1, 3, 2,
                                        2, 1, 3,
                                        2, 3, 1,
                                        3, 1, 2,
                                        3, 2, 1), ncol = 3, byrow = TRUE))

    expect_equal(permute(c("a", "b")), matrix(c("a", "b", "b", "a"), ncol = 2))
})
