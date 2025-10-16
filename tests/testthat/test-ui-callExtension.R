test_that("callExtension returns NULL if .extensions is NULL", {
    res <- callExtension(NULL, "x")
    expect_null(res)
})

test_that("callExtension returns NULL if .id not found", {
    ext <- list(a = 1, b = 2)
    res <- callExtension(ext, "missing")
    expect_null(res)
})

test_that("callExtension returns the extension value when not a function", {
    ext <- list(msg = "hello")
    res <- callExtension(ext, "msg")
    expect_equal(res, "hello")
})

test_that("callExtension calls function extensions with arguments", {
    ext <- list(sumfun = function(x, y) x + y)
    res <- callExtension(ext, "sumfun", 3, 4)
    expect_equal(res, 7)
})

test_that("callExtension passes through ... correctly", {
    ext <- list(pastefun = function(...) paste(..., collapse = "-"))
    res <- callExtension(ext, "pastefun", "A", "B", "C")
    expect_equal(res, "A B C")

    ext <- list(pastefun = function(...) paste(..., collapse = "-"))
    res <- callExtension(ext, "pastefun", "A", "B", 1:3)
    expect_equal(res, "A B 1-A B 2-A B 3")
})

test_that("callExtension works with function returning NULL", {
    ext <- list(none = function() NULL)
    res <- callExtension(ext, "none")
    expect_null(res)
})

test_that("callExtension ignores ... when extension is not a function", {
    ext <- list(static = "constant")
    # Even though ... is provided, it should not fail
    res <- callExtension(ext, "static", "unused argument")
    expect_equal(res, "constant")
})

