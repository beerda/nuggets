test_that("varnames", {
    expect_equal(var_names(NULL), NULL)
    expect_equal(var_names(character(0)), character(0))
    expect_equal(var_names(c("a=1", "a=2", "z", "b=x", "b=y")),
                 c("a", "a", "z", "b", "b"))

    expect_error(var_names(1:5),
                 "`x` must be a character vector or NULL.")
})
