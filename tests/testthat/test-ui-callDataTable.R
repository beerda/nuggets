test_that("callDataTable()", {
    meta <- data.frame(
        data_name = c("condA", "condB", "numX"),
        type = c("condition", "condition", "numeric"),
        stringsAsFactors = FALSE
    )

    call_data <- list(colnames = c("A", "B", "C"))
    call_args <- list(
        condA = c("A", "C"),
        condB = "B",
        disjoint = c("A", "A", "C")
    )

    rules <- data.frame(x = 1)  # dummy object
    attr(rules, "call_data") <- call_data
    attr(rules, "call_args") <- call_args

    ui <- callDataTable(rules, meta)
    html <- as.character(ui)

    expect_match(html, "^<table class=\"info-table")
    expect_match(html, "<thead>.*<th>column name</th>[^<]*<th>condA</th>[^<]*<th>condB</th>[^<]*<th>disjoint</th>.*</thead>")
    expect_match(html, "<tr>.*<td>A</td>[^<]*<td>[^<]*<span[^<]*\u2714</span>[^<]*</td>[^<]*<td></td>[^<]*<td>A</td>.*</tr>")
    expect_match(html, "<tr>.*<td>B</td>[^<]*<td></td>[^<]*<td>[^<]*<span[^<]*\u2714</span>[^<]*</td>[^<]*<td>A</td>.*</tr>")
    expect_match(html, "<tr>.*<td>C</td>[^<]*<td>[^<]*<span[^<]*\u2714</span>[^<]*</td>[^<]*<td></td>[^<]*<td>C</td>.*</tr>")
    expect_match(html, "</table>$")
})
