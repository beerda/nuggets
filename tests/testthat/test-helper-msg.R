test_that("msg helper", {
    expect_message(.msg(TRUE, "This is a message."), "This is a message.")
    expect_silent(.msg(FALSE, "This message should not be printed."))
})
