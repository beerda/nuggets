test_that("must_be_vector", {
    x <- 1:5
    names(x) <- letters[1:5]
    expect_no_error(.must_be_vector(x))

    expect_no_error(.must_be_vector(1L:5L))
    expect_no_error(.must_be_vector(1:5 / 3))
    expect_no_error(.must_be_vector(letters[1:5]))

    expect_error(.must_be_vector(list(a=1)))
    expect_error(.must_be_vector(matrix(0, nrow = 2, ncol = 2)))
    expect_error(.must_be_vector(array(0, dim = c(1:3))))
    expect_error(.must_be_vector(factor(letters[1:5])))
    expect_error(.must_be_vector(structure(list(), class = "myclass")))
})
