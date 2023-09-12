#include <testthat.h>
#include <cpp11.hpp>
#include <boost/dynamic_bitset.hpp>
#include "Chain.h"

using namespace cpp11;
using namespace std;


context("Chain.h") {
    test_that("empty chain") {
        Chain chain;
        expect_true(chain.empty());
        expect_true(chain.size() == 0);
    }

    test_that("bit chain") {
        writable::logicals data(10);
        for (int i = 0; i < data.size(); i++) {
            data[i] = (i == 2 || i == 5);
        }
        Chain chain(data);

        expect_true(!chain.empty());
        expect_true(chain.isBitwise());
        expect_true(!chain.isNumeric());
        expect_true(chain.size() == 10);
        expect_true(chain.getSum() == 2.0);
        expect_true(chain.getSupport() == 0.2);
    }

    test_that("numeric chain") {
        writable::doubles data(10);
        for(size_t i = 0; i < 10; i++) {
            data[i] = i / 10.0;
        }
        Chain chain(data);

        expect_true(!chain.empty());
        expect_true(!chain.isBitwise());
        expect_true(chain.isNumeric());
        expect_true(chain.size() == 10);
        expect_true(chain.getSum() == 4.5);
        expect_true(chain.getSupport() == 0.45);
    }

    test_that("toNumeric") {
        writable::logicals data(10);
        for (int i = 0; i < data.size(); i++) {
            data[i] = (i == 2 || i == 5);
        }
        Chain chain(data);

        chain.toNumeric();
        expect_true(!chain.empty());
        expect_true(chain.isBitwise());
        expect_true(chain.isNumeric());
        expect_true(chain.size() == 10);
        expect_true(chain.getSum() == 2.0);
    }

    test_that("combine bit & bit") {
        writable::logicals data1(10);
        writable::logicals data2(10);
        for (int i = 0; i < data1.size(); i++) {
            data1[i] = (i == 2 || i == 5);
            data2[i] = (i == 2 || i == 8);
        }
        Chain chain1(data1);
        Chain chain2(data2);

        chain1.combineWith(chain1);
        expect_true(!chain1.empty());
        expect_true(chain1.isBitwise());
        expect_true(!chain1.isNumeric());
        expect_true(chain1.size() == 10);
        expect_true(chain1.getSum() == 2.0);

        chain2.combineWith(chain1);
        expect_true(!chain2.empty());
        expect_true(chain2.isBitwise());
        expect_true(!chain2.isNumeric());
        expect_true(chain2.size() == 10);
        expect_true(chain2.getSum() == 1.0);
    }

    test_that("combine num & num") {
        writable::doubles data(10);
        for(size_t i = 0; i < 10; i++) {
            data[i] = i / 10.0;
        }
        Chain chain1(data);
        Chain chain2(data);

        chain2.combineWith(chain1);
        expect_true(!chain2.empty());
        expect_true(!chain2.isBitwise());
        expect_true(chain2.isNumeric());
        expect_true(chain2.size() == 10);
        expect_true(chain2.getSum() == 2.85);
    }

    test_that("combine incompatible") {
        writable::logicals data1(10);
        writable::doubles data2(10);
        Chain chain1(data1);
        Chain chain2(data2);

        expect_error(chain2.combineWith(chain1));
    }

    test_that("combine both & num") {
        writable::doubles data1(10);
        writable::logicals data2(10);
        for (int i = 0; i < data1.size(); i++) {
            data1[i] = i / 10.0;
            data2[i] = (i == 2 || i == 5);
        }
        Chain chain1(data1);
        Chain chain2(data2);

        chain2.toNumeric();
        expect_true(chain2.isBitwise());
        expect_true(chain2.isNumeric());

        chain2.combineWith(chain1);
        expect_true(!chain2.empty());
        expect_true(!chain2.isBitwise());
        expect_true(chain2.isNumeric());
        expect_true(chain2.size() == 10);
        expect_true(chain2.getSum() == 0.7);
    }

    test_that("combine both & bit") {
        writable::logicals data1(10);
        writable::logicals data2(10);
        for (int i = 0; i < data1.size(); i++) {
            data1[i] = (i == 2 || i == 5);
            data2[i] = (i == 2 || i == 8);
        }
        Chain chain1(data1);
        Chain chain2(data2);

        chain2.toNumeric();
        expect_true(chain2.isBitwise());
        expect_true(chain2.isNumeric());

        chain2.combineWith(chain1);
        expect_true(!chain2.empty());
        expect_true(chain2.isBitwise());
        expect_true(!chain2.isNumeric());
        expect_true(chain2.size() == 10);
        expect_true(chain2.getSum() == 1.0);
    }

    test_that("combine both & both") {
        writable::logicals data1(10);
        writable::logicals data2(10);
        for (int i = 0; i < data1.size(); i++) {
            data1[i] = (i == 2 || i == 5);
            data2[i] = (i == 2 || i == 8);
        }
        Chain chain1(data1);
        Chain chain2(data2);

        chain1.toNumeric();
        chain2.toNumeric();
        expect_true(chain1.isBitwise());
        expect_true(chain1.isNumeric());
        expect_true(chain2.isBitwise());
        expect_true(chain2.isNumeric());

        chain2.combineWith(chain1);
        expect_true(!chain2.empty());
        expect_true(chain2.isBitwise());
        expect_true(!chain2.isNumeric());
        expect_true(chain2.size() == 10);
        expect_true(chain2.getSum() == 1.0);
    }
}
