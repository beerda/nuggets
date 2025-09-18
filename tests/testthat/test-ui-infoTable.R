test_that("infoTable", {
    labels <- c("A", "B", "C")
    values <- c(1, 2, 3)
    ui <- infoTable(labels, values)
    html <- as.character(ui)

    expect_match(html,
                 paste("^<table class=\"info-table\" width=\"100%\">\\n *",
                       "<tr>\\n *<td>A</td>\\n *<td>1</td>\\n *</tr>\\n *",
                       "<tr>\\n *<td>B</td>\\n *<td>2</td>\\n *</tr>\\n *",
                       "<tr>\\n *<td>C</td>\\n *<td>3</td>\\n *</tr>\\n*</table>$",
                       sep = ""))
})
