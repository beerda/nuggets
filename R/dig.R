#'
#' @return
#' @author Michal Burda
#' @export
dig <- function(x,
                f,
                ...) {
    UseMethod("dig")
}


#' @rdname dig
#' @export
dig.default <- function(x, f, ...) {
    stop(paste0("'dig' is not implemented for class '", class(x), "'"))
}


.dig <- function(logicals,
                 doubles,
                 predicates,
                 logicals_foci,
                 doubles_foci,
                 f,
                 disjoint,
                 min_length,
                 max_length,
                 min_support,
                 ...) {
    assert_that(is.list(logicals))
    assert_that(is.list(doubles))
    assert_that(is.list(logicals_foci))
    assert_that(is.list(doubles_foci))

    assert_that(is.integer(predicates))
    assert_that(all(is.finite(predicates)))
    assert_that(length(predicates) == length(logicals) + length(doubles))

    assert_that(is.function(f))
    fun <- function(l) {
        do.call(f, c(l, list(...)))
    }
    arguments <- formalArgs(f)
    if (is.null(arguments)) {
        arguments <- ""
    }

    if (is.null(disjoint)) {
        disjoint <- integer(0L)
    }
    assert_that(is.vector(disjoint))
    assert_that(is.character(disjoint) || is.numeric(disjoint))
    assert_that(length(disjoint) == 0 || length(disjoint) == length(logicals) + length(doubles))
    disjoint <- as.factor(disjoint)
    disjoint <- as.integer(disjoint)


    assert_that(is.number(min_length))
    assert_that(is.finite(min_length))
    assert_that(min_length >= 0)
    min_length <- as.integer(min_length)

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
                   disjoint = disjoint,
                   minLength = min_length,
                   maxLength = max_length,
                   minSupport = as.double(min_support));

    dig_(logicals, doubles, logicals_foci, doubles_foci, config, fun)
}


#' @rdname dig
#' @export
dig.matrix <- function(x,
                       f,
                       condition = everything(),
                       focus = NULL,
                       disjoint = NULL,
                       min_length = 0,
                       max_length = Inf,
                       min_support = 0.0,
                       ...) {
    assert_that(is.matrix(x))

    cols <- lapply(seq_len(ncol(x)), function(i) x[, i])
    names(cols) <- colnames(x)
    if (is.null(names(cols))) {
        names(cols) <- seq_len(length(cols))
    }

    condition <- enquo(condition)
    focus <- enquo(focus)

    predicates <- eval_select(condition, cols)

    foci <- eval_select(focus, cols)
    foci <- cols[foci]

    cols <- cols[predicates]

    if (is.logical(x)) {
        .dig(logicals = cols,
             doubles = list(),
             predicates = predicates,
             logicals_foci = foci,
             doubles_foci = list(),
             f = f,
             disjoint = disjoint,
             min_length = min_length,
             max_length = max_length,
             min_support = min_support)

    } else if (is.double(x)) {
        assert_that(all(x >= 0.0))
        assert_that(all(x <= 1.0))

        .dig(logicals = list(),
             doubles = cols,
             predicates = predicates,
             logicals_foci = list(),
             doubles_foci = foci,
             f = f,
             disjoint = disjoint,
             min_length = min_length,
             max_length = max_length,
             min_support = min_support)

    } else {
        stop(paste0("'dig.matrix' is not implemented for non-double and non-logical matrices"))
    }
}
