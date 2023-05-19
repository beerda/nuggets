#include <testthat.h>
#include <cpp11.hpp>
#include <boost/dynamic_bitset.hpp>
#include "Chain.hpp"

using namespace cpp11;
using namespace std;


context("Chain.hpp") {
    writable::logicals bdata(10);
    for (int i = 0; i < 10; i++) {
        bdata[i] = false;
    }
    bdata[2] = true;
    bdata[5] = true;
    Chain bch(bdata); // 2, 5

    bdata[5] = false;
    bdata[8] = true;
    Chain bch2(bdata); // 2, 8

    writable::doubles ndata(10);
    for(size_t i = 0; i < 10; i++) {
        ndata[i] = i / 10.0;
    }
    Chain nch(ndata);

    test_that("bit Chain") {
        expect_true(bch.isBitwise());
        expect_true(bch.size() == 10);
        expect_true(bch.sum() == 2.0);
    }

    test_that("numeric Chain") {
        expect_false(nch.isBitwise());
        expect_true(nch.size() == 10);
        expect_true(nch.sum() == 4.5);
    }

    test_that("combineWith") {
        Chain result = bch;
        result.combineWith(bch);
        expect_true(result.isBitwise());
        expect_true(result.size() == 10);
        expect_true(result.sum() == 2.0);

        result = bch;
        result.combineWith(bch2);
        expect_true(result.isBitwise());
        expect_true(result.size() == 10);
        expect_true(result.sum() == 1.0);

        result = nch;
        result.combineWith(nch);
        expect_false(result.isBitwise());
        expect_true(result.size() == 10);
        expect_true(result.sum() == 2.85);

        result = bch;
        expect_error(result.combineWith(nch));
    }

    test_that("toNumeric") {
        Chain result = bch;
        expect_true(result.isBitwise());
        expect_true(result.size() == 10);
        expect_true(result.sum() == 2.0);

        result.toNumeric();
        expect_false(result.isBitwise());
        expect_true(result.size() == 10);
        expect_true(result.sum() == 2.0);
    }
}
