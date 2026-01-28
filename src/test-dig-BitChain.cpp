#include <testthat.h>
#include "common.h"
#include "dig/BitChain.h"

context("dig/BitChain.h") {
    test_that("initialize from LogicalVector") {
        LogicalVector v(5);
        v[0] = true;
        v[1] = false;
        v[2] = true;
        v[3] = true;
        v[4] = false;

        BitChain b(3, PredicateType::FOCUS, v);

        expect_true(b.getClause().size() == 1);
        expect_true(b.getClause()[0] == 3);
        expect_true(!b.empty());
        expect_true(b.size() == 5);
        expect_true(b.getSum() == 3);
        expect_true(!b.isCondition());
        expect_true(b.isFocus());
        expect_true(b.at(0));
        expect_true(!b.at(1));
        expect_true(b.at(2));
        expect_true(b.at(3));
        expect_true(!b.at(4));
        expect_true(b.toString() == "[n=5]10110");
    }

    test_that("initialize by conjunction") {
        LogicalVector la(5);
        la[0] = true;
        la[1] = false;
        la[2] = true;
        la[3] = true;
        la[4] = false;

        LogicalVector lb(5);
        lb[0] = false;
        lb[1] = true;
        lb[2] = true;
        lb[3] = false;
        lb[4] = true;

        {
            BitChain a1(10, PredicateType::BOTH, la);
            BitChain a2(11, PredicateType::BOTH, la);
            BitChain b(20, PredicateType::BOTH, lb);

            BitChain c1(b, a1);
            expect_true(c1.getClause().size() == 2);
            expect_true(c1.getClause()[0] == 20);
            expect_true(c1.getClause()[1] == 10);
            expect_true(!c1.empty());
            expect_true(c1.size() == 5);
            expect_true(c1.getSum() == 1);
            expect_true(c1.isCondition());
            expect_true(c1.isFocus());
            expect_true(!c1.at(0));
            expect_true(!c1.at(1));
            expect_true(c1.at(2));
            expect_true(!c1.at(3));
            expect_true(!c1.at(4));
            expect_true(c1.toString() == "[n=5]00100");

            BitChain c2(b, a2);
            expect_true(c2.getClause().size() == 2);
            expect_true(c2.getClause()[0] == 20);
            expect_true(c2.getClause()[1] == 11);
            expect_true(c2.getSum() == 1);
            expect_true(c2.toString() == "[n=5]00100");

            BitChain d(c1, c2);
            expect_true(d.getClause().size() == 3);
            expect_true(d.getClause()[0] == 20);
            expect_true(d.getClause()[1] == 10);
            expect_true(d.getClause()[2] == 11);
            expect_true(d.getSum() == 1);
            expect_true(d.toString() == "[n=5]00100");
        }
        {
            BitChain a(10, PredicateType::BOTH, la);
            BitChain b(20, PredicateType::CONDITION, lb);
            BitChain c(a, b);
            expect_true(c.isCondition());
            expect_true(!c.isFocus());
            expect_true(!c.isCached());
            expect_true(c.toString() == "[n=5]00100");
        }
        {
            BitChain a(10, PredicateType::BOTH, la);
            BitChain b(20, PredicateType::FOCUS, lb);
            BitChain c(a, b);
            expect_true(!c.isCondition());
            expect_true(c.isFocus());
            expect_true(!c.isCached());
            expect_true(c.toString() == "[n=5]00100");
        }
        {
            BitChain a(10, PredicateType::BOTH, la);
            BitChain b(20, PredicateType::BOTH, lb);
            BitChain c(a, b, 5.2f);
            expect_true(!c.isCondition());
            expect_true(c.isFocus());
            expect_true(c.isCached());
            expect_true(c.toString() == "[cached:5.2]");
        }
    }
}
