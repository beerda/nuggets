#include <testthat.h>
#include "common.h"
#include "dig/BitChain.h"

context("dig/BitChain.h") {
    test_that("push_back") {
        BitChain b;

        expect_true(b.empty());
        expect_true(b.size() == 0);
        expect_true(b.nChunks() == 0);
        expect_true(b.getSum() == 0);

        b.push_back(true);
        expect_true(!b.empty());
        expect_true(b.size() == 1);
        expect_true(b.nChunks() == 1);
        expect_true(b.getSum() == 1);

        b.push_back(false);
        expect_true(!b.empty());
        expect_true(b.size() == 2);
        expect_true(b.nChunks() == 1);
        expect_true(b.getSum() == 1);

        b.push_back(true);
        expect_true(!b.empty());
        expect_true(b.size() == 3);
        expect_true(b.nChunks() == 1);
        expect_true(b.getSum() == 2);

        b.push_back(true);
        expect_true(!b.empty());
        expect_true(b.size() == 4);
        expect_true(b.nChunks() == 1);
        expect_true(b.getSum() == 3);

        for (int i = 0; i < 100; ++i)
            b.push_back(false);

        b.push_back(true);

        expect_true(!b.empty());
        expect_true(b.size() == 105);
        expect_true(b.nChunks() == (b.size() + BitChain::CHUNK_SIZE - 1) / BitChain::CHUNK_SIZE);
        expect_true(b.getSum() == 4);

        expect_true(b.at(0));
        expect_true(!b.at(1));
        expect_true(b.at(2));
        expect_true(b.at(3));

        for (int i = 0; i < 100; ++i)
            expect_true(!b.at(4 + i));

        expect_true(b.at(104));
    }

    test_that("create nonempty") {
        BitChain b(200);

        expect_true(b.size() == 200);
        expect_true(b.getSum() == 0);

        for (int i = 0; i < 200; ++i)
            expect_true(!b.at(i));
    }

    test_that("initialize from LogicalVector") {
        LogicalVector v(5);
        v[0] = true;
        v[1] = false;
        v[2] = true;
        v[3] = true;
        v[4] = false;

        BitChain b(v);
        expect_true(b.size() == 5);
        expect_true(b.getSum() == 3);
        expect_true(b.at(0));
        expect_true(!b.at(1));
        expect_true(b.at(2));
        expect_true(b.at(3));
        expect_true(!b.at(4));
        expect_true(b.getMutableData().capacity() == 1);
        expect_true(b.nChunks() == 1);
    }

    test_that("reserve") {
        BitChain b;

        b.reserve(BitChain::CHUNK_SIZE * 2);
        expect_true(b.size() == 0);
        expect_true(b.getMutableData().capacity() == 2);

        b.reserve(BitChain::CHUNK_SIZE * 5);
        expect_true(b.size() == 0);
        expect_true(b.getMutableData().capacity() == 5);

        b.reserve(BitChain::CHUNK_SIZE * 5 + 1);
        expect_true(b.size() == 0);
        expect_true(b.getMutableData().capacity() == 6);
    }

    test_that("negate") {
        BitChain b;

        expect_true(b.size() == 0);
        expect_true(b.getSum() == 0);

        b.negate();

        expect_true(b.size() == 0);
        expect_true(b.getSum() == 0);

        b.push_back(true);
        b.push_back(false);
        b.push_back(true);
        b.push_back(true);
        b.push_back(false);

        expect_true(b.size() == 5);
        expect_true(b.getSum() == 3);

        b.negate();

        expect_true(b.size() == 5);
        expect_true(b.getSum() == 2);

        expect_true(!b.at(0));
        expect_true(b.at(1));
        expect_true(!b.at(2));
        expect_true(!b.at(3));
        expect_true(b.at(4));
    }

    test_that("negate 10") {
        BitChain b;
        size_t limit = 10;

        for (size_t i = 0; i < limit; ++i) {
            b.push_back(i % 2 == 0);
        }

        for (size_t i = 0; i < limit; ++i) {
            expect_true(b.at(i) == (i % 2 == 0));
        }

        b.negate();

        for (size_t i = 0; i < limit; ++i) {
            expect_true(b.at(i) == (i % 2 != 0));
        }
    }

    test_that("negate 63") {
        BitChain b;
        size_t limit = 63;

        for (size_t i = 0; i < limit; ++i) {
            b.push_back(i % 2 == 0);
        }

        for (size_t i = 0; i < limit; ++i) {
            expect_true(b.at(i) == (i % 2 == 0));
        }

        b.negate();

        for (size_t i = 0; i < limit; ++i) {
            expect_true(b.at(i) == (i % 2 != 0));
        }
    }

    test_that("negate 64") {
        BitChain b;
        size_t limit = 64;

        for (size_t i = 0; i < limit; ++i) {
            b.push_back(i % 2 == 0);
        }

        for (size_t i = 0; i < limit; ++i) {
            expect_true(b.at(i) == (i % 2 == 0));
        }

        b.negate();

        for (size_t i = 0; i < limit /2; ++i) {
            expect_true(b.at(i) == (i % 2 != 0));
        }
    }

    test_that("negate 65") {
        BitChain b;
        size_t limit = 64;

        for (size_t i = 0; i < limit; ++i) {
            b.push_back(i % 2 == 0);
        }

        for (size_t i = 0; i < limit; ++i) {
            expect_true(b.at(i) == (i % 2 == 0));
        }

        b.negate();

        for (size_t i = 0; i < limit /2; ++i) {
            expect_true(b.at(i) == (i % 2 != 0));
        }
    }

    test_that("conjunction") {
        BitChain b1;
        BitChain b2;

        b1.push_back(true);
        b1.push_back(false);
        b1.push_back(true);
        b1.push_back(true);
        b1.push_back(false);

        b2.push_back(true);
        b2.push_back(true);
        b2.push_back(false);
        b2.push_back(true);
        b2.push_back(false);

        expect_true(b1.size() == 5);
        expect_true(b1.getSum() == 3);

        expect_true(b2.size() == 5);
        expect_true(b2.getSum() == 3);

        b1.conjunctWith(b2);

        expect_true(b1.size() == 5);
        expect_true(b1.getSum() == 2);

        expect_true(b1.at(0));
        expect_true(!b1.at(1));
        expect_true(!b1.at(2));
        expect_true(b1.at(3));
        expect_true(!b1.at(4));
    }

    test_that("negation and conjunction") {
        BitChain b1;
        BitChain b2;

        b1.push_back(true);
        b1.push_back(false);
        b1.push_back(true);
        b1.push_back(true);
        b1.push_back(false);

        b2.push_back(true);
        b2.push_back(true);
        b2.push_back(false);
        b2.push_back(true);
        b2.push_back(false);

        expect_true(b1.size() == 5);
        expect_true(b1.getSum() == 3);

        expect_true(b2.size() == 5);
        expect_true(b2.getSum() == 3);

        b1.negate();
        b2.negate();

        expect_true(b1.size() == 5);
        expect_true(b1.getSum() == 2);
        expect_true(b2.size() == 5);
        expect_true(b2.getSum() == 2);

        b1.conjunctWith(b2);

        expect_true(b1.size() == 5);
        expect_true(b1.getSum() == 1);

        expect_true(!b1.at(0));
        expect_true(!b1.at(1));
        expect_true(!b1.at(2));
        expect_true(!b1.at(3));
        expect_true(b1.at(4));
    }

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
