set.seed(34523)

test_that("minimum (Goedel) t-norm", {
    expect_equal(.goedel_tnorm(0.2, 0.5, 0.1, 0.3), 0.1)
    expect_equal(.goedel_tnorm(0.4, 0.5, 0.3), 0.3)
    expect_equal(.goedel_tnorm(0.2, 0.5, 0.9), 0.2)
    expect_equal(.goedel_tnorm(0.2, 0.5, 0.0), 0)
    expect_equal(.goedel_tnorm(1, 1, 1, 1), 1)
    expect_equal(.goedel_tnorm(1, 0.9, 1, 1), 0.9)

    expect_equal(.goedel_tnorm(c(0.2, 0.5, 0.1, 0.3)), 0.1)
    expect_equal(.goedel_tnorm(c(0.4, 0.5, 0.3)), 0.3)
    expect_equal(.goedel_tnorm(c(0.2, 0.5, 0.9)), 0.2)
    expect_equal(.goedel_tnorm(c(0.2, 0.5, 0.0)), 0)
    expect_equal(.goedel_tnorm(c(1, 1, 1, 1)), 1)
    expect_equal(.goedel_tnorm(c(1, 0.9, 1, 1)), 0.9)
})

test_that("lukasiewicz t-norm", {
    expect_equal(.lukas_tnorm(0.2, 0.5, 0.1, 0.3), 0)
    expect_equal(.lukas_tnorm(0.8, 0.5, 0.9), 0.2)
    expect_equal(.lukas_tnorm(1, 1, 1, 1), 1)
    expect_equal(.lukas_tnorm(1, 0.9, 1, 1), 0.9)
    expect_equal(.lukas_tnorm(1, 0.9, 0.8, 1), 0.7)
    expect_equal(.lukas_tnorm(0.2, 0.5, 0.0), 0)

    expect_equal(.lukas_tnorm(c(0.2, 0.5, 0.1, 0.3)), 0)
    expect_equal(.lukas_tnorm(c(0.8, 0.5, 0.9)), 0.2)
    expect_equal(.lukas_tnorm(c(1, 1, 1, 1)), 1)
    expect_equal(.lukas_tnorm(c(1, 0.9, 1, 1)), 0.9)
    expect_equal(.lukas_tnorm(c(0.2, 0.5, 0.0)), 0)
})

test_that("product (Goguen) t-norm", {
    expect_equal(.goguen_tnorm(0.2, 0.5, 0.1, 0.3), 0.2 * 0.5 * 0.1 * 0.3)
    expect_equal(.goguen_tnorm(0.8, 0.5, 0.9), 0.8 * 0.5 * 0.9)
    expect_equal(.goguen_tnorm(1, 1, 1, 1), 1)
    expect_equal(.goguen_tnorm(1, 0.9, 1, 1), 0.9)
    expect_equal(.goguen_tnorm(0.2, 0.5, 0.0), 0)

    expect_equal(.goguen_tnorm(c(0.2, 0.5, 0.1, 0.3)), 0.2 * 0.5 * 0.1 * 0.3)
    expect_equal(.goguen_tnorm(c(0.8, 0.5, 0.9)), 0.8 * 0.5 * 0.9)
    expect_equal(.goguen_tnorm(c(1, 1, 1, 1)), 1)
    expect_equal(.goguen_tnorm(c(1, 0.9, 1, 1)), 0.9)
    expect_equal(.goguen_tnorm(c(0.2, 0.5, 0.0)), 0)
})


