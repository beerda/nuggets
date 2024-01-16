#include <testthat.h>
#include "common.h"
#include "dig/SparseBitChain.h"


context("dig/SparseBitChain.h") {
    test_that("push_back - lot of FALSE at start") {
        SparseBitChain b;

        if (Bitset::CHUNK_SIZE == 64) {
            expect_true(b.empty());
            expect_true(b.size() == 0);
            expect_true(b.getSum() == 0);
            expect_true(b.getGaps().size() == 0);
            expect_true(b.getBitsets().size() == 0);
            expect_true(b.getTrailing() == 0);

            b.push_back(false);                       // set 0 = FALSE
            expect_true(!b.empty());
            expect_true(b.size() == 1);
            expect_true(b.getSum() == 0);
            expect_true(b.getGaps().size() == 0);
            expect_true(b.getBitsets().size() == 0);
            expect_true(b.getTrailing() == 1);
            expect_true(!b.at(0));

            for (int i = 1; i <= 199; ++i) {
                b.push_back(false);                   // set 1..199 = FALSE
            }

            expect_true(!b.empty());
            expect_true(b.size() == 200);
            expect_true(b.getSum() == 0);
            expect_true(b.getGaps().size() == 0);
            expect_true(b.getBitsets().size() == 0);
            expect_true(b.getTrailing() == 200);
            expect_true(!b.at(0));
            expect_true(!b.at(1));
            expect_true(!b.at(2));
            expect_true(!b.at(100));
            expect_true(!b.at(198));
            expect_true(!b.at(199));

            b.push_back(true);                         // set 200 = TRUE
            expect_true(!b.empty());
            expect_true(b.size() == 201);
            expect_true(b.getSum() == 1);
            expect_true(b.getGaps().size() == 1);
            expect_true(b.getGaps()[0] == 3);          // 0..191 = FALSE
            expect_true(b.getBitsets().size() == 1);
            expect_true(b.getTrailing() == 0);
            expect_true(!b.getBitsets()[0].at(0));     // 192 = FALSE
            expect_true(!b.getBitsets()[0].at(1));     // 193 = FALSE
            expect_true(!b.getBitsets()[0].at(7));     // 199 = FALSE
            expect_true(b.getBitsets()[0].at(8));      // 200 = TRUE
            expect_true(b.getTrailing() == 0);
            expect_true(!b.at(0));
            expect_true(!b.at(1));
            expect_true(!b.at(2));
            expect_true(!b.at(100));
            expect_true(!b.at(198));
            expect_true(!b.at(199));
            expect_true(b.at(200));

            b.push_back(true);                         // set 201 = TRUE
            expect_true(!b.empty());
            expect_true(b.size() == 202);
            expect_true(b.getSum() == 2);
            expect_true(b.getGaps().size() == 1);
            expect_true(b.getGaps()[0] == 3);          // 0..191 = FALSE
            expect_true(b.getBitsets().size() == 1);
            expect_true(b.getTrailing() == 0);
            expect_true(!b.getBitsets()[0].at(0));     // 192 = FALSE
            expect_true(!b.getBitsets()[0].at(1));     // 193 = FALSE
            expect_true(!b.getBitsets()[0].at(7));     // 199 = FALSE
            expect_true(b.getBitsets()[0].at(8));      // 200 = TRUE
            expect_true(b.getBitsets()[0].at(9));      // 201 = TRUE
            expect_true(b.getTrailing() == 0);
            expect_true(!b.at(199));
            expect_true(b.at(200));
            expect_true(b.at(201));
        }
    }

    test_that("push_back - lot of TRUE at start") {
        SparseBitChain b;

        if (Bitset::CHUNK_SIZE == 64) {
            expect_true(b.empty());
            expect_true(b.size() == 0);
            expect_true(b.getSum() == 0);
            expect_true(b.getGaps().size() == 0);
            expect_true(b.getBitsets().size() == 0);
            expect_true(b.getTrailing() == 0);

            for (int i = 0; i < 200; ++i) {
                b.push_back(true);                   // set 0..199 = TRUE
            }

            expect_true(!b.empty());
            expect_true(b.size() == 200);
            expect_true(b.getSum() == 200);
            expect_true(b.getGaps().size() == 1);
            expect_true(b.getGaps()[0] == 0);
            expect_true(b.getBitsets().size() == 1);
            expect_true(b.getBitsets()[0].size() == 200);
            expect_true(b.getBitsets()[0].getSum() == 200);
            expect_true(b.getTrailing() == 0);
            expect_true(b.at(0));
            expect_true(b.at(1));
            expect_true(b.at(100));
            expect_true(b.at(198));
            expect_true(b.at(199));

            for (int i = 200; i <= 255; ++i) {
                b.push_back(false);                   // set 200..255 = FALSE
            }
            expect_true(!b.empty());
            expect_true(b.size() == 256);
            expect_true(b.getSum() == 200);
            expect_true(b.getGaps().size() == 1);
            expect_true(b.getGaps()[0] == 0);
            expect_true(b.getBitsets().size() == 1);
            expect_true(b.getBitsets()[0].size() == 256);
            expect_true(b.getBitsets()[0].getSum() == 200);
            expect_true(b.getTrailing() == 0);
            expect_true(b.at(0));
            expect_true(b.at(1));
            expect_true(b.at(100));
            expect_true(b.at(198));
            expect_true(b.at(199));
            expect_true(!b.at(200));
            expect_true(!b.at(201));
            expect_true(!b.at(255));

            for (int i = 256; i <= 320; ++i) {
                b.push_back(false);                   // set 256..320 = FALSE
            }
            expect_true(b.getTrailing() == 65);
            b.push_back(true);                   // set 321 = TRUE

            expect_true(!b.empty());
            expect_true(b.size() == 322);
            expect_true(b.getSum() == 201);
            expect_true(b.getGaps().size() == 2);
            expect_true(b.getGaps()[0] == 0);
            expect_true(b.getGaps()[1] == 1);
            expect_true(b.getBitsets().size() == 2);
            expect_true(b.getBitsets()[0].size() == 256);
            expect_true(b.getBitsets()[0].getSum() == 200);
            expect_true(b.getBitsets()[1].size() == 2);
            expect_true(b.getBitsets()[1].getSum() == 1);
            expect_true(b.getTrailing() == 0);
            expect_true(!b.getBitsets()[1].at(0));
            expect_true(b.getBitsets()[1].at(1));
            expect_true(b.at(0));
            expect_true(b.at(1));
            expect_true(b.at(100));
            expect_true(b.at(198));
            expect_true(b.at(199));
            expect_true(!b.at(200));
            expect_true(!b.at(201));
            expect_true(!b.at(255));
            expect_true(!b.at(256));
            expect_true(!b.at(318));
            expect_true(!b.at(319));
            expect_true(!b.at(320));
            expect_true(b.at(321));
        }
    }

    test_that("conjunctWith - empty both chains") {
        SparseBitChain b1, b2;

        expect_true(b1.size() == 0);
        expect_true(b2.size() == 0);
        b1.conjunctWith(b2);
        expect_true(b1.size() == 0);
        expect_true(b2.size() == 0);
    }

    test_that("conjunctWith - 1 chain empty") {
        for (size_t n = 31; n <= 33; n++) {
            SparseBitChain b1, b2;

            b1.push_back(true, n);
            b2.push_back(false, n);
            expect_true(b1.size() == n);
            expect_true(b2.size() == n);

            b1.conjunctWith(b2);

            expect_true(b1.size() == n);
            expect_true(b2.size() == n);

            for (size_t i = 0; i < n; i++) {
                expect_true(!b1.at(i));
            }
        }
    }

    test_that("conjunctWith - chains full") {
        for (size_t n = 31; n <= 33; n++) {
            SparseBitChain b1, b2;

            b1.push_back(true, n);
            b2.push_back(true, n);
            expect_true(b1.size() == n);
            expect_true(b2.size() == n);

            b1.conjunctWith(b2);
            expect_true(b1.size() == n);
            expect_true(b2.size() == n);

            for (size_t i = 0; i < n; i++) {
                expect_true(b1.at(i));
            }
        }
    }

    test_that("conjunctWith - complex") {
        SparseBitChain b1, b2;

        b1.push_back(false, 64);
        b1.push_back(false, 3); b1.push_back(true, 4); b1.push_back(false, 57);
        b1.push_back(false, 64);
        b1.push_back(false, 5);

        b2.push_back(false, 64);
        b2.push_back(false, 2);  b2.push_back(true, 22); b2.push_back(false, 40);
        b2.push_back(false, 60); b2.push_back(true, 2); b2.push_back(false, 2);
        b2.push_back(true, 5);

        expect_true(b1.size() == 3*64 + 5);
        expect_true(b1.getSum() == 4);
        expect_true(b2.size() == 3*64 + 5);
        expect_true(b2.getSum() == 29);

        b1.conjunctWith(b2);

        expect_true(b1.size() == 3*64 + 5);
        expect_true(b1.getSum() == 4);

        for (size_t i = 0; i < 64 + 3; i++) {
            expect_true(!b1.at(i));
        }
        expect_true(b1.at(67));
        expect_true(b1.at(68));
        expect_true(b1.at(69));
        expect_true(b1.at(70));
        for (size_t i = 64 + 3 + 4; i < b1.size(); i++) {
            expect_true(!b1.at(i));
        }
    }

    test_that("conjunctWith - complex 2") {
        SparseBitChain b1, b2;

        b1.push_back(true, 128); b1.push_back(false, 128);
        b1.push_back(true, 128); b1.push_back(false, 128);
        b1.push_back(false, 128); b1.push_back(false, 128);
        b1.push_back(true, 128); b1.push_back(false, 128);
        b1.push_back(true, 128); b1.push_back(false, 128);

        b2.push_back(false, 128 * 5);
        b2.push_back(true, 128 * 5);

        expect_true(b1.size() == 1280);
        expect_true(b1.getSum() == 4 * 128);
        expect_true(b2.size() == 1280);
        expect_true(b2.getSum() == 5 * 128);

        if (Bitset::CHUNK_SIZE == 64) {
            expect_true(b1.getGaps().size() == 4);
            expect_true(b1.getGaps()[0] == 0);
            expect_true(b1.getGaps()[1] == 2);
            expect_true(b1.getGaps()[2] == 6);
            expect_true(b1.getGaps()[3] == 2);

            expect_true(b2.getGaps().size() == 1);
            expect_true(b2.getGaps()[0] == 10);
        }

        b1.conjunctWith(b2);

        expect_true(b1.size() == 1280);
        expect_true(b1.getSum() == 2 * 128);

        for (size_t i = 0; i < 128 * 6; i++) {
            expect_true(!b1.at(i));
        }
        for (size_t i = 128 * 6; i < 128 * 7; i++) {
            expect_true(b1.at(i));
        }
        for (size_t i = 128 * 7; i < 128 * 8; i++) {
            expect_true(!b1.at(i));
        }
        for (size_t i = 128 * 8; i < 128 * 9; i++) {
            expect_true(b1.at(i));
        }
        for (size_t i = 128 * 9; i < b1.size(); i++) {
            expect_true(!b1.at(i));
        }

        // packing of gaps
        if (Bitset::CHUNK_SIZE == 64) {
            //expect_true(b1.getGaps().size() == 1);
            //expect_true(b1.getGaps()[0] == 12);
        }
    }
}
