test_that("is_subset", {
  expect_true(is_subset(3:5, 1:8))
  expect_true(is_subset(3:5, 3:5))
  expect_false(is_subset(2:5, 3:5))
})
