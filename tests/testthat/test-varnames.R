test_that("varnames", {
    expect_equal(varnames(NULL), NULL)
    expect_equal(varnames(character(0)), character(0))
    expect_equal(varnames(c("a=1", "a=2", "z", "b=x", "b=y")),
                 c("a", "a", "z", "b", "b"))

    expect_error(varnames(1:5),
                 "`x` must be a character vector or NULL.")
})
