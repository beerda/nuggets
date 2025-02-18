#include <testthat.h>
#include "common.h"
#include "dig/PackedBitChain.h"

context("dig/PackedBitChain.h") {
    test_that("simple test on 1st chunk") {
        PackedBitChain b;

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

    test_that("packing") {
        PackedBitChain b;

        // add 0 1 0 1...
        for (size_t i = 0; i < 5; i++) {
            for (size_t j = 0; j < Bitset::CHUNK_SIZE; j++) {
                b.push_back(j % 2 == 0);  // 0 1 0 1...
            }
            expect_true(b.size() == (i + 1) * Bitset::CHUNK_SIZE);
            expect_true(b.getSum() == (i + 1) * Bitset::CHUNK_SIZE / 2);
            expect_true(b.sizeChunks() == 1);
        }

        // add 1 1 1 1...
        for (size_t i = 0; i < 5; i++) {
            for (size_t j = 0; j < Bitset::CHUNK_SIZE; j++) {
                b.push_back(true);  // 1 1 1 1...
            }
            expect_true(b.size() == (5 + i + 1) * Bitset::CHUNK_SIZE);
            expect_true(b.getSum() == 5 * Bitset::CHUNK_SIZE / 2 + (i + 1) * Bitset::CHUNK_SIZE);
            expect_true(b.sizeChunks() == 2);
        }

        // add 0 0 0 0...
        for (size_t i = 0; i < 5; i++) {
            for (size_t j = 0; j < Bitset::CHUNK_SIZE; j++) {
                b.push_back(false);  // 0 0 0 0...
            }
            expect_true(b.size() == (10 + i + 1) * Bitset::CHUNK_SIZE);
            expect_true(b.getSum() == 5 * Bitset::CHUNK_SIZE / 2 + 5 * Bitset::CHUNK_SIZE);
            expect_true(b.sizeChunks() == 3);
        }

        // check 0 1 0 1...
        for (size_t i = 0; i < 5; i++) {
            for (size_t j = 0; j < Bitset::CHUNK_SIZE; j++) {
                size_t pos = i * Bitset::CHUNK_SIZE + j;
                expect_true(b.at(pos) == (pos % 2 == 0));
            }
        }

        // check 1 1 1 1...
        for (size_t i = 0; i < 5; i++) {
            for (size_t j = 0; j < Bitset::CHUNK_SIZE; j++) {
                size_t pos = (5 + i) * Bitset::CHUNK_SIZE + j;
                expect_true(b.at(pos) == true);
            }
        }

        // check 0 0 0 0...
        for (size_t i = 0; i < 5; i++) {
            for (size_t j = 0; j < Bitset::CHUNK_SIZE; j++) {
                size_t pos = (10 + i) * Bitset::CHUNK_SIZE + j;
                expect_true(b.at(pos) == false);
            }
        }

        // -----------------------------
        b.negate();

        expect_true(b.size() == 15 * Bitset::CHUNK_SIZE);
        expect_true(b.getSum() == 5 * Bitset::CHUNK_SIZE / 2 + 5 * Bitset::CHUNK_SIZE);
        expect_true(b.sizeChunks() == 3);

        // check 1 0 1 0...
        for (size_t i = 0; i < 5; i++) {
            for (size_t j = 0; j < Bitset::CHUNK_SIZE; j++) {
                size_t pos = i * Bitset::CHUNK_SIZE + j;
                expect_true(b.at(pos) == (pos % 2 == 1));
            }
        }

        // check 0 0 0 0...
        for (size_t i = 0; i < 5; i++) {
            for (size_t j = 0; j < Bitset::CHUNK_SIZE; j++) {
                size_t pos = (5 + i) * Bitset::CHUNK_SIZE + j;
                expect_true(b.at(pos) == false);
            }
        }

        // check 1 1 1 1...
        for (size_t i = 0; i < 5; i++) {
            for (size_t j = 0; j < Bitset::CHUNK_SIZE; j++) {
                size_t pos = (10 + i) * Bitset::CHUNK_SIZE + j;
                expect_true(b.at(pos) == true);
            }
        }
    }

    test_that("conjunctWith") {
        PackedBitChain b1;
        PackedBitChain b2;

        // b1:
        for (size_t i = 0; i < 5; i++) {
            for (size_t j = 0; j < Bitset::CHUNK_SIZE; j++) {
                b1.push_back(true);  // 1 1 1 1...
            }
        }
        for (size_t i = 0; i < 5; i++) {
            for (size_t j = 0; j < Bitset::CHUNK_SIZE; j++) {
                b1.push_back(false);  // 0 0 0 0...
            }
        }
        b1.push_back(true);
        b1.push_back(false);
        b1.push_back(true);

        expect_true(b1.size() == 10 * Bitset::CHUNK_SIZE + 3);
        expect_true(b1.getSum() == 5 * Bitset::CHUNK_SIZE + 2);

        // b2:
        for (size_t i = 0; i < 10; i++) {
            for (size_t j = 0; j < Bitset::CHUNK_SIZE; j++) {
                b2.push_back(j % 2 == 0);  // 0 1 0 1...
            }
        }
        b2.push_back(false);
        b2.push_back(false);
        b2.push_back(true);

        expect_true(b2.size() == 10 * Bitset::CHUNK_SIZE + 3);
        expect_true(b2.getSum() == 5 * Bitset::CHUNK_SIZE + 1);

        // conjunction
        b1.conjunctWith(b2);
        expect_true(b1.size() == 10 * Bitset::CHUNK_SIZE + 3);
        expect_true(b1.getSum() == 5 * Bitset::CHUNK_SIZE / 2 + 1);

        for (size_t i = 0; i < 5; i++) {
            for (size_t j = 0; j < Bitset::CHUNK_SIZE; j++) {
                size_t pos = i * Bitset::CHUNK_SIZE + j;
                expect_true(b1.at(pos) == (j % 2 == 0));
            }
        }
        for (size_t i = 0; i < 5; i++) {
            for (size_t j = 0; j < Bitset::CHUNK_SIZE; j++) {
                size_t pos = (5 + i) * Bitset::CHUNK_SIZE + j;
                expect_true(b1.at(pos) == 0);
            }
        }
        expect_true(b1.at(10 * Bitset::CHUNK_SIZE + 0) == 0);
        expect_true(b1.at(10 * Bitset::CHUNK_SIZE + 1) == 0);
        expect_true(b1.at(10 * Bitset::CHUNK_SIZE + 2) == 1);
    }
}
