test_that("numericFilterModule - ui: numeric, round 2, all specials", {
    meta <- tribble(
        ~data_name,          ~short_name,  ~long_name,           ~type,       ~round,
        "confidence",        "conf",       "Confidence",         "numeric",   2
    )

    mod <- numericFilterModule(id = "test",
                               x = c(1.1234, 2, 3.9876, NA, Inf, -Inf, NaN),
                               meta = meta,
                               resetAllEvent = "resetAllEvent")

    ui <- mod$ui()
    html <- as.character(ui)
    expect_match(html, "^<div class=\"tab-pane\" title=\"Confidence\"")
    expect_match(html, paste0("<input class=\"js-range-slider\" [^>]*",
                              "data-min=\"1.12\" data-max=\"3.99\" [^>]*",
                              "data-from=\"1.12\" data-to=\"3.99\" [^>]*"))
    expect_match(html, "<input type=\"checkbox\" name=\"test-special\" value=\"-Inf\" checked=\"checked\"/>")
    expect_match(html, "<input type=\"checkbox\" name=\"test-special\" value=\"NA\" checked=\"checked\"/>")
    expect_match(html, "<input type=\"checkbox\" name=\"test-special\" value=\"NaN\" checked=\"checked\"/>")
    expect_match(html, "<input type=\"checkbox\" name=\"test-special\" value=\"Inf\" checked=\"checked\"/>")
})


test_that("numericFilterModule - ui: numeric, round 1, no specials", {
    meta <- tribble(
        ~data_name,          ~short_name,  ~long_name,           ~type,       ~round,
        "confidence",        "conf",       "Confidence",         "numeric",   1
    )

    mod <- numericFilterModule(id = "test",
                               x = c(1.1234, 2, 3.9876),
                               meta = meta,
                               resetAllEvent = "resetAllEvent")

    ui <- mod$ui()
    html <- as.character(ui)
    expect_match(html, "^<div class=\"tab-pane\" title=\"Confidence\"")
    expect_match(html, paste0("<input class=\"js-range-slider\" [^>]*",
                              "data-min=\"1.1\" data-max=\"4\" [^>]*",
                              "data-from=\"1.1\" data-to=\"4\" [^>]*"))
    expect_no_match(html, "<input type=\"checkbox\" name=\"test-special\" value=\"-Inf\" checked=\"checked\"/>")
    expect_no_match(html, "<input type=\"checkbox\" name=\"test-special\" value=\"NA\" checked=\"checked\"/>")
    expect_no_match(html, "<input type=\"checkbox\" name=\"test-special\" value=\"NaN\" checked=\"checked\"/>")
    expect_no_match(html, "<input type=\"checkbox\" name=\"test-special\" value=\"Inf\" checked=\"checked\"/>")
})


test_that("numericFilterModule - ui: integer, NA special", {
    meta <- tribble(
        ~data_name,          ~short_name,  ~long_name,           ~type,       ~round,
        "confidence",        "conf",       "Confidence",         "integer",   NA
    )

    mod <- numericFilterModule(id = "test",
                               x = c(1, 2, NA, 3),
                               meta = meta,
                               resetAllEvent = "resetAllEvent")

    ui <- mod$ui()
    html <- as.character(ui)
    expect_match(html, "^<div class=\"tab-pane\" title=\"Confidence\"")
    expect_match(html, paste0("<input class=\"js-range-slider\" [^>]*",
                              "data-min=\"1\" data-max=\"3\" [^>]*",
                              "data-from=\"1\" data-to=\"3\" [^>]*",
                              "data-step=\"1\""))
    expect_no_match(html, "<input type=\"checkbox\" name=\"test-special\" value=\"-Inf\" checked=\"checked\"/>")
    expect_match(html, "<input type=\"checkbox\" name=\"test-special\" value=\"NA\" checked=\"checked\"/>")
    expect_no_match(html, "<input type=\"checkbox\" name=\"test-special\" value=\"NaN\" checked=\"checked\"/>")
    expect_no_match(html, "<input type=\"checkbox\" name=\"test-special\" value=\"Inf\" checked=\"checked\"/>")
})


test_that("numericFilterModule - server", {
    suppressMessages(library(shiny))

    meta <- tribble(
        ~data_name,          ~short_name,  ~long_name,           ~type,       ~round,
        "confidence",        "conf",       "Confidence",         "numeric",   1
    )

    mod <- numericFilterModule(id = "test",
                               x = c(1.1234, 2, 3.9876),
                               meta = meta,
                               resetAllEvent = "resetAllEvent")

    # Workaround:
    # Accordingly to documentation, the following line should be:
    # testServer(mod$server, ...).
    # However, testServer wants to pass id to the module server function,
    # but our module server function does not expect it.
    testServer(function(id) mod$server(), {
        session$setInputs(slider = c(1.5, 3.5))

        expect_match(output$summaryTable,
                     "^<table .* min .* Q1 .* median .* Q3 .* max .*</table>$")

        plot <- output$histogramPlot
        expect_true(is.list(plot))
        expect_true("src" %in% names(plot))
    })
})


test_that("numericFilterModule - filter", {
    meta <- tribble(
        ~data_name,          ~short_name,  ~long_name,           ~type,       ~round,
        "confidence",        "conf",       "Confidence",         "numeric",   1
    )

    mod <- numericFilterModule(id = "test",
                               x = c(1.2, 1.3, 1.5, NA, Inf, -Inf, NaN),
                               meta = meta,
                               resetAllEvent = "resetAllEvent")

    input <- list("test-slider" = c(-1, 1.4))
    res <- mod$filter(input)
    expect_equal(res, c(TRUE, TRUE, FALSE, FALSE, FALSE, FALSE, FALSE))

    input <- list("test-slider" = c(5, 6),
                  "test-special" = c("NA"))
    res <- mod$filter(input)
    expect_equal(res, c(FALSE, FALSE, FALSE, TRUE, FALSE, FALSE, FALSE))

    input <- list("test-slider" = c(5, 6),
                  "test-special" = c("Inf"))
    res <- mod$filter(input)
    expect_equal(res, c(FALSE, FALSE, FALSE, FALSE, TRUE, FALSE, FALSE))

    input <- list("test-slider" = c(5, 6),
                  "test-special" = c("-Inf"))
    res <- mod$filter(input)
    expect_equal(res, c(FALSE, FALSE, FALSE, FALSE, FALSE, TRUE, FALSE))

    input <- list("test-slider" = c(5, 6),
                  "test-special" = c("NaN"))
    res <- mod$filter(input)
    expect_equal(res, c(FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, TRUE))
})
