test_that("aboutTable", {
    ui <- aboutTable("stats")
    html <- as.character(ui)

    # Structure
    expect_match(html, paste0("^<div>\\n *",
                              "<table class=\"info-table left\" width=\"100%\">"))
    expect_match(html, "</table>\\n *</div>$")

    # Expected rows
    expect_match(html, "<tr>\\n *<td>Package:</td>\\n *<td>stats</td>\\n *</tr>")
    expect_match(html, "<td>Version:</td>")
    expect_match(html, "<td>Date:</td>")
    expect_match(html, "<td>Author:</td>")
    expect_match(html, "<td>License:</td>")
    expect_match(html, "<td>URL:</td>")
    expect_match(html, "<td>Bug reports:</td>")
    expect_match(html, "<td>Cite:</td>")
})
