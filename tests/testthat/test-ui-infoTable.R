test_that("infoTable 0 cols", {
    tab <- data.frame()
    ui <- infoTable(tab)
    html <- as.character(ui)

    expect_match(html,
                 paste("^<table class=\"info-table\" width=\"100%\">\\n *",
                       "<tbody>\\n* *",
                       "</tbody>\\n* *",
                       "</table>$",
                       sep = ""))
})

test_that("infoTable 2 cols", {
    tab <- data.frame(labels = c("A", "B", "C"),
                      values = c(1, 2, 3),
                      stringsAsFactors = FALSE)
    ui <- infoTable(tab)
    html <- as.character(ui)

    expect_match(html,
                 paste("^<table class=\"info-table\" width=\"100%\">\\n *",
                       "<tbody>\\n *",
                       "<tr>\\n *<td>A</td>\\n *<td>1</td>\\n *</tr>\\n *",
                       "<tr>\\n *<td>B</td>\\n *<td>2</td>\\n *</tr>\\n *",
                       "<tr>\\n *<td>C</td>\\n *<td>3</td>\\n *</tr>\\n *",
                       "</tbody>\\n *",
                       "</table>$",
                       sep = ""))
})

test_that("infoTable 3 cols", {
    tab <- data.frame(labels = c("A", "B", "C"),
                      values = c(1, 2, 3),
                      extra = c("x", "y", "z"),
                      stringsAsFactors = FALSE)
    ui <- infoTable(tab)
    html <- as.character(ui)

    expect_match(html,
                 paste("^<table class=\"info-table\" width=\"100%\">\\n *",
                       "<tbody>\\n *",
                       "<tr>\\n *<td>A</td>\\n *<td>1</td>\\n *<td>x</td>\\n *</tr>\\n *",
                       "<tr>\\n *<td>B</td>\\n *<td>2</td>\\n *<td>y</td>\\n *</tr>\\n *",
                       "<tr>\\n *<td>C</td>\\n *<td>3</td>\\n *<td>z</td>\\n *</tr>\\n *",
                       "</tbody>\\n *",
                       "</table>$",
                       sep = ""))
})
