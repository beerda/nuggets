test_that("format_condition", {
  expect_equal(format_condition(NULL), "{}")
  expect_equal(format_condition("a"), "{a}")
  expect_equal(format_condition(letters[1:4]), "{a,b,c,d}")
})
