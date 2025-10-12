test_that("rulebaseTable", {
    rules <- data.frame(a = 1:3,
                        b = 4:6,
                        cond = c("x", "y", "x"))
    meta <- data.frame(data_name = c("a", "b", "cond"),
                       long_name = c("A", "B", "foobar"),
                       type = c("numeric", "numeric", "condition"),
                       stringsAsFactors = FALSE)

    ui <- rulebaseTable(rules, meta)
    html <- as.character(ui)

    expect_match(html, "^<table class=\"info-table")
    expect_match(html, "<td>Number of rules:</td>[^<]*<td>3</td>")
    expect_match(html, "<td>Number of columns:</td>[^<]*<td>3</td>")
    expect_match(html, "<td>Number of distinct foobars:</td>[^<]*<td>2</td>")
    expect_match(html, "</table>$")

    rules <- data.frame()
    ui <- rulebaseTable(rules, meta)
    html <- as.character(ui)

    expect_match(html, "^<table class=\"info-table")
    expect_match(html, "<td>Number of rules:</td>[^<]*<td>0</td>")
    expect_match(html, "<td>Number of columns:</td>[^<]*<td>0</td>")
    expect_match(html, "<td>Number of distinct foobars:</td>[^<]*<td>0</td>")
    expect_match(html, "</table>$")
})
