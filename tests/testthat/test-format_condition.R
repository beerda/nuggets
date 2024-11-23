test_that("format_condition", {
  expect_equal(format_condition(NULL), "{}")
  expect_equal(format_condition("a"), "{a}")
  expect_equal(format_condition(letters[1:4]), "{a,b,c,d}")

  expect_error(format_condition(1:4))
  expect_error(format_condition(list(a=letters[1:4])))
})
