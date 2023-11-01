test_that("which_antichain", {
    expect_equal(which_antichain(list()),
                 integer(0))
    expect_equal(which_antichain(list(1, 2, 3)),
                 c(1, 2, 3))
    expect_equal(which_antichain(list(1, 1, 2)),
                 c(1, 3))
    expect_equal(which_antichain(list(c(1, 2, 5), 1, 2, 5, c(5, 2), 7)),
                 c(1, 6))
    expect_equal(which_antichain(list(c(1, 2), c(1, 3), c(4, 2), 1, 2, 3, 4)),
                 c(1, 2, 3))
})
