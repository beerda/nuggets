test_that("highlightCondition highlights single predicate correctly", {
    res <- highlightCondition("A=1")
    expect_match(res, "^<span class=\"pred_n\">A</span>=<span class=\"pred_v\">1</span>$")
})

test_that("highlightCondition highlights multiple predicates separated by commas", {
    res <- highlightCondition("A=1,B=2")
    # It should insert <br/> between predicates
    expect_match(res, "<span class=\"pred_n\">A</span>=<span class=\"pred_v\">1</span><br/><span class=\"pred_n\">B</span>=<span class=\"pred_v\">2</span>")
    # Exactly two predicate-name spans
    expect_equal(length(regmatches(res, gregexpr("class=\"pred_n\"", res))[[1]]), 2)
})

test_that("highlightCondition removes braces", {
    res <- highlightCondition("{A=1,B=2}")
    expect_false(grepl("[{}]", res))
})

test_that("highlightCondition escapes HTML special characters", {
    res <- highlightCondition("A=<script>")
    # '<' and '>' should be HTML escaped
    expect_match(res, "&lt;script&gt;")
    expect_false(grepl("<script>", res, fixed = TRUE))
})

test_that("highlightCondition handles empty and missing equal sign gracefully", {
    expect_equal(highlightCondition(""), "<span class=\"pred_n\"></span>")
    # With no '=', it should just wrap in pred_n span
    res <- highlightCondition("ABC")
    expect_match(res, "<span class=\"pred_n\">ABC</span>")
    expect_false(grepl("pred_v", res))
})
