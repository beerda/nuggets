#include <testthat.h>
#include "common.h"
#include "dig/BitsetBitChain.h"

context("dig/BitsetBitChain.h") {
    test_that("push_back") {
        BitsetBitChain b;

        expect_true(b.empty());
        expect_true(b.size() == 0);
        expect_true(b.getSum() == 0);
    }
}
