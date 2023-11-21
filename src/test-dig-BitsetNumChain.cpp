#include <testthat.h>
#include <iostream>
#include "common.h"
#include "dig/BitsetNumChain.h"

#define EXPECTED_DATA_SIZE(x) ((x-1) * BitsetNumChain<GOEDEL>::ACCURACY / BitsetNumChain<GOEDEL>::CHUNK_SIZE + 2)


context("dig/BitsetNumChain.h") {
    test_that("push_back & sum") {
        BitsetNumChain<GOEDEL> b;

        expect_true(b.empty());
        expect_true(b.size() == 0);
        expect_true(b.getSum() == 0);
        expect_true(b.getMutableData().size() == 1);
        expect_true(b.getMutableData().back() == 0UL);

        b.push_back(0.5);
        expect_true(!b.empty());
        expect_true(b.size() == 1);
        expect_true(abs(b.at(0) - 0.496063) < 1e-6);
        expect_true(abs(b.getSum() - 0.496063) < 1e-6);
        expect_true(b.getMutableData().size() == 2);

        b.push_back(0.1);
        expect_true(!b.empty());
        expect_true(b.size() == 2);
        expect_true(abs(b.at(0) - 0.496063) < 1e-6);
        expect_true(abs(b.at(1) - 0.094488) < 1e-6);
        expect_true(abs(b.getSum() - 0.5905512) < 1e-6);
        expect_true(b.getMutableData().size() == EXPECTED_DATA_SIZE(b.size()));

        b.push_back(0.0);
        expect_true(!b.empty());
        expect_true(b.size() == 3);
        expect_true(abs(b.at(0) - 0.496063) < 1e-6);
        expect_true(abs(b.at(1) - 0.094488) < 1e-6);
        expect_true(abs(b.at(2) - 0.000000) < 1e-6);
        expect_true(abs(b.getSum() - 0.5905512) < 1e-6);
        expect_true(b.getMutableData().size() == EXPECTED_DATA_SIZE(b.size()));

        b.push_back(1.0);
        expect_true(!b.empty());
        expect_true(b.size() == 4);
        expect_true(abs(b.at(0) - 0.496063) < 1e-6);
        expect_true(abs(b.at(1) - 0.094488) < 1e-6);
        expect_true(abs(b.at(2) - 0.000000) < 1e-6);
        expect_true(abs(b.at(3) - 1.000000) < 1e-6);
        expect_true(abs(b.getSum() - 1.5905512) < 1e-6);
        expect_true(b.getMutableData().size() == EXPECTED_DATA_SIZE(b.size()));

        b.push_back(1.0);
        expect_true(!b.empty());
        expect_true(b.size() == 5);
        expect_true(abs(b.at(0) - 0.496063) < 1e-6);
        expect_true(abs(b.at(1) - 0.094488) < 1e-6);
        expect_true(abs(b.at(2) - 0.000000) < 1e-6);
        expect_true(abs(b.at(3) - 1.000000) < 1e-6);
        expect_true(abs(b.at(4) - 1.000000) < 1e-6);
        expect_true(abs(b.getSum() - 2.5905512) < 1e-6);
        expect_true(b.getMutableData().size() == EXPECTED_DATA_SIZE(b.size()));

        b.push_back(1.0);
        expect_true(!b.empty());
        expect_true(b.size() == 6);
        expect_true(abs(b.at(0) - 0.496063) < 1e-6);
        expect_true(abs(b.at(1) - 0.094488) < 1e-6);
        expect_true(abs(b.at(2) - 0.000000) < 1e-6);
        expect_true(abs(b.at(3) - 1.000000) < 1e-6);
        expect_true(abs(b.at(4) - 1.000000) < 1e-6);
        expect_true(abs(b.at(5) - 1.000000) < 1e-6);
        expect_true(abs(b.getSum() - 3.5905512) < 1e-6);
        expect_true(b.getMutableData().size() == EXPECTED_DATA_SIZE(b.size()));

        b.push_back(0.0);
        expect_true(!b.empty());
        expect_true(b.size() == 7);
        expect_true(abs(b.at(0) - 0.496063) < 1e-6);
        expect_true(abs(b.at(1) - 0.094488) < 1e-6);
        expect_true(abs(b.at(2) - 0.000000) < 1e-6);
        expect_true(abs(b.at(3) - 1.000000) < 1e-6);
        expect_true(abs(b.at(4) - 1.000000) < 1e-6);
        expect_true(abs(b.at(5) - 1.000000) < 1e-6);
        expect_true(abs(b.at(6) - 0.000000) < 1e-6);
        expect_true(abs(b.getSum() - 3.5905512) < 1e-6);
        expect_true(b.getMutableData().size() == EXPECTED_DATA_SIZE(b.size()));

        b.push_back(1.0);
        expect_true(!b.empty());
        expect_true(b.size() == 8);
        expect_true(abs(b.at(0) - 0.496063) < 1e-6);
        expect_true(abs(b.at(1) - 0.094488) < 1e-6);
        expect_true(abs(b.at(2) - 0.000000) < 1e-6);
        expect_true(abs(b.at(3) - 1.000000) < 1e-6);
        expect_true(abs(b.at(4) - 1.000000) < 1e-6);
        expect_true(abs(b.at(5) - 1.000000) < 1e-6);
        expect_true(abs(b.at(6) - 0.000000) < 1e-6);
        expect_true(abs(b.at(7) - 1.000000) < 1e-6);
        expect_true(abs(b.getSum() - 4.5905512) < 1e-6);
        expect_true(b.getMutableData().size() == EXPECTED_DATA_SIZE(b.size()));

        b.push_back(1.0);
        expect_true(!b.empty());
        expect_true(b.size() == 9);
        expect_true(abs(b.at(0) - 0.496063) < 1e-6);
        expect_true(abs(b.at(1) - 0.094488) < 1e-6);
        expect_true(abs(b.at(2) - 0.000000) < 1e-6);
        expect_true(abs(b.at(3) - 1.000000) < 1e-6);
        expect_true(abs(b.at(4) - 1.000000) < 1e-6);
        expect_true(abs(b.at(5) - 1.000000) < 1e-6);
        expect_true(abs(b.at(6) - 0.000000) < 1e-6);
        expect_true(abs(b.at(7) - 1.000000) < 1e-6);
        expect_true(abs(b.at(8) - 1.000000) < 1e-6);
        expect_true(abs(b.getSum() - 5.5905512) < 1e-6);
        expect_true(b.getMutableData().size() == EXPECTED_DATA_SIZE(b.size()));
    }

    test_that("reserve") {
        size_t inChunk = BitsetNumChain<GOEDEL>::CHUNK_SIZE / BitsetNumChain<GOEDEL>::ACCURACY;
        BitsetNumChain<GOEDEL> b;

        expect_true(b.size() == 0);
        expect_true(b.getMutableData().size() == 1);
        expect_true(b.getMutableData().capacity() == 1);

        b.reserve(inChunk * 2);
        expect_true(b.size() == 0);
        expect_true(b.getMutableData().size() == 1);
        expect_true(b.getMutableData().capacity() == 3);

        b.reserve(inChunk * 5);
        expect_true(b.size() == 0);
        expect_true(b.getMutableData().size() == 1);
        expect_true(b.getMutableData().capacity() == 6);

        b.reserve(inChunk * 5 + 1);
        expect_true(b.size() == 0);
        expect_true(b.getMutableData().size() == 1);
        expect_true(b.getMutableData().capacity() == 7);
    }

    test_that("conjunctWith<GOEDEL>") {
        BitsetNumChain<GOEDEL> a;
        BitsetNumChain<GOEDEL> b;

        for (int j = 0; j < 100; j++) {
            for (double i = 0.0; i <= 1.0; i += 0.1)
                a.push_back(i);

            for (double i = 1.0; i >= 0.0; i -= 0.1)
                b.push_back(i);
        }

        a.conjunctWith(b);

        for (int j = 0; j < 100; j++) {
            expect_true(abs(a.at(11*j + 0) - 0.000000) < 1e-6);
            expect_true(abs(a.at(11*j + 1) - 0.094488) < 1e-6);
            expect_true(abs(a.at(11*j + 2) - 0.1968504) < 1e-6);
            expect_true(abs(a.at(11*j + 3) - 0.2992126) < 1e-6);
            expect_true(abs(a.at(11*j + 4) - 0.3937008) < 1e-6);
            expect_true(abs(a.at(11*j + 5) - 0.496063) < 1e-6);
            expect_true(abs(a.at(11*j + 6) - 0.3937008) < 1e-6);
            expect_true(abs(a.at(11*j + 7) - 0.2992126) < 1e-6);
            expect_true(abs(a.at(11*j + 8) - 0.1968504) < 1e-6);
            expect_true(abs(a.at(11*j + 9) - 0.094488) < 1e-6);
            expect_true(abs(a.at(11*j + 10) - 0.000000) < 1e-6);
        }
    }

    test_that("conjunctWith<LUKASIEWICZ>") {
        BitsetNumChain<LUKASIEWICZ> a;
        BitsetNumChain<LUKASIEWICZ> b;

        for (int j = 0; j < 1; j++) {
            for (double i = 0.0; i <= 1.0; i += 0.2)
                a.push_back(i);

            for (double i = 0.0; i < 1.0; i += 0.2)
                a.push_back(0.9);

            for (double i = 1.0; i >= 0.0; i -= 0.1)
                b.push_back(i);
        }

        a.conjunctWith(b);

        for (int j = 0; j < 1; j++) {
            expect_true(abs(a.at(11*j + 0) - 0.000000) < 1e-6); // 0.0 and 1.0
            expect_true(abs(a.at(11*j + 1) - 0.094488) < 1e-6); // 0.2 and 0.9
            expect_true(abs(a.at(11*j + 2) - 0.188976) < 1e-6); // 0.4 and 0.8
            expect_true(abs(a.at(11*j + 3) - 0.291339) < 1e-6); // 0.6 and 0.7
            expect_true(abs(a.at(11*j + 4) - 0.393701) < 1e-6); // 0.8 and 0.6
            expect_true(abs(a.at(11*j + 5) - 0.496063) < 1e-6); // 1.0 and 0.5
            expect_true(abs(a.at(11*j + 6) - 0.291339) < 1e-6); // 0.9 and 0.4
            expect_true(abs(a.at(11*j + 7) - 0.196850) < 1e-6); // 0.9 and 0.3
            expect_true(abs(a.at(11*j + 8) - 0.094488) < 1e-6); // 0.9 and 0.2
            expect_true(abs(a.at(11*j + 9) - 0.000000) < 1e-6); // 0.9 and 0.1
            expect_true(abs(a.at(11*j + 10) - 0.00000) < 1e-6); // 0.9 and 0.0
        }
    }
}
