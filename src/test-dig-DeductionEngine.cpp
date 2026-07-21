#include <testthat.h>
#include "common.h"
#include "dig/DeductionEngine.h"


context("dig/DeductionEngine.h") {
    test_that("empty 1") {
        List implications = List::create();
        vector<size_t> initial = {};

        DeductionEngine engine(10, implications);
        Clause result = engine.deduce(initial);
        expect_true(result.size() == 0);
    }

    test_that("empty 2") {
        List implications = List::create();
        vector<size_t> initial = {8};

        DeductionEngine engine(10, implications);
        Clause result = engine.deduce(initial);

        expect_true(result.size() == 1);
        expect_true(result.contains(8));
    }

    test_that("deduce nothing") {
        List implications = List::create(
            IntegerVector::create(1, 2, 3), // 1 AND 2 => 3
            IntegerVector::create(3, 4),    // 3 => 4
            IntegerVector::create(5)         // => 5 (empty antecedent)
        );

        vector<size_t> initial = {8};

        DeductionEngine engine(10, implications);
        Clause result = engine.deduce(initial);

        expect_true(result.size() == 2);
        expect_true(result.contains(5));
        expect_true(result.contains(8));

    }

    test_that("deduce something") {
        List implications = List::create(
            IntegerVector::create(1, 2, 3), // 1 AND 2 => 3
            IntegerVector::create(3, 4),    // 3 => 4
            IntegerVector::create(5)         // => 5 (empty antecedent)
        );

        vector<size_t> initial = {7, 3};

        DeductionEngine engine(10, implications);
        Clause result = engine.deduce(initial);

        expect_true(result.size() == 4);
        expect_true(result.contains(3));
        expect_true(result.contains(4));
        expect_true(result.contains(5));
        expect_true(result.contains(7));

    }

    test_that("deduce transitive") {
        List implications = List::create(
            IntegerVector::create(1, 2, 3), // 1 AND 2 => 3
            IntegerVector::create(3, 4),    // 3 => 4
            IntegerVector::create(5)         // => 5 (empty antecedent)
        );

        vector<size_t> initial = {1, 2, 8};

        DeductionEngine engine(10, implications);
        Clause result = engine.deduce(initial);

        expect_true(result.size() == 6);
        expect_true(result.contains(1));
        expect_true(result.contains(2));
        expect_true(result.contains(3));
        expect_true(result.contains(4));
        expect_true(result.contains(5));
        expect_true(result.contains(8));
    }
}
