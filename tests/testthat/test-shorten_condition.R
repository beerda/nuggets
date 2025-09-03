test_that("shorten_condition", {
    expect_equal(shorten_condition(NULL), NULL)
    expect_equal(shorten_condition(character(0)), character(0))

    expect_equal(shorten_condition(c("{a=1,b=100,c=3}", "{a=2}", "{b=100,c=3}"),
                                   method = "letters"),
                 c("{A,B,C}", "{D}", "{B,C}"))

    expect_equal(shorten_condition(c("{helloWorld=1}",
                                     "{helloWorld = 2}",
                                     "{c=3, helloWorld=1}"),
                                   method = "abbrev4"),
                 c("{hllW=1}", "{hllW=2}", "{c=3,hllW=1}"))

    expect_equal(shorten_condition(c("{helloWorld=1}",
                                     "{helloWorld = 2}",
                                     "{c=3, helloWorld=1}"),
                                   method = "abbrev8"),
                 c("{hellWrld=1}", "{hellWrld=2}", "{c=3,hellWrld=1}"))
})
