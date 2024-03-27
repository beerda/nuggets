#include <testthat.h>
#include "common.h"
#include "dig/BitChain.h"

context("dig/BitChain.h") {
    test_that("push_back") {
        BitChain b;

        expect_true(b.empty());
        expect_true(b.size() == 0);
        expect_true(b.getSum() == 0);
    }
}