test_that("tnorm borders", {
    .tnorms <- list(goedel = .goedel_tnorm,
                    lukas = .lukas_tnorm,
                    goguen = .goguen_tnorm)

    for (ttt in names(.tnorms)) {
        tnorm <- .tnorms[[ttt]]

        expect_equal(tnorm(), NA_real_)
        expect_equal(tnorm(0.2, NA, 1), NA_real_)
        expect_equal(tnorm(0.2, NA, 0), NA_real_)
        expect_equal(tnorm(0.2, NaN, 1), NA_real_)
        expect_equal(tnorm(0.2, NaN, 0), NA_real_)

        expect_error(tnorm(0.2, Inf, 0), "argument out of range 0..1")
        expect_error(tnorm(0.2, -Inf, 0), "argument out of range 0..1")
        expect_error(tnorm(0.2, 3, 0), "argument out of range 0..1")
        expect_error(tnorm(0.2, -3, 0), "argument out of range 0..1")

        expect_equal(tnorm(c()), NA_real_)
        expect_equal(tnorm(c(0.2, NA, 1)), NA_real_)
        expect_equal(tnorm(c(0.2, NA, 0)), NA_real_)
        expect_equal(tnorm(c(0.2, NaN, 1)), NA_real_)
        expect_equal(tnorm(c(0.2, NaN, 0)), NA_real_)

        expect_error(tnorm(c(0.2, Inf, 0)), "argument out of range 0..1")
        expect_error(tnorm(c(0.2, -Inf, 0)), "argument out of range 0..1")
        expect_error(tnorm(c(0.2, 3, 0)), "argument out of range 0..1")
        expect_error(tnorm(c(0.2, -3, 0)), "argument out of range 0..1")
    }
})

test_that("parallel minimum t-norm", {
    expect_equal(
        .pgoedel_tnorm(
            c(0.2, 0.5, 0.4, 0.9, 1),
            c(0.5, 0.9, 0.8, 1.0, 1),
            c(0.6, 0.4, 0.0, 1.0, 1),
            c(0.3, 0.7, 0.5, 1.0, 1)
        ),
        c(0.2, 0.4, 0.0, 0.9, 1)
    )

    expect_equal(.pgoedel_tnorm(0.2, 0.5), 0.2)
    expect_equal(.pgoedel_tnorm(0.2, 0.5, 0.0), 0)
    expect_equal(.pgoedel_tnorm(c(0.2, 0.5, 0.0)), c(0.2, 0.5, 0.0))
})

test_that("parallel lukasiewicz t-norm", {
    expect_equal(
        .plukas_tnorm(
            c(0.2, 0.8, 0.4, 0.9, 1),
            c(0.5, 0.9, 0.8, 1.0, 1),
            c(0.6, 0.5, 0.0, 1.0, 1),
            c(0.3, 0.9, 0.5, 1.0, 1)
        ),
        c(0, 0.1, 0.0, 0.9, 1)
    )

    expect_equal(.plukas_tnorm(0.7, 0.8, 0.6), 0.1)
    expect_equal(.plukas_tnorm(0.2, 0.5, 0.0), 0)
    expect_equal(.plukas_tnorm(c(0.2, 0.5, 0.0)), c(0.2, 0.5, 0.0))
})

test_that("parallel product t-norm", {
    expect_equal(
        .pgoguen_tnorm(
            c(0.2, 0.5, 0.4, 0.9, 1),
            c(0.5, 0.9, 0.8, 1.0, 1),
            c(0.6, 0.4, 0.0, 1.0, 1),
            c(0.3, 0.7, 0.5, 1.0, 1)
        ),
        c(
            0.2 * 0.5 * 0.6 * 0.3,
            0.5 * 0.9 * 0.4 * 0.7,
            0.0, 0.9, 1
        )
    )

    expect_equal(.pgoguen_tnorm(0.2, 0.5), 0.2 * 0.5)
    expect_equal(.pgoguen_tnorm(0.2, 0.5, 0.0), 0)
    expect_equal(.pgoguen_tnorm(c(0.2, 0.5, 0.0)), c(0.2, 0.5, 0.0))
})

