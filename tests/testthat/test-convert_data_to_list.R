test_that(".convert_data_to_list", {
  x <- data.frame(a = 1:3, b = 4:6)
  expect_equal(.convert_data_to_list(x),
               list(a = 1:3, b = 4:6))

  x <- matrix(1:6,
              nrow = 2,
              dimnames = list(NULL, c("a", "b", "c")))
  expect_equal(.convert_data_to_list(x),
               list(a = 1:2, b = 3:4, c = 5:6))

  x <- 1:3
  expect_error(.convert_data_to_list(x),
               "must be a matrix or a data frame")

  x <- data.frame()
  expect_error(.convert_data_to_list(x),
               "must have at least one column")

  x <- data.frame(a = numeric(0))
  expect_error(.convert_data_to_list(x),
               "must have at least one row")
})
