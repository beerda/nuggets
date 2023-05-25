#'
#' @return
#' @author Michal Burda
#' @export
dig <- function(x,
                f,
                max_length = Inf,
                min_support = 0.0,
                ...) {
    UseMethod("dig")
}


#' @rdname dig
#' @export
dig.default <- function(x, ...) {
    stop(paste0("'dig' is not implemented for class '", class(x), "'"))
}


.dig <- function(logicals,
                 doubles,
                 predicates,
                 f,
                 max_length,
                 min_support,
                 ...) {
    assert_that(is.list(logicals))
    assert_that(is.list(doubles))
    assert_that(is.integer(predicates))

    assert_that(is.function(f))
    fun <- function(l) {
        do.call(f, c(l, list(...)))
    }
    arguments <- formalArgs(f)
    if (is.null(arguments)) {
        arguments <- ""
    }

    assert_that(is.number(max_length))
    assert_that(max_length >= 0)
    if (!is.finite(max_length)) {
        max_length <- -1;
    }
    max_length <- as.integer(max_length)

    assert_that(is.number(min_support))
    assert_that(0.0 <= min_support && min_support <= 1.0)
    min_support <- as.double(min_support)

    config <- list(arguments = arguments,
                   predicates = predicates,
                   maxLength = max_length,
                   minSupport = as.double(min_support));

    dig_(logicals, doubles, config, fun)
}


#' @rdname dig
#' @export
dig.matrix <- function(x,
                       f,
                       max_length = Inf,
                       min_support = 0.0,
                       ...) {
    assert_that(is.matrix(x))

    predicates <- seq_len(ncol(x))
    cols <- lapply(seq_len(ncol(x)), function(i) x[, i])

    if (is.logical(x)) {
        .dig(logicals = cols,
             doubles = list(),
             predicates = predicates,
             f = f,
             max_length = max_length,
             min_support = min_support)

    } else if (is.double(x)) {
        assert_that(all(x >= 0.0))
        assert_that(all(x <= 1.0))

        .dig(logicals = list(),
             doubles = cols,
             predicates = predicates,
             f = f,
             max_length = max_length,
             min_support = min_support)

    } else {
        stop(paste0("'dig.matrix' is not implemented for non-double and non-logical matrices"))
    }
}
