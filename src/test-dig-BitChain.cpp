#include <testthat.h>
#include "common.h"
#include "dig/BitChain.h"

context("dig/BitChain.h") {
    test_that("create nonempty") {
        BitChain b(200);

        expect_false(b.empty());
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
    }
}
