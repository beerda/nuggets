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

    test_that("conjunctWith - empty chains") {
        SparseBitChain b1, b2;

        expect_true(b1.size() == 0);
        expect_true(b2.size() == 0);
        b1.conjunctWith(b2);
        expect_true(b1.size() == 0);
        expect_true(b2.size() == 0);
    }

    test_that("conjunctWith - 1 chain empty") {
        SparseBitChain b1, b2;

        expect_true(b1.size() == 0);
        expect_true(b2.size() == 0);
        b1.conjunctWith(b2);
        expect_true(b1.size() == 0);
        expect_true(b2.size() == 0);
    }

    test_that("conjunctWith - ") {
        SparseBitChain b1, b2;

        b1.push_back(false, 64);
        b1.push_back(true, 4); b1.push_back(false, 60);
        b1.push_back(false, 64);

        b2.push_back(false, 64);
        b2.push_back(false, 64);
        b2.push_back(false, 60); b2.push_back(true, 2); b2.push_back(false, 2);

        expect_true(b1.size() == 3*64);
        expect_true(b2.size() == 3*64);

        b1.conjunctWith(b2);
        expect_true(b1.size() == 3*64);
    }
}
