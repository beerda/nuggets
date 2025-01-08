test_that("is_almost_constant", {
    expect_true(is_almost_constant(logical(0), na_rm = FALSE))
    expect_true(is_almost_constant(logical(0), na_rm = TRUE))
    expect_true(is_almost_constant(1, na_rm = FALSE))
    expect_true(is_almost_constant(1, na_rm = TRUE))
    expect_true(is_almost_constant("x", na_rm = FALSE))
    expect_true(is_almost_constant("x", na_rm = TRUE))
    expect_true(is_almost_constant(NA, na_rm = FALSE))
    expect_true(is_almost_constant(NA, na_rm = TRUE))

    expect_true(is_almost_constant(rep(TRUE, 5), na_rm = FALSE))
    expect_true(is_almost_constant(rep(TRUE, 5), na_rm = TRUE))
    expect_true(is_almost_constant(rep("x", 5), na_rm = FALSE))
    expect_true(is_almost_constant(rep("x", 5), na_rm = TRUE))
    expect_true(is_almost_constant(rep(1, 5), na_rm = FALSE))
    expect_true(is_almost_constant(rep(1, 5), na_rm = TRUE))
    expect_true(is_almost_constant(rep(NA, 5), na_rm = FALSE))
    expect_true(is_almost_constant(rep(NA, 5), na_rm = TRUE))

    expect_false(is_almost_constant(factor(letters[1:5]), na_rm = FALSE))
    expect_true(is_almost_constant(factor(rep("x", 10), levels = letters), na_rm = FALSE))

    expect_false(is_almost_constant(1:2, na_rm = FALSE))
    expect_false(is_almost_constant(1:2, na_rm = TRUE))
    expect_false(is_almost_constant(1:12, na_rm = FALSE))
    expect_false(is_almost_constant(1:12, na_rm = TRUE))

    expect_false(is_almost_constant(c(rep("x", 5), rep(NA, 5)), na_rm = FALSE))
    expect_true(is_almost_constant(c(rep("x", 5), rep(NA, 5)), na_rm = TRUE))

    expect_true(is_almost_constant(c(rep("x", 11), rep("y", 1)), threshold = 0.9, na_rm = FALSE))
    expect_true(is_almost_constant(c(rep("x", 11), rep("y", 1)), threshold = 0.9, na_rm = TRUE))
    expect_false(is_almost_constant(c(rep("x", 10), rep("y", 2)), threshold = 0.9, na_rm = FALSE))
    expect_false(is_almost_constant(c(rep("x", 10), rep("y", 2)), threshold = 0.9, na_rm = TRUE))

    expect_true(is_almost_constant(c(rep("x", 11), rep(NA, 1)), threshold = 0.9, na_rm = FALSE))
    expect_true(is_almost_constant(c(rep("x", 11), rep(NA, 1)), threshold = 0.9, na_rm = TRUE))
    expect_false(is_almost_constant(c(rep("x", 10), rep(NA, 2)), threshold = 0.9, na_rm = FALSE))
    expect_true(is_almost_constant(c(rep("x", 10), rep(NA, 2)), threshold = 0.9, na_rm = TRUE))

    expect_true(is_almost_constant(c(rep(NA, 11), rep("y", 1)), threshold = 0.9, na_rm = FALSE))
    expect_true(is_almost_constant(c(rep(NA, 11), rep("y", 1)), threshold = 0.9, na_rm = TRUE))
    expect_false(is_almost_constant(c(rep(NA, 10), rep("y", 2)), threshold = 0.9, na_rm = FALSE))
    expect_true(is_almost_constant(c(rep(NA, 10), rep("y", 2)), threshold = 0.9, na_rm = TRUE))

    expect_true(is_almost_constant(c(rep(NA, 10), "x", "y"), threshold = 0.8, na_rm = FALSE))
    expect_false(is_almost_constant(c(rep(NA, 10), "x", "y"), threshold = 0.8, na_rm = TRUE))
})
