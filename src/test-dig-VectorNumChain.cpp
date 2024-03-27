#include <testthat.h>
#include "common.h"
#include "dig/VectorNumChain.h"

context("dig/VectorNumChain.h") {
    test_that("initializations") {
        VectorNumChain<GOGUEN> chain;
        expect_true(chain.empty());
        expect_true(chain.size() == 0);
        expect_true(EQUAL(chain.getSum(), 0));

        chain.pushBack(0);
        expect_false(chain.empty());
        expect_true(chain.size() == 1);
        expect_true(EQUAL(chain.getSum(), 0));
        expect_true(EQUAL(chain.at(0), 0.0));

        chain.pushBack(0.5);
        expect_false(chain.empty());
        expect_true(chain.size() == 2);
        expect_true(EQUAL(chain.getSum(), 0.5));
        expect_true(EQUAL(chain.at(0), 0.0));
        expect_true(EQUAL(chain.at(1), 0.5));

        chain.pushBack(1);
        expect_false(chain.empty());
        expect_true(chain.size() == 3);
        expect_true(EQUAL(chain.getSum(), 1.5));
        expect_true(EQUAL(chain.at(0), 0.0));
        expect_true(EQUAL(chain.at(1), 0.5));
        expect_true(EQUAL(chain.at(2), 1.0));

    }

    test_that("GOEDEL") {
        VectorNumChain<GOEDEL> chain;
        chain.pushBack(0.0);
        chain.pushBack(0.5);
        chain.pushBack(1.0);

        VectorNumChain<GOEDEL> other;
        other.pushBack(0.8);
        other.pushBack(0.6);
        other.pushBack(0.4);

        chain.conjunctWith(other);
        expect_true(EQUAL(chain.getSum(), 0.0 + 0.5 + 0.4));
    }

    test_that("GOGUEN") {
        VectorNumChain<GOGUEN> chain;
        chain.pushBack(0.0);
        chain.pushBack(0.5);
        chain.pushBack(1.0);

        VectorNumChain<GOGUEN> other;
        other.pushBack(0.8);
        other.pushBack(0.6);
        other.pushBack(0.4);

        chain.conjunctWith(other);
        expect_true(EQUAL(chain.getSum(), 0.0 + 0.3 + 0.4));
    }

    test_that("LUKASIEWICZ") {
        VectorNumChain<LUKASIEWICZ> chain;
        chain.pushBack(0.0);
        chain.pushBack(0.5);
        chain.pushBack(1.0);

        VectorNumChain<LUKASIEWICZ> other;
        other.pushBack(0.8);
        other.pushBack(0.6);
        other.pushBack(0.4);

        chain.conjunctWith(other);
        expect_true(EQUAL(chain.getSum(), 0 + 0.1 + 0.4));
    }
}
