#'
#' @return
#' @author Michal Burda
#' @export
calculate.associations <- function(x, measure) {
    .must_be_nugget(x, "associations")
    .must_have_numeric_column(x,
                              "pp",
                              arg_x = "x",
                              call = current_env())
    .must_have_numeric_column(x,
                              "pn",
                              arg_x = "x",
                              call = current_env())
    .must_have_numeric_column(x,
                              "np",
                              arg_x = "x",
                              call = current_env())
    .must_have_numeric_column(x,
                              "nn",
                              arg_x = "x",
                              call = current_env())
    .must_be_enum(measure,
                  names(.association_measures),
                  null = FALSE,
                  multi = TRUE,
                  arg = "measure",
                  call = current_env())

    if (any(c(x$pp, x$pn, x$np, x$nn) < 0)) {
        cli_abort(c("{.arg x} contains negative counts in columns {.var pp}, {.var pn}, {.var np}, or {.var nn}.",
                    "x" = "All counts must be non-negative."),
                  call = current_env())
    }

    if (any(measure %in% colnames(x))) {
        cli_warn(c("Some of the selected measures are already present in {.arg x} and will be overwritten.",
                   "i" = "Measures: {.var {intersect(measure, colnames(x))}}."),
                 call = current_env())
    }

    n1x <- x$pp + x$pn
    n0x <- x$np + x$nn
    nx1 <- x$pp + x$np
    nx0 <- x$pn + x$nn
    n <- n1x + n0x

    counts <- list(
        n11 = x$pp, n10 = x$pn, n01 = x$np, n00 = x$nn,
        n1x = n1x, n0x = n0x, nx1 = nx1, nx0 = nx0,
        n = n
    )

    res <- lapply(measure, function(m) {
        func <- .association_measures[[m]]
        func(counts)
    })
    names(res) <- measure

    bind_cols(x, res)
}

# A named list of measure functions, each taking `counts` (a list with n00, n01, n10, n11, n, n1x, n0x, nx1, nx0, etc.)
# Some measures accept additional arguments (e.g., laplace's k, chiSquared's significance/complement).
.association_measures <- list(
    cosine = function(counts) with(counts, n11 / sqrt(n1x * nx1)),

    conviction = function(counts) with(counts, n1x * nx0 / (n * n10)),

    gini = function(counts) with(counts,
                                 n1x / n * ((n11 / n1x)^2 + (n10 / n1x)^2) - (nx1 / n)^2 +
                                     n0x / n * ((n01 / n0x)^2 + (n00 / n0x)^2) - (nx0 / n)^2
    ),

    rule_power_factor = function(counts) with(counts, n11 * n11 / n1x / n),

    odds_ratio = function(counts) with(counts, n11 * n00 / (n10 * n01)),

    relative_risk = function(counts) with(counts, (n11 / n1x) / (n01 / n0x)),

    phi = function(counts) with(counts, (n * n11 - n1x * nx1) / sqrt(n1x * nx1 * n0x * nx0)),

    leverage = function(counts) with(counts, n11 / n - (n1x * nx1 / n^2)),

    collective_strength = function(counts) with(counts,
                                               n11 * n00 / (n1x * nx1 + n0x + nx0) *
                                                   (n^2 - n1x * nx1 - n0x * nx0) / (n - n11 - n00)
    ),

    importance = function(counts) with(counts,
                                       log(((n11 + 1) * (n0x + 2)) / ((n01 + 1) * (n1x + 2)), base = 10)
    ),

    imbalance = function(counts) with(counts, abs(n1x - nx1) / (n1x + nx1 - n11)),

    jaccard = function(counts) with(counts, n11 / (n1x + nx1 - n11)),

    kappa = function(counts) with(counts,
                                  (n * n11 + n * n00 - n1x * nx1 - n0x * nx0) /
                                      (n^2 - n1x * nx1 - n0x * nx0)
    ),

    lambda = function(counts) with(counts, {
        max_x0x1 <- apply(cbind(nx1, nx0), 1, max)
        (apply(cbind(n11, n10), 1, max) + apply(cbind(n01, n00), 1, max) - max_x0x1) /
            (n - max_x0x1)
    }),

    mutual_information = function(counts) with(counts, (
        n00 / n * log(n * n00 / (n0x * nx0)) +
            n01 / n * log(n * n01 / (n0x * nx1)) +
            n10 / n * log(n * n10 / (n1x * nx0)) +
            n11 / n * log(n * n11 / (n1x * nx1))
    ) /
        pmin(
            -1 * (n0x / n * log(n0x / n) + n1x / n * log(n1x / n)),
            -1 * (nx0 / n * log(nx0 / n) + nx1 / n * log(nx1 / n))
        )),

    maxconfidence = function(counts) with(counts, pmax(n11 / n1x, n11 / nx1)),

    j_measure = function(counts) with(counts,
                                     n11 / n * log(n * n11 / (n1x * nx1)) +
                                         n10 / n * log(n * n10 / (n1x * nx0))
    ),

    kulczynski = function(counts) with(counts, (n11 / n1x + n11 / nx1) / 2),

    #laplace = function(counts, k) with(counts, (n11 + 1) / (n1x + k)),

    certainty = function(counts) with(counts, (n11 / n1x - nx1 / n) / (1 - nx1 / n)),

    added_value = function(counts) with(counts, n11 / n1x - nx1 / n),

    ralambondrainy = function(counts) with(counts, n10 / n),

    sebag = function(counts) with(counts, (n1x - n10) / n10),

    counterexample = function(counts) with(counts, (n11 - n10) / n11),

    confirmed_confidence = function(counts) with(counts, (n11 - n10) / n1x),

    casual_support = function(counts) with(counts, (n1x + nx1 - 2 * n10) / n),

    casual_confidence = function(counts) with(counts, 1 - n10 / n * (1 / n1x + 1 / nx1)),

    least_contradiction = function(counts) with(counts, (n1x - n10) / nx1),

    centered_confidence = function(counts) with(counts, nx0 / n - n10 / n1x),

    varying_liaison = function(counts) with(counts, (n1x - n10) / (n1x * nx1 / n) - 1),

    yule_q = function(counts) with(counts, {
        OR <- n11 * n00 / (n10 * n01)
        (OR - 1) / (OR + 1)
    }),

    yule_y = function(counts) with(counts, {
        OR <- n11 * n00 / (n10 * n01)
        (sqrt(OR) - 1) / (sqrt(OR) + 1)
    }),

    lerman = function(counts) with(counts, (n11 - n1x * nx1 / n) / sqrt(n1x * nx1 / n)),

    implication_index = function(counts) with(counts, (n10 - n1x * nx0 / n) / sqrt(n1x * nx0 / n)),

    doc = function(counts) with(counts, (n11 / n1x) - (n01 / n0x))

#    chi_squared = function(counts, significance = FALSE, complement = FALSE) with(counts, {
#        len <- length(n11)
#        chi2 <- numeric(len)
#
#        for (i in seq_len(len)) {
#            fo <- matrix(c(n00[i], n01[i], n10[i], n11[i]), ncol = 2)
#            suppressWarnings(chi2[i] <- stats::chisq.test(fo, correct = FALSE)$statistic)
#        }
#
#        if (!significance) {
#            chi2
#        } else {
#            stats::pchisq(q = chi2, df = 1, lower.tail = !complement)
#        }
#    })
)
