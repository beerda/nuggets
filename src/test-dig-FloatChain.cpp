#include <testthat.h>
#include "common.h"
#include "dig/FloatChain.h"

context("dig/FloatChain.h") {
    test_that("initialize from LogicalVector") {
        LogicalVector v(5);
        v[0] = true;
        v[1] = false;
        v[2] = true;
        v[3] = true;
        v[4] = false;

        FloatChain<TNorm::GOGUEN> b(3, PredicateType::FOCUS, v);

        expect_true(b.getClause().size() == 1);
        expect_true(b.getClause()[0] == 3);
        expect_true(!b.empty());
        expect_true(b.size() == 5);
        expect_true(EQUAL(b.getSum(), 3));
        expect_true(!b.isCondition());
        expect_true(b.isFocus());
        expect_true(EQUAL(b.at(0), 1.0));
        expect_true(EQUAL(b.at(1), 0.0));
        expect_true(EQUAL(b.at(2), 1.0));
        expect_true(EQUAL(b.at(3), 1.0));
        expect_true(EQUAL(b.at(4), 0.0));
    }

    test_that("initialize from NumericVector") {
        NumericVector v(5);
        v[0] = 0.8;
        v[1] = 0.3;
        v[2] = 1.0;
        v[3] = 0.0;
        v[4] = 0.2;

        FloatChain<TNorm::GOGUEN> b(3, PredicateType::FOCUS, v);

        expect_true(b.getClause().size() == 1);
        expect_true(b.getClause()[0] == 3);
        expect_true(!b.empty());
        expect_true(b.size() == 5);
        expect_true(EQUAL(b.getSum(), 2.3));
        expect_true(!b.isCondition());
        expect_true(b.isFocus());
        expect_true(EQUAL(b.at(0), 0.8));
        expect_true(EQUAL(b.at(1), 0.3));
        expect_true(EQUAL(b.at(2), 1.0));
        expect_true(EQUAL(b.at(3), 0.0));
        expect_true(EQUAL(b.at(4), 0.2));
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
            FloatChain<TNorm::GOGUEN> a1(10, PredicateType::BOTH, la);
            FloatChain<TNorm::GOGUEN> a2(11, PredicateType::BOTH, la);
            FloatChain<TNorm::GOGUEN> b(20, PredicateType::BOTH, lb);

            FloatChain<TNorm::GOGUEN> c1(b, a1);
            expect_true(c1.getClause().size() == 2);
            expect_true(c1.getClause()[0] == 20);
            expect_true(c1.getClause()[1] == 10);
            expect_true(!c1.empty());
            expect_true(c1.size() == 5);
            expect_true(c1.getSum() == 1);
            expect_true(c1.isCondition());
            expect_true(c1.isFocus());
            expect_true(!c1.isCached());
            expect_true(c1.at(0) == 0.0);
            expect_true(c1.at(1) == 0.0);
            expect_true(c1.at(2) == 1.0);
            expect_true(c1.at(3) == 0.0);
            expect_true(c1.at(4) == 0.0);

            FloatChain<TNorm::GOGUEN> c2(b, a2);
            expect_true(c2.getClause().size() == 2);
            expect_true(c2.getClause()[0] == 20);
            expect_true(c2.getClause()[1] == 11);
            expect_true(c2.getSum() == 1);
            expect_true(!c2.isCached());

            FloatChain<TNorm::GOGUEN> d(c1, c2);
            expect_true(d.getClause().size() == 3);
            expect_true(d.getClause()[0] == 20);
            expect_true(d.getClause()[1] == 10);
            expect_true(d.getClause()[2] == 11);
            expect_true(d.getSum() == 1);
            expect_true(!d.isCached());
        }
        {
            FloatChain<TNorm::GOGUEN> a(10, PredicateType::BOTH, la);
            FloatChain<TNorm::GOGUEN> b(20, PredicateType::CONDITION, lb);
            FloatChain<TNorm::GOGUEN> c(a, b);
            expect_true(c.isCondition());
            expect_true(!c.isFocus());
            expect_true(!c.isCached());
        }
        {
            FloatChain<TNorm::GOGUEN> a(10, PredicateType::BOTH, la);
            FloatChain<TNorm::GOGUEN> b(20, PredicateType::FOCUS, lb);
            FloatChain<TNorm::GOGUEN> c(a, b);
            expect_true(!c.isCondition());
            expect_true(c.isFocus());
            expect_true(!c.isCached());
        }
    }

    test_that("test goedel") {
        NumericVector v(5);
        v[0] = 0.8;
        v[1] = 0.3;
        v[2] = 1.0;
        v[3] = 0.0;
        v[4] = 0.2;

        NumericVector w(5);
        w[0] = 0.9;
        w[1] = 0.8;
        w[2] = 0.5;
        w[3] = 0.9;
        w[4] = 0.0;

        FloatChain<TNorm::GOEDEL> a(3, PredicateType::BOTH, v);
        FloatChain<TNorm::GOEDEL> b(4, PredicateType::BOTH, w);
        FloatChain<TNorm::GOEDEL> c(a, b);

        expect_true(EQUAL(c.at(0), 0.8));
        expect_true(EQUAL(c.at(1), 0.3));
        expect_true(EQUAL(c.at(2), 0.5));
        expect_true(EQUAL(c.at(3), 0.0));
        expect_true(EQUAL(c.at(4), 0.0));
        expect_true(EQUAL(c.getSum(), 1.6));
    }

    test_that("test goguen") {
        NumericVector v(5);
        v[0] = 0.8;
        v[1] = 0.3;
        v[2] = 1.0;
        v[3] = 0.0;
        v[4] = 0.2;

        NumericVector w(5);
        w[0] = 0.9;
        w[1] = 0.8;
        w[2] = 0.5;
        w[3] = 0.9;
        w[4] = 0.0;

        FloatChain<TNorm::GOGUEN> a(3, PredicateType::BOTH, v);
        FloatChain<TNorm::GOGUEN> b(4, PredicateType::BOTH, w);
        FloatChain<TNorm::GOGUEN> c(a, b);

        expect_true(EQUAL(c.at(0), 0.8 * 0.9));
        expect_true(EQUAL(c.at(1), 0.3 * 0.8));
        expect_true(EQUAL(c.at(2), 0.5));
        expect_true(EQUAL(c.at(3), 0.0));
        expect_true(EQUAL(c.at(4), 0.0));
        expect_true(EQUAL(c.getSum(), 0.8 * 0.9 + 0.3 * 0.8 + 0.5));
    }

    test_that("test lukasiewicz") {
        NumericVector v(5);
        v[0] = 0.8;
        v[1] = 0.3;
        v[2] = 1.0;
        v[3] = 0.0;
        v[4] = 0.2;

        NumericVector w(5);
        w[0] = 0.9;
        w[1] = 0.8;
        w[2] = 0.5;
        w[3] = 0.9;
        w[4] = 0.0;

        FloatChain<TNorm::LUKASIEWICZ> a(3, PredicateType::BOTH, v);
        FloatChain<TNorm::LUKASIEWICZ> b(4, PredicateType::BOTH, w);
        FloatChain<TNorm::LUKASIEWICZ> c(a, b);

        expect_true(EQUAL(c.at(0), 0.7));
        expect_true(EQUAL(c.at(1), 0.1));
        expect_true(EQUAL(c.at(2), 0.5));
        expect_true(EQUAL(c.at(3), 0.0));
        expect_true(EQUAL(c.at(4), 0.0));
        expect_true(EQUAL(c.getSum(), 0.7 + 0.1 + 0.5));
    }
}