test_that("ptnorm borders", {
    .ptnorms <- list(goedel = .pgoedel_tnorm,
                    lukas = .plukas_tnorm,
                    goguen = .pgoguen_tnorm)

    for (ttt in names(.ptnorms)) {
        tnorm <- .ptnorms[[ttt]]

        expect_true(is.null(tnorm()))

        expect_equal(
            tnorm(c(0.2, NA, 1), c(0.8, 0.6, NA))[2:3],
            as.numeric(c(NA, NA))
        )
        expect_equal(
            tnorm(c(0.2, NA, 0), c(0.8, 0, NA))[2:3],
            as.numeric(c(NA, NA))
        )
        expect_equal(
            tnorm(c(0.2, NaN, 1), c(0.8, 0.6, NA))[2:3],
            as.numeric(c(NA, NA))
        )
        expect_equal(
            tnorm(c(0.2, NaN, 0), c(0.8, 0, NaN))[2:3],
            as.numeric(c(NA, NA))
        )

        expect_error(
            tnorm(c(0.2, 0.9, 0), c(0.8, 0, Inf)),
            "argument out of range 0..1"
        )
        expect_error(
            tnorm(c(0.2, 0.9, 0), c(0.8, 0, -Inf)),
            "argument out of range 0..1"
        )
        expect_error(
            tnorm(c(0.2, 0.9, 0), c(0.8, 0, 3)),
            "argument out of range 0..1"
        )
        expect_error(
            tnorm(c(0.2, 0.9, 0), c(0.8, 0, -3)),
            "argument out of range 0..1"
        )

        mr <- matrix(runif(12), nrow = 3, ncol = 4)
        colnames(mr) <- LETTERS[1:4]
        rownames(mr) <- letters[1:3]

        m0 <- matrix(0, nrow = 3, ncol = 4)
        colnames(m0) <- colnames(mr)
        rownames(m0) <- rownames(mr)
        expect_equal(tnorm(mr, 0), m0)
        expect_equal(tnorm(mr, m0), m0)

        m1 <- matrix(1, nrow = 3, ncol = 4)
        expect_equal(tnorm(mr, 1), mr)
        expect_equal(tnorm(mr, m1), mr)

        mx <- matrix(tnorm(c(mr), c(mr)), nrow = 3, ncol = 4)
        colnames(mx) <- colnames(mr)
        rownames(mx) <- rownames(mr)
        expect_equal(tnorm(mr, mr), mx)
    }
})

test_that("Goedel t-conorm", {
    expect_equal(.goedel_tconorm(0.2, 0.5, 0.1, 0.3), 0.5)
    expect_equal(.goedel_tconorm(0.4, 0.5, 0.8), 0.8)
    expect_equal(.goedel_tconorm(0.9, 0.5, 0.2), 0.9)
    expect_equal(.goedel_tconorm(0.2, 1, 0.0), 1)
    expect_equal(.goedel_tconorm(0, 0, 0, 0), 0)

    expect_equal(.goedel_tconorm(c(0.2, 0.5, 0.1, 0.3)), 0.5)
    expect_equal(.goedel_tconorm(c(0.4, 0.5, 0.8)), 0.8)
    expect_equal(.goedel_tconorm(c(0.9, 0.5, 0.2)), 0.9)
    expect_equal(.goedel_tconorm(c(0.2, 1, 0.0)), 1)
    expect_equal(.goedel_tconorm(c(0, 0, 0, 0)), 0)
})

test_that("Lukasiewicz t-conorm", {
    expect_equal(.lukas_tconorm(0.2, 0.5, 0.1, 0.0), 0.8)
    expect_equal(.lukas_tconorm(0.4, 0.5, 0.8), 1)
    expect_equal(.lukas_tconorm(1, 1, 1), 1)
    expect_equal(.lukas_tconorm(0, 0, 0, 0), 0)

    expect_equal(.lukas_tconorm(c(0.2, 0.5, 0.1, 0.0)), 0.8)
    expect_equal(.lukas_tconorm(c(0.4, 0.5, 0.8)), 1)
    expect_equal(.lukas_tconorm(c(1, 1, 1)), 1)
    expect_equal(.lukas_tconorm(c(0, 0, 0, 0)), 0)
})

test_that("Goguen t-conorm", {
    expect_equal(.goguen_tconorm(0.2, 0.5, 0.1, 0.3), 0.748)
    expect_equal(.goguen_tconorm(0.2, 1, 0.0), 1)
    expect_equal(.goguen_tconorm(0, 0, 0, 0), 0)

    expect_equal(.goguen_tconorm(c(0.2, 0.5, 0.1, 0.3)), 0.748)
    expect_equal(.goguen_tconorm(c(0.2, 1, 0.0)), 1)
    expect_equal(.goguen_tconorm(c(0, 0, 0, 0)), 0)
})

