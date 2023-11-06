#include <testthat.h>
#include "common.h"
#include "dig/Bitset.h"

context("dig/Bitset.h") {
    test_that("push_back") {
        Bitset b;

        expect_true(b.empty());
        expect_true(b.size() == 0);
        expect_true(b.getSum() == 0);

        b.push_back(true);
        expect_true(!b.empty());
        expect_true(b.size() == 1);
        expect_true(b.getSum() == 1);

        b.push_back(false);
        expect_true(!b.empty());
        expect_true(b.size() == 2);
        expect_true(b.getSum() == 1);

        b.push_back(true);
        expect_true(!b.empty());
        expect_true(b.size() == 3);
        expect_true(b.getSum() == 2);

        b.push_back(true);
        expect_true(!b.empty());
        expect_true(b.size() == 4);
        expect_true(b.getSum() == 3);

        for (int i = 0; i < 100; ++i)
            b.push_back(false);

        b.push_back(true);

        expect_true(!b.empty());
        expect_true(b.size() == 105);
        expect_true(b.getSum() == 4);

        expect_true(b.at(0));
        expect_true(!b.at(1));
        expect_true(b.at(2));
        expect_true(b.at(3));

        for (int i = 0; i < 100; ++i)
            expect_true(!b.at(4 + i));

        expect_true(b.at(104));
    }

    test_that("reserve") {
        Bitset b;

        b.reserve(Bitset::CHUNK_SIZE * 2);
        expect_true(b.size() == 0);
        expect_true(b.getMutableData().capacity() == 2);

        b.reserve(Bitset::CHUNK_SIZE * 5);
        expect_true(b.size() == 0);
        expect_true(b.getMutableData().capacity() == 5);

        b.reserve(Bitset::CHUNK_SIZE * 5 + 1);
        expect_true(b.size() == 0);
        expect_true(b.getMutableData().capacity() == 6);
    }
}
