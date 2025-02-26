test_that("is_condition", {
    d <- data.frame(a = 1:5, b = 1:5, bla = 1:5)

    expect_equal(is_condition(list(NULL), d),
                 TRUE)
    expect_equal(is_condition(list("a"), d),
                 TRUE)
    expect_equal(is_condition(list("foo"), d),
                 FALSE)
    expect_equal(is_condition(list("a", "bla"), d),
                 c(TRUE, TRUE))
    expect_equal(is_condition(list("x", c("z", "bla"), NULL, "b"), d),
                 c(FALSE, FALSE, TRUE, TRUE))
})
