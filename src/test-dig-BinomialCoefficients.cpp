#include <testthat.h>
#include "common.h"
#include "dig/BinomialCoefficients.h"

context("dig/BinomialCoefficients.h") {
    test_that("BinomialCoefficients 0") {
        BinomialCoefficients table(0); // treat as 1
        expect_true(table.get(0, 0) == 1);
        expect_true(table.get(0, 1) == 0);
        expect_true(table.get(1, 0) == 1);
        expect_true(table.get(1, 1) == 1);
    }

    test_that("BinomialCoefficients 1") {
        BinomialCoefficients table(1);
        expect_true(table.get(0, 0) == 1);
        expect_true(table.get(1, 0) == 1);
        expect_true(table.get(1, 1) == 1);
        expect_true(table.get(1, 2) == 0);
        try {
            table.get(2, 0);
            expect_true(false); // should not reach here
        } catch (const std::out_of_range& e) {
            expect_true(true); // expected exception
        }
    }

    test_that("BinomialCoefficients 2") {
        BinomialCoefficients table(2);
        expect_true(table.get(0, 0) == 1);
        expect_true(table.get(1, 0) == 1);
        expect_true(table.get(1, 1) == 1);
        expect_true(table.get(2, 0) == 1);
        expect_true(table.get(2, 1) == 2);
        expect_true(table.get(2, 2) == 1);
        expect_true(table.get(2, 3) == 0);
        try {
            table.get(3, 0);
            expect_true(false); // should not reach here
        } catch (const std::out_of_range& e) {
            expect_true(true); // expected exception
        }
    }

    test_that("BinomialCoefficients 5") {
        BinomialCoefficients table(5);
        expect_true(table.get(0, 0) == 1);
        expect_true(table.get(1, 0) == 1);
        expect_true(table.get(1, 1) == 1);
        expect_true(table.get(2, 0) == 1);
        expect_true(table.get(2, 1) == 2);
        expect_true(table.get(2, 2) == 1);
        expect_true(table.get(3, 0) == 1);
        expect_true(table.get(3, 1) == 3);
        expect_true(table.get(3, 2) == 3);
        expect_true(table.get(3, 3) == 1);
        expect_true(table.get(4, 0) == 1);
        expect_true(table.get(4, 1) == 4);
        expect_true(table.get(4, 2) == 6);
        expect_true(table.get(4, 3) == 4);
        expect_true(table.get(4, 4) == 1);
        expect_true(table.get(5, 0) == 1);
        expect_true(table.get(5, 1) == 5);
        expect_true(table.get(5, 2) == 10);
        expect_true(table.get(5, 3) == 10);
        expect_true(table.get(5, 4) == 5);
        expect_true(table.get(5, 5) == 1);
        try {
            table.get(6, 0);
            expect_true(false); // should not reach here
        } catch (const std::out_of_range& e) {
            expect_true(true); // expected exception
        }
    }
}
