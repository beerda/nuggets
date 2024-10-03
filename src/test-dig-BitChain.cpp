#include <testthat.h>
#include "common.h"
#include "dig/BitChain.h"

context("dig/BitChain.h") {
    test_that("complex test") {
        BitChain b;

        expect_true(b.empty());
        expect_true(b.size() == 0);
        expect_true(b.getSum() == 0);

        b.negate();

        expect_true(b.empty());
        expect_true(b.size() == 0);
        expect_true(b.getSum() == 0);

        b.push_back(true);
        b.push_back(false);
        b.push_back(false);
        b.push_back(true);
        b.push_back(true);

        expect_false(b.empty());
        expect_true(b.size() == 5);
        expect_true(b.getSum() == 3);

        expect_true(b.at(0) == true);
        expect_true(b.at(1) == false);
        expect_true(b.at(2) == false);
        expect_true(b.at(3) == true);
        expect_true(b.at(4) == true);

        b.negate();

        expect_false(b.empty());
        expect_true(b.size() == 5);
        expect_true(b.getSum() == 2);

        expect_true(b.at(0) == false);
        expect_true(b.at(1) == true);
        expect_true(b.at(2) == true);
        expect_true(b.at(3) == false);
        expect_true(b.at(4) == false);
    }
}
