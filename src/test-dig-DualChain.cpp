#include <testthat.h>
#include "common.h"
#include "dig/DualChain.h"
#include "dig/BitChain.h"
#include "dig/VectorNumChain.h"

using DualChainTestType = DualChain<BitChain, VectorNumChain<GOGUEN>>;


context("dig/DualChain.h") {
    test_that("empty chain") {
        DualChainTestType chain;
        expect_true(chain.empty());
        expect_true(chain.size() == 0);
    }

    test_that("bit chain") {
        LogicalVector data(10);
        for (int i = 0; i < data.size(); i++) {
            data[i] = (i == 2 || i == 5);
        }
        DualChainTestType chain(data);

        expect_true(!chain.empty());
        expect_true(chain.isBitwise());
        expect_true(!chain.isNumeric());
        expect_true(chain.size() == 10);
        expect_true(EQUAL(chain.getSum(), 2.0));
        expect_true(EQUAL(chain.getSupport(), 0.2));
        expect_true(chain.getValue(2));
        expect_true(!chain.getValue(3));

        chain.negate();

        expect_true(!chain.empty());
        expect_true(chain.isBitwise());
        expect_true(!chain.isNumeric());
        expect_true(chain.size() == 10);
        expect_true(EQUAL(chain.getSum(), 8.0));
        expect_true(EQUAL(chain.getSupport(), 0.8));
        expect_true(!chain.getValue(2));
        expect_true(chain.getValue(3));
    }

    test_that("numeric chain") {
        NumericVector data(10);
        for(size_t i = 0; i < 10; i++) {
            data[i] = i / 10.0;
        }
        DualChainTestType chain(data);

        expect_true(!chain.empty());
        expect_true(!chain.isBitwise());
        expect_true(chain.isNumeric());
        expect_true(chain.size() == 10);
        expect_true(EQUAL(chain.getSum(), 4.5));
        expect_true(EQUAL(chain.getSupport(), 0.45));
        expect_true(EQUAL(chain.getValue(1), 0.1));
        expect_true(EQUAL(chain.getValue(9), 0.9));

        chain.negate();

        expect_true(!chain.empty());
        expect_true(!chain.isBitwise());
        expect_true(chain.isNumeric());
        expect_true(chain.size() == 10);
        expect_true(EQUAL(chain.getSum(), 4.5));
        expect_true(EQUAL(chain.getSupport(), 0.45));
        expect_true(EQUAL(chain.getValue(1), 0.9));
        expect_true(EQUAL(chain.getValue(9), 0.1));
    }

    test_that("toNumeric") {
        LogicalVector data(10);
        for (int i = 0; i < data.size(); i++) {
            data[i] = (i == 2 || i == 5);
        }
        DualChainTestType chain(data);

        chain.toNumeric();

        expect_true(!chain.empty());
        expect_true(chain.isBitwise());
        expect_true(chain.isNumeric());
        expect_true(chain.size() == 10);
        expect_true(EQUAL(chain.getSum(), 2.0));
        expect_true(EQUAL(chain.getValue(1), 0));
        expect_true(EQUAL(chain.getValue(2), 1));

        chain.negate();

        expect_true(!chain.empty());
        expect_true(chain.isBitwise());
        expect_true(chain.isNumeric());
        expect_true(chain.size() == 10);
        expect_true(EQUAL(chain.getSum(), 8.0));
        expect_true(EQUAL(chain.getValue(1), 1));
        expect_true(EQUAL(chain.getValue(2), 0));
    }

    test_that("combine bit & bit") {
        LogicalVector data1(10);
        LogicalVector data2(10);
        for (int i = 0; i < data1.size(); i++) {
            data1[i] = (i == 2 || i == 5);
            data2[i] = (i == 2 || i == 8);
        }
        DualChainTestType chain1(data1);
        DualChainTestType chain2(data2);

        chain1.conjunctWith(chain1);
        expect_true(!chain1.empty());
        expect_true(chain1.isBitwise());
        expect_true(!chain1.isNumeric());
        expect_true(chain1.size() == 10);
        expect_true(EQUAL(chain1.getSum(), 2.0));

        chain2.conjunctWith(chain1);
        expect_true(!chain2.empty());
        expect_true(chain2.isBitwise());
        expect_true(!chain2.isNumeric());
        expect_true(chain2.size() == 10);
        expect_true(EQUAL(chain2.getSum(), 1.0));
    }

    test_that("combine num & num") {
        NumericVector data(10);
        for(size_t i = 0; i < 10; i++) {
            data[i] = i / 10.0;
        }
        DualChainTestType chain1(data);
        DualChainTestType chain2(data);

        chain2.conjunctWith(chain1);
        expect_true(!chain2.empty());
        expect_true(!chain2.isBitwise());
        expect_true(chain2.isNumeric());
        expect_true(chain2.size() == 10);
        expect_true(EQUAL(chain2.getSum(), 2.85));
    }

    test_that("combine incompatible") {
        LogicalVector data1(10);
        NumericVector data2(10);
        DualChainTestType chain1(data1);
        DualChainTestType chain2(data2);

        expect_error(chain2.conjunctWith(chain1));
    }

    test_that("combine both & num") {
        NumericVector data1(10);
        LogicalVector data2(10);
        for (int i = 0; i < data1.size(); i++) {
            data1[i] = i / 10.0;
            data2[i] = (i == 2 || i == 5);
        }
        DualChainTestType chain1(data1);
        DualChainTestType chain2(data2);

        chain2.toNumeric();
        expect_true(chain2.isBitwise());
        expect_true(chain2.isNumeric());

        chain2.conjunctWith(chain1);
        expect_true(!chain2.empty());
        expect_true(!chain2.isBitwise());
        expect_true(chain2.isNumeric());
        expect_true(chain2.size() == 10);
        expect_true(EQUAL(chain2.getSum(), 0.7));
    }

    test_that("combine both & bit") {
        LogicalVector data1(10);
        LogicalVector data2(10);
        for (int i = 0; i < data1.size(); i++) {
            data1[i] = (i == 2 || i == 5);
            data2[i] = (i == 2 || i == 8);
        }
        DualChainTestType chain1(data1);
        DualChainTestType chain2(data2);

        chain2.toNumeric();
        expect_true(chain2.isBitwise());
        expect_true(chain2.isNumeric());

        chain2.conjunctWith(chain1);
        expect_true(!chain2.empty());
        expect_true(chain2.isBitwise());
        expect_true(!chain2.isNumeric());
        expect_true(chain2.size() == 10);
        expect_true(EQUAL(chain2.getSum(), 1.0));
    }

    test_that("combine both & both") {
        LogicalVector data1(10);
        LogicalVector data2(10);
        for (int i = 0; i < data1.size(); i++) {
            data1[i] = (i == 2 || i == 5);
            data2[i] = (i == 2 || i == 8);
        }
        DualChainTestType chain1(data1);
        DualChainTestType chain2(data2);

        chain1.toNumeric();
        chain2.toNumeric();
        expect_true(chain1.isBitwise());
        expect_true(chain1.isNumeric());
        expect_true(chain2.isBitwise());
        expect_true(chain2.isNumeric());

        chain2.conjunctWith(chain1);
        expect_true(!chain2.empty());
        expect_true(chain2.isBitwise());
        expect_true(!chain2.isNumeric());
        expect_true(chain2.size() == 10);
        expect_true(EQUAL(chain2.getSum(), 1.0));
    }
}
