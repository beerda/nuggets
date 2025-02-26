test_that("remove_ill_conditions", {
    d <- data.frame(a = 1:5, b = 1:5, bla = 1:5)

    expect_equal(remove_ill_conditions(list(), d),
                 list())
    expect_equal(remove_ill_conditions(list(NULL, NULL), d),
                 list(NULL, NULL))
    expect_equal(remove_ill_conditions(list("a", NULL, c("b", "bla"), "x", c("a", "b", "zz"), "b"), d),
                 list("a", NULL, c("b", "bla"), "b"))

})