test_that('t-conorm borders', {
    .tconorms <- list(goedel = .goedel_tconorm,
                      lukas = .lukas_tconorm,
                      goguen = .goguen_tconorm)

    for (ttt in names(.tconorms)) {
        tconorm <- .tconorms[[ttt]]

        expect_equal(tconorm(), NA_real_)
        expect_equal(tconorm(0.2, NA, 0), NA_real_)
        expect_equal(tconorm(0.2, NA, 1), NA_real_)

        expect_error(tconorm(0.2, Inf, 0), "argument out of range 0..1")
        expect_error(tconorm(0.2, -Inf, 0), "argument out of range 0..1")
        expect_error(tconorm(0.2, 3, 0), "argument out of range 0..1")
        expect_error(tconorm(0.2, -3, 0), "argument out of range 0..1")

        expect_equal(tconorm(c()), NA_real_)
        expect_equal(tconorm(c(0.2, NA, 0)), NA_real_)
        expect_equal(tconorm(c(0.2, NA, 1)), NA_real_)

        expect_error(tconorm(c(0.2, Inf, 0)), "argument out of range 0..1")
        expect_error(tconorm(c(0.2, -Inf, 0)), "argument out of range 0..1")
        expect_error(tconorm(c(0.2, 3, 0)), "argument out of range 0..1")
        expect_error(tconorm(c(0.2, -3, 0)), "argument out of range 0..1")
    }
})

test_that("Goedel residuum", {
    expect_equal(.goedel_residuum(c(0, 0.2, 0.8, 1), 1), c(1, 1, 1, 1))
    expect_equal(.goedel_residuum(c(0, 0.2, 0.8, 1), 0), c(1, 0, 0, 0))
    expect_equal(.goedel_residuum(c(0, 0.2, 0.8, 1), 0.5), c(1, 1, 0.5, 0.5))
    expect_equal(.goedel_residuum(c(0, 0.2, 0.8, 1), c(0.3, 0.9)), c(1, 1, 0.3, 0.9))
})

test_that("Lukasiewicz residuum", {
    expect_equal(.lukas_residuum(c(0, 0.2, 0.8, 1), 1), c(1, 1, 1, 1))
    expect_equal(.lukas_residuum(c(0, 0.2, 0.8, 1), 0), c(1, 0.8, 0.2, 0))
    expect_equal(.lukas_residuum(c(0, 0.2, 0.8, 1), 0.5), c(1, 1, 0.7, 0.5))
    expect_equal(.lukas_residuum(c(0, 0.2, 0.8, 1), c(0.3, 0.9)), c(1, 1, 0.5, 0.9))
})

test_that("Goguen residuum", {
    expect_equal(.goguen_residuum(c(0, 0.2, 0.8, 1), 1), c(1, 1, 1, 1))
    expect_equal(.goguen_residuum(c(0, 0.2, 0.8, 1), 0), c(1, 0, 0, 0))
    expect_equal(.goguen_residuum(c(0, 0.2, 0.8, 1), 0.5), c(1, 1, 0.625, 0.5))
    expect_equal(.goguen_residuum(c(0, 0.2, 0.8, 1), c(0.3, 0.9)), c(1, 1, 0.375, 0.9))
})

test_that("Goedel bi-residuum", {
    expect_equal(.goedel_biresiduum(c(0, 0.2, 0.8, 1), 1), c(0, 0.2, 0.8, 1))
    expect_equal(.goedel_biresiduum(c(0, 0.2, 0.8, 1), 0), c(1, 0, 0, 0))
    expect_equal(.goedel_biresiduum(c(0, 0.2, 0.8, 1), 0.5), c(0, 0.2, 0.5, 0.5))
    expect_equal(.goedel_biresiduum(c(0, 0.2, 0.8, 1), c(0.3, 0.9)), c(0, 0.2, 0.3, 0.9))
})

test_that("Lukasiewicz bi-residuum", {
    expect_equal(.lukas_biresiduum(c(0, 0.2, 0.8, 1), 1), c(0, 0.2, 0.8, 1))
    expect_equal(.lukas_biresiduum(c(0, 0.2, 0.8, 1), 0), c(1, 0.8, 0.2, 0))
    expect_equal(.lukas_biresiduum(c(0, 0.2, 0.8, 1), 0.5), c(0.5, 0.7, 0.7, 0.5))
    expect_equal(.lukas_biresiduum(c(0, 0.2, 0.8, 1), c(0.3, 0.9)), c(0.7, 0.3, 0.5, 0.9))
})

