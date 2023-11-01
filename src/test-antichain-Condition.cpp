#include <testthat.h>
#include "common.h"
#include "antichain/Condition.h"

context("antichain/Condition.h") {
    test_that("condition") {
        Condition c({1, 2, 5});

        expect_true(c.length() == 3);
        expect_true(c.hasPredicate(1));
        expect_true(c.hasPredicate(2));
        expect_true(c.hasPredicate(5));
        expect_true(c.getPredicates() == unordered_set<int>({1, 2, 5}));
    }
}
