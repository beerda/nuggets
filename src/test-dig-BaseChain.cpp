#include <testthat.h>
#include "common.h"
#include "dig/BaseChain.h"


context("dig/BaseChain.h") {
    test_that("default constructor") {
        BaseChain c(0.3f);

        IF_DEBUG(
            expect_true(false);
        )

        expect_true(c.getClause().empty());
        expect_true(c.getPredicateType() == CONDITION);
        expect_true(c.getSum() == 0.3f);
        expect_true(c.isCondition());
        expect_true(!c.isFocus());
    }

    test_that("constructor with id and type") {
        BaseChain c(5, FOCUS, 1.2f);

        expect_true(c.getClause().size() == 1);
        expect_true(c.getClause()[0] == 5);
        expect_true(c.getPredicateType() == FOCUS);
        expect_true(c.getSum() == 1.2f);
        expect_true(!c.isCondition());
        expect_true(c.isFocus());
    }

    test_that("constructor with conjunction 1") {
        BaseChain a(2, CONDITION, 0.5f);
        BaseChain b(3, BOTH, 0.8f);

        BaseChain c(a, b, true);

        expect_true(c.getClause().size() == 2);
        expect_true(c.getClause()[0] == 2);
        expect_true(c.getClause()[1] == 3);
        expect_true(c.getPredicateType() == FOCUS);
        expect_true(c.getSum() == 0.0f);
        expect_true(!c.isCondition());
        expect_true(c.isFocus());

        BaseChain d(a, b, false);

        expect_true(d.getClause().size() == 2);
        expect_true(d.getClause()[0] == 2);
        expect_true(d.getClause()[1] == 3);
        expect_true(d.getPredicateType() == BOTH);
        expect_true(d.getSum() == 0.0f);
        expect_true(d.isCondition());
        expect_true(d.isFocus());
    }
}
