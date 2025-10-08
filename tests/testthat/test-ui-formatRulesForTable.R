test_that("formatRulesForTable highlights condition columns", {
    rules <- data.frame(id = 1:2, cond = c("A=1", "B=2"), score = c(0.1, 0.2))
    meta <- data.frame(
        data_name = c("cond", "score"),
        short_name = c("Condition", "Score"),
        type = c("condition", "numeric"),
        round = c(NA, NA),
        stringsAsFactors = FALSE
    )

    res <- formatRulesForTable(rules, meta)
    expect_equal(res$Condition, highlightCondition(rules$cond))
    expect_equal(colnames(res), c("id", "Condition", "Score"))
})

test_that("formatRulesForTable rounds numeric columns with round specified", {
    rules <- data.frame(id = 1:3, val = c(1.111, 2.222, 3.333))
    meta <- data.frame(
        data_name = "val",
        short_name = "Value",
        type = "numeric",
        round = 2,
        stringsAsFactors = FALSE
    )

    res <- formatRulesForTable(rules, meta)
    expect_equal(res$Value, round(rules$val, 2))
})

test_that("formatRulesForTable does not round numeric columns when round is NA", {
    rules <- data.frame(val = c(1.2345, 2.3456))
    meta <- data.frame(
        data_name = "val",
        short_name = "Value",
        type = "numeric",
        round = NA_real_,
        stringsAsFactors = FALSE
    )

    res <- formatRulesForTable(rules, meta)
    expect_equal(res$Value, rules$val)
})

test_that("formatRulesForTable handles data frame without id column", {
    rules <- data.frame(cond = c("X=1"), num = 42)
    meta <- data.frame(
        data_name = c("cond", "num"),
        short_name = c("Condition", "Number"),
        type = c("condition", "numeric"),
        round = c(NA, NA),
        stringsAsFactors = FALSE
    )

    res <- formatRulesForTable(rules, meta)
    expect_equal(colnames(res), c("Condition", "Number"))
})

test_that("formatRulesForTable preserves column order id + meta$data_name", {
    rules <- data.frame(id = 10:11, a = 1:2, b = 3:4)
    meta <- data.frame(
        data_name = c("b", "a"),
        short_name = c("Bee", "Aye"),
        type = c("numeric", "numeric"),
        round = c(NA, NA),
        stringsAsFactors = FALSE
    )

    res <- formatRulesForTable(rules, meta)
    expect_equal(colnames(res), c("id", "Bee", "Aye"))
    expect_equal(res$Bee, rules$b)
    expect_equal(res$Aye, rules$a)
})

test_that("formatRulesForTable works with multiple types in mixed order", {
    rules <- data.frame(id = 1, cond = "A=1", score = 0.9876, name = "rule")
    meta <- data.frame(
        data_name = c("cond", "score", "name"),
        short_name = c("Condition", "Score", "Name"),
        type = c("condition", "numeric", "other"),
        round = c(NA, 3, NA),
        stringsAsFactors = FALSE
    )

    res <- formatRulesForTable(rules, meta)
    expect_equal(colnames(res), c("id", "Condition", "Score", "Name"))
    expect_equal(res$Score, round(rules$score, 3))
    expect_equal(res$Condition, highlightCondition(rules$cond))
})
