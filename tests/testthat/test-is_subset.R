test_that("is_subset", {
    expect_true(is_subset(c(), c()))
    expect_true(is_subset(c(), 1:5))
    expect_true(is_subset(3:5, 1:8))
    expect_true(is_subset(3:5, 3:5))

    expect_false(is_subset(2:5, c()))
    expect_false(is_subset(2:5, 3:5))

    expect_error(is_subset(list(), list()))
    expect_error(is_subset(matrix(0, nrow = 3, ncol = 3),
                           matrix(0, nrow = 3, ncol = 3)))
})