test_that("Goguen bi-residuum", {
    expect_equal(.goguen_biresiduum(c(0, 0.2, 0.8, 1), 1), c(0, 0.2, 0.8, 1))
    expect_equal(.goguen_biresiduum(c(0, 0.2, 0.8, 1), 0), c(1, 0, 0, 0))
    expect_equal(.goguen_biresiduum(c(0, 0.2, 0.8, 1), 0.5), c(0, 2/5, 5/8, 0.5))
    expect_equal(.goguen_biresiduum(c(0, 0.2, 0.8, 1), c(0.3, 0.9)), c(0, 2/9, 3/8, 0.9))
})

test_that('residua borders', {
    .residua <- list(goedel = .goedel_residuum,
                     lukas = .lukas_residuum,
                     goguen = .goguen_residuum,
                     goedel_bi = .goedel_biresiduum,
                     lukas_bi = .lukas_biresiduum,
                     goguen_bi = .goguen_biresiduum)
    for (ttt in names(.residua)) {
        resid <- .residua[[ttt]]

        expect_equal(resid(0, NA), NA_real_)
        expect_equal(resid(0.4, NA), NA_real_)
        expect_equal(resid(1, NA), NA_real_)

        expect_error(resid(0.2, Inf), "argument out of range 0..1")
        expect_error(resid(0.2, -Inf), "argument out of range 0..1")
        expect_error(resid(0.2, 3), "argument out of range 0..1")
        expect_error(resid(0.2, -3), "argument out of range 0..1")

        expect_equal(resid(NA, 0), NA_real_)
        expect_equal(resid(NA, 0.2), NA_real_)
        expect_equal(resid(NA, 1), NA_real_)

        expect_error(resid(Inf, 0.2), "argument out of range 0..1")
        expect_error(resid(-Inf, 0.2), "argument out of range 0..1")
        expect_error(resid(3, 0.2), "argument out of range 0..1")
        expect_error(resid(-3, 0.2), "argument out of range 0..1")
    }
})

test_that("involutive negation", {
    expect_equal(
        .invol_neg(c(0, 0.2, NA, 0.8, 1, NaN)),
        c(1, 0.8, NA, 0.2, 0, NA)
    )

    m <- matrix(c(0, 0.2, NA, 0.8, 1, 0.3), nrow = 2)
    colnames(m) <- letters[1:3]
    rownames(m) <- letters[1:2]

    r <- matrix(c(1, 0.8, NA, 0.2, 0, 0.7), nrow = 2)
    colnames(r) <- letters[1:3]
    rownames(r) <- letters[1:2]

    expect_equal(.invol_neg(m), r)

    expect_error(.invol_neg(c(-3, 0.2)), "argument out of range 0..1")
    expect_error(.invol_neg(c(3, 0.2)), "argument out of range 0..1")
    expect_error(.invol_neg(c(-Inf, 0.2)), "argument out of range 0..1")
    expect_error(.invol_neg(c(Inf, 0.2)), "argument out of range 0..1")
})

test_that("strict negation", {
    expect_equal(
        .strict_neg(c(0, 0.2, NA, 0.8, 1, NaN)),
        c(1, 0, NA, 0, 0, NA)
    )

    m <- matrix(c(0, 0.2, NA, 0.8, 1, 0.3), nrow = 2)
    colnames(m) <- letters[1:3]
    rownames(m) <- letters[1:2]

    r <- matrix(c(1, 0, NA, 0, 0, 0), nrow = 2)
    colnames(r) <- letters[1:3]
    rownames(r) <- letters[1:2]

    expect_equal(.strict_neg(m), r)

    expect_error(.strict_neg(c(-3, 0.2)), "argument out of range 0..1")
    expect_error(.strict_neg(c(3, 0.2)), "argument out of range 0..1")
    expect_error(.strict_neg(c(-Inf, 0.2)), "argument out of range 0..1")
    expect_error(.strict_neg(c(Inf, 0.2)), "argument out of range 0..1")
})
