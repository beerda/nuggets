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

    test_that("duplicate antecedent") {
        List implications = List::create(
            IntegerVector::create(1, 1, 3)
        );

        vector<size_t> initial = {1};

        DeductionEngine engine(10, implications);
        Clause result = engine.deduce(initial);

        expect_true(result.size() == 2);
        expect_true(result.contains(1));
        expect_true(result.contains(3));
    }

    test_that("isDerivableWithout check") {
        List implications = List::create(
            IntegerVector::create(1, 2, 3), // 1 AND 2 => 3
            IntegerVector::create(3, 4),    // 3 => 4
            IntegerVector::create(5)         // => 5 (empty antecedent)
        );

        DeductionEngine engine(10, implications);

        vector<size_t> initial1 = {1, 2};
        expect_true(!engine.isDerivableWithout(initial1, 1));
        expect_true(!engine.isDerivableWithout(initial1, 2));
        expect_true(engine.isDerivableWithout(initial1, 3));
        expect_true(engine.isDerivableWithout(initial1, 4));
        expect_true(engine.isDerivableWithout(initial1, 5));

        vector<size_t> initial2 = {1};
        expect_true(!engine.isDerivableWithout(initial2, 1));
        expect_true(!engine.isDerivableWithout(initial2, 2));
        expect_true(!engine.isDerivableWithout(initial2, 3));
        expect_true(!engine.isDerivableWithout(initial2, 4));
        expect_true(engine.isDerivableWithout(initial2, 5));

        vector<size_t> initial3 = {5};
        expect_true(!engine.isDerivableWithout(initial3, 1));
        expect_true(!engine.isDerivableWithout(initial3, 2));
        expect_true(!engine.isDerivableWithout(initial3, 3));
        expect_true(!engine.isDerivableWithout(initial3, 4));
        expect_true(engine.isDerivableWithout(initial3, 5));

        vector<size_t> initial4 = {1, 2, 3, 4, 5};
        expect_true(!engine.isDerivableWithout(initial4, 1));
        expect_true(!engine.isDerivableWithout(initial4, 2));
        expect_true(engine.isDerivableWithout(initial4, 3));
        expect_true(engine.isDerivableWithout(initial4, 4));
        expect_true(engine.isDerivableWithout(initial4, 5));
    }

    test_that("hasRedundant check") {
        List implications = List::create(
            IntegerVector::create(1, 2, 3), // 1 AND 2 => 3
            IntegerVector::create(3, 4),    // 3 => 4
            IntegerVector::create(5)         // => 5 (empty antecedent)
        );

        DeductionEngine engine(10, implications);

        vector<size_t> initial1 = {1, 2};
        expect_true(!engine.hasRedundant(initial1));

        vector<size_t> initial2 = {1};
        expect_true(!engine.hasRedundant(initial2));

        vector<size_t> initial3 = {1, 2, 3};
        expect_true(engine.hasRedundant(initial3));

        vector<size_t> initial4 = {1, 2, 4};
        expect_true(engine.hasRedundant(initial4));

        vector<size_t> initial5 = {5};
        expect_true(engine.hasRedundant(initial5));

        vector<size_t> initial6 = {};
        expect_true(!engine.hasRedundant(initial6));
    }
}
