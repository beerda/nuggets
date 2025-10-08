test_that("creationParamsTable", {
    rules <- data.frame(x = 1:3)
    attr(rules, "call_function") <- "dig_tautologies"
    attr(rules, "call_args") <- list(
        min_support = 0.5,
        min_confidence = 0.7
    )

    ui <- creationParamsTable(rules)
    html <- as.character(ui)

    expect_match(html, "^<p>Generated using the function <a href=\"https://beerda.github.io/nuggets/reference/dig_tautologies\\.html\">dig_tautologies\\(\\)</a> with the following parameters:</p>")
    expect_match(html, "<td>min_support =</td>[^<]*<td><pre><code class=\"language-r\">0\\.5.*</code></pre>[^<]*</td>")
    expect_match(html, "<td>min_confidence =</td>[^<]*<td><pre><code class=\"language-r\">0\\.7.*</code></pre>[^<]*</td>")
})

