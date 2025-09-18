test_that("infoBox", {
    # Test "info" status
    ui <- infoBox("Some text", "blah", status = "info")
    html <- as.character(ui)
    expect_match(html, "class=\"info-box\"")
    expect_match(html, "fa-circle-info")
    expect_match(html, "Some text\\n +blah")

    # Test "success" status
    ui <- infoBox("Done!", status = "success")
    html <- as.character(ui)
    expect_match(html, "fa-circle-check")

    # Test "danger" status
    ui <- infoBox("Error", status = "danger")
    html <- as.character(ui)
    expect_match(html, "fa-circle-xmark")

    # Test "warning" status
    ui <- infoBox("Careful", status = "warning")
    html <- as.character(ui)
    expect_match(html, "fa-triangle-exclamation")
})
