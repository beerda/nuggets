test_that("rulebaseTable", {
    rules <- data.frame(a = 1:3, b = 4:6)
    ui <- rulebaseTable(rules)
    html <- as.character(ui)

    expect_match(html, "^<table class=\"info-table\"")
    expect_match(html, "<td>Number of rules:</td>[^<]*<td>3</td>")
    expect_match(html, "<td>Number of columns:</td>[^<]*<td>2</td>")
    expect_match(html, "</table>$")

    rules <- data.frame()
    ui <- rulebaseTable(rules)
    html <- as.character(ui)

    expect_match(html, "^<table class=\"info-table\"")
    expect_match(html, "<td>Number of rules:</td>[^<]*<td>0</td>")
    expect_match(html, "<td>Number of columns:</td>[^<]*<td>0</td>")
    expect_match(html, "</table>$")
})
