test_that("values", {
    expect_equal(values(NULL), NULL)
    expect_equal(values(character(0)), character(0))
    expect_equal(values(c("a=1", "a=2", "z", "b=x", "b=y")),
                 c("1", "2", "", "x", "y"))

    expect_error(values(1:5),
                 "`x` must be a character vector or NULL.")
})
