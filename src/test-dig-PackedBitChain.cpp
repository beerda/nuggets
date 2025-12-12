#include <testthat.h>
#include "common.h"
#include "dig/PackedBitChain.h"

context("dig/PackedBitChain.h") {
    test_that("initialize from LogicalVector (empty)") {
        LogicalVector v(0);

        PackedBitChain b(1, PredicateType::CONDITION, v);

        expect_true(b.getClause().size() == 1);
        expect_true(b.getClause()[0] == 1);
        expect_true(b.empty());
        expect_true(b.size() == 0);
        expect_true(b.getSum() == 0);
        expect_true(b.isCondition());
        expect_true(!b.isFocus());
        expect_true(b.toString() == "[n=0]");
        expect_true(b.raw().size() == 0);
    }

    test_that("initialize from LogicalVector (starting with TRUE)") {
        LogicalVector v(6);
        v[0] = true;
        v[1] = false;
        v[2] = false;
        v[3] = true;
        v[4] = true;
        v[5] = false;

        PackedBitChain b(3, PredicateType::FOCUS, v);

        expect_true(b.getClause().size() == 1);
        expect_true(b.getClause()[0] == 3);
        expect_true(!b.empty());
        expect_true(b.size() == 6);
        expect_true(b.getSum() == 3);
        expect_true(!b.isCondition());
        expect_true(b.isFocus());
        expect_true(b.at(0));
        expect_true(!b.at(1));
        expect_true(!b.at(2));
        expect_true(b.at(3));
        expect_true(b.at(4));
        expect_true(!b.at(5));
        expect_true(b.toString() == "[n=6]100110");
        expect_true(b.raw().size() == 5);
        expect_true(b.raw()[0] == 0);
        expect_true(b.raw()[1] == 1);
        expect_true(b.raw()[2] == 2);
        expect_true(b.raw()[3] == 2);
        expect_true(b.raw()[4] == 1);
    }

    test_that("initialize by conjunction (empty)") {
        LogicalVector la(0);
        LogicalVector lb(0);

        PackedBitChain a(10, PredicateType::BOTH, la);
        PackedBitChain b(20, PredicateType::BOTH, lb);

        PackedBitChain c(b, a, false);
        expect_true(c.getClause().size() == 2);
        expect_true(c.getClause()[0] == 20);
        expect_true(c.getClause()[1] == 10);
        expect_true(c.empty());
        expect_true(c.size() == 0);
        expect_true(c.getSum() == 0);
        expect_true(c.isCondition());
        expect_true(c.isFocus());
        expect_true(c.toString() == "[n=0]");
    }

    test_that("initialize by conjunction (start the same)") {
        LogicalVector la(6);
        la[0] = false;
        la[1] = false;
        la[2] = true;
        la[3] = true;
        la[4] = true;
        la[5] = false;

        LogicalVector lb(6);
        lb[0] = false;
        lb[1] = true;
        lb[2] = true;
        lb[3] = true;
        lb[4] = false;
        lb[5] = false;

        {
            PackedBitChain a(10, PredicateType::BOTH, la);
            PackedBitChain b(20, PredicateType::BOTH, lb);

            PackedBitChain c(b, a, false);
            expect_true(c.getSum() == 2);
            expect_true(c.toString() == "[n=6]001100");
        }
        {
            PackedBitChain a(10, PredicateType::BOTH, la);
            PackedBitChain b(20, PredicateType::BOTH, lb);

            PackedBitChain c(a, b, false);
            expect_true(c.getSum() == 2);
            expect_true(c.toString() == "[n=6]001100");
        }
    }

    test_that("initialize by conjunction (start different)") {
        LogicalVector la(6);
        la[0] = true;
        la[1] = false;
        la[2] = true;
        la[3] = true;
        la[4] = false;
        la[5] = true;

        LogicalVector lb(6);
        lb[0] = false;
        lb[1] = true;
        lb[2] = true;
        lb[3] = true;
        lb[4] = false;
        lb[5] = true;

        {
            PackedBitChain a(10, PredicateType::BOTH, la);
            PackedBitChain b(20, PredicateType::BOTH, lb);

            PackedBitChain c(b, a, false);
            expect_true(c.getSum() == 3);
            expect_true(c.toString() == "[n=6]001101");
        }
        {
            PackedBitChain a(10, PredicateType::BOTH, la);
            PackedBitChain b(20, PredicateType::BOTH, lb);

            PackedBitChain c(a, b, false);
            expect_true(c.getSum() == 3);
            expect_true(c.toString() == "[n=6]001101");
        }
    }

    test_that("initialize by conjunction (long const)") {
        LogicalVector la(6);
        la[0] = true;
        la[1] = true;
        la[2] = true;
        la[3] = true;
        la[4] = true;
        la[5] = true;

        LogicalVector lb(6);
        lb[0] = false;
        lb[1] = true;
        lb[2] = true;
        lb[3] = false;
        lb[4] = true;
        lb[5] = false;

        {
            PackedBitChain a(10, PredicateType::BOTH, la);
            PackedBitChain b(20, PredicateType::BOTH, lb);

            PackedBitChain c(b, a, false);
            expect_true(c.getSum() == 3);
            expect_true(c.toString() == "[n=6]011010");
        }
        {
            PackedBitChain a(10, PredicateType::BOTH, la);
            PackedBitChain b(20, PredicateType::BOTH, lb);

            PackedBitChain c(a, b, false);
            expect_true(c.getSum() == 3);
            expect_true(c.toString() == "[n=6]011010");
        }
    }

    test_that("initialize by conjunction (complex)") {
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
            PackedBitChain a1(10, PredicateType::BOTH, la);
            PackedBitChain a2(11, PredicateType::BOTH, la);
            PackedBitChain b(20, PredicateType::BOTH, lb);

            PackedBitChain c1(b, a1, false);
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

            PackedBitChain c2(b, a2, false);
            expect_true(c2.getClause().size() == 2);
            expect_true(c2.getClause()[0] == 20);
            expect_true(c2.getClause()[1] == 11);
            expect_true(c2.getSum() == 1);
            expect_true(c2.toString() == "[n=5]00100");

            PackedBitChain d(c1, c2, false);
            expect_true(d.getClause().size() == 3);
            expect_true(d.getClause()[0] == 20);
            expect_true(d.getClause()[1] == 10);
            expect_true(d.getClause()[2] == 11);
            expect_true(d.getSum() == 1);
            expect_true(d.toString() == "[n=5]00100");
        }
        {
            PackedBitChain a(10, PredicateType::BOTH, la);
            PackedBitChain b(20, PredicateType::CONDITION, lb);
            PackedBitChain c(a, b, false);
            expect_true(c.isCondition());
            expect_true(!c.isFocus());
            expect_true(c.toString() == "[n=5]00100");
        }
        {
            PackedBitChain a(10, PredicateType::BOTH, la);
            PackedBitChain b(20, PredicateType::FOCUS, lb);
            PackedBitChain c(a, b, false);
            expect_true(!c.isCondition());
            expect_true(c.isFocus());
            expect_true(c.toString() == "[n=5]00100");
        }
    }
}
