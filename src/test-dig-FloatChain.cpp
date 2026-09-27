#include <testthat.h>
#include "common.h"
#include "dig/FloatChain.h"

context("dig/FloatChain.h") {
    test_that("empty chain") {
        FloatChain<TNorm::GOGUEN>::resetWeights();
        FloatChain<TNorm::GOGUEN> b(5);

        expect_true(b.hasPredicate() == false);
        expect_true(b.empty());
        expect_true(b.size() == 0);
        expect_true(b.getSum() == 5.0);
        expect_true(b.isCondition());
        expect_true(!b.isFocus());

        LogicalVector lv = b.getValuesAsLogicalVector();
        expect_true(lv.size() == 5);
        expect_true(lv[0] == true);
        expect_true(lv[1] == true);
        expect_true(lv[2] == true);
        expect_true(lv[3] == true);
        expect_true(lv[4] == true);

        NumericVector vv = b.getValuesAsNumericVector();
        expect_true(vv.size() == 5);
        expect_true(vv[0] == 1.0);
        expect_true(vv[1] == 1.0);
        expect_true(vv[2] == 1.0);
        expect_true(vv[3] == 1.0);
        expect_true(vv[4] == 1.0);

        NumericVector nv = b.getWeightedValuesAsNumericVector();
        expect_true(nv.size() == 5);
        expect_true(nv[0] == 1.0);
        expect_true(nv[1] == 1.0);
        expect_true(nv[2] == 1.0);
        expect_true(nv[3] == 1.0);
        expect_true(nv[4] == 1.0);
    }

    test_that("empty chain with weights") {
        FloatChain<TNorm::GOGUEN>::setWeights({1.0, 2.0, 3.0, 4.0, 5.0});
        FloatChain<TNorm::GOGUEN> b(15.0);

        expect_true(b.hasPredicate() == false);
        expect_true(b.empty());
        expect_true(b.size() == 0);
        expect_true(b.getSum() == 15.0);
        expect_true(b.isCondition());
        expect_true(!b.isFocus());

        LogicalVector lv = b.getValuesAsLogicalVector();
        expect_true(lv.size() == 5);
        expect_true(lv[0] == true);
        expect_true(lv[1] == true);
        expect_true(lv[2] == true);
        expect_true(lv[3] == true);
        expect_true(lv[4] == true);

        NumericVector vv = b.getValuesAsNumericVector();
        expect_true(vv.size() == 5);
        expect_true(vv[0] == 1.0);
        expect_true(vv[1] == 1.0);
        expect_true(vv[2] == 1.0);
        expect_true(vv[3] == 1.0);
        expect_true(vv[4] == 1.0);

        NumericVector nv = b.getWeightedValuesAsNumericVector();
        expect_true(nv.size() == 5);
        expect_true(nv[0] == 1.0);
        expect_true(nv[1] == 2.0);
        expect_true(nv[2] == 3.0);
        expect_true(nv[3] == 4.0);
        expect_true(nv[4] == 5.0);
    }

    test_that("initialize from LogicalVector") {
        FloatChain<TNorm::GOGUEN>::resetWeights();
        LogicalVector v(5);
        v[0] = true;
        v[1] = false;
        v[2] = true;
        v[3] = true;
        v[4] = false;

        FloatChain<TNorm::GOGUEN> b(3, PredicateType::FOCUS, v);

        expect_true(b.hasPredicate() == true);
        expect_true(b.getPredicate() == 3);
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

        LogicalVector lv = b.getValuesAsLogicalVector();
        expect_true(lv.size() == 5);
        expect_true(lv[0] == true);
        expect_true(lv[1] == false);
        expect_true(lv[2] == true);
        expect_true(lv[3] == true);
        expect_true(lv[4] == false);

        NumericVector vv = b.getValuesAsNumericVector();
        expect_true(vv.size() == 5);
        expect_true(vv[0] == 1.0);
        expect_true(vv[1] == 0.0);
        expect_true(vv[2] == 1.0);
        expect_true(vv[3] == 1.0);
        expect_true(vv[4] == 0.0);

        NumericVector nv = b.getWeightedValuesAsNumericVector();
        expect_true(nv.size() == 5);
        expect_true(nv[0] == 1.0);
        expect_true(nv[1] == 0.0);
        expect_true(nv[2] == 1.0);
        expect_true(nv[3] == 1.0);
        expect_true(nv[4] == 0.0);
    }

    test_that("initialize from LogicalVector with weights") {
        FloatChain<TNorm::GOGUEN>::setWeights({1.0, 2.0, 3.0, 4.0, 5.0});
        LogicalVector v(5);
        v[0] = true;
        v[1] = false;
        v[2] = true;
        v[3] = true;
        v[4] = false;

        FloatChain<TNorm::GOGUEN> b(3, PredicateType::FOCUS, v);

        expect_true(b.hasPredicate() == true);
        expect_true(b.getPredicate() == 3);
        expect_true(!b.empty());
        expect_true(b.size() == 5);
        expect_true(EQUAL(b.getSum(), 1.0 + 3.0 + 4.0));
        expect_true(!b.isCondition());
        expect_true(b.isFocus());
        expect_true(EQUAL(b.at(0), 1.0));
        expect_true(EQUAL(b.at(1), 0.0));
        expect_true(EQUAL(b.at(2), 1.0));
        expect_true(EQUAL(b.at(3), 1.0));
        expect_true(EQUAL(b.at(4), 0.0));

        LogicalVector lv = b.getValuesAsLogicalVector();
        expect_true(lv.size() == 5);
        expect_true(lv[0] == true);
        expect_true(lv[1] == false);
        expect_true(lv[2] == true);
        expect_true(lv[3] == true);
        expect_true(lv[4] == false);

        NumericVector vv = b.getValuesAsNumericVector();
        expect_true(vv.size() == 5);
        expect_true(vv[0] == 1.0);
        expect_true(vv[1] == 0.0);
        expect_true(vv[2] == 1.0);
        expect_true(vv[3] == 1.0);
        expect_true(vv[4] == 0.0);

        NumericVector nv = b.getWeightedValuesAsNumericVector();
        expect_true(nv.size() == 5);
        expect_true(nv[0] == 1.0);
        expect_true(nv[1] == 0.0);
        expect_true(nv[2] == 3.0);
        expect_true(nv[3] == 4.0);
        expect_true(nv[4] == 0.0);
    }

    test_that("initialize from NumericVector") {
        FloatChain<TNorm::GOGUEN>::resetWeights();
        NumericVector v(5);
        v[0] = 0.8;
        v[1] = 0.3;
        v[2] = 1.0;
        v[3] = 0.0;
        v[4] = 0.2;

        FloatChain<TNorm::GOGUEN> b(3, PredicateType::FOCUS, v);

        expect_true(b.hasPredicate() == true);
        expect_true(b.getPredicate() == 3);
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

        LogicalVector lv = b.getValuesAsLogicalVector();
        expect_true(lv.size() == 5);
        expect_true(lv[0] == true);
        expect_true(lv[1] == true);
        expect_true(lv[2] == true);
        expect_true(lv[3] == false);
        expect_true(lv[4] == true);

        NumericVector vv = b.getValuesAsNumericVector();
        expect_true(vv.size() == 5);
        expect_true(EQUAL(vv[0], 0.8));
        expect_true(EQUAL(vv[1], 0.3));
        expect_true(EQUAL(vv[2], 1.0));
        expect_true(EQUAL(vv[3], 0.0));
        expect_true(EQUAL(vv[4], 0.2));

        NumericVector nv = b.getWeightedValuesAsNumericVector();
        expect_true(nv.size() == 5);
        expect_true(EQUAL(nv[0], 0.8));
        expect_true(EQUAL(nv[1], 0.3));
        expect_true(EQUAL(nv[2], 1.0));
        expect_true(EQUAL(nv[3], 0.0));
        expect_true(EQUAL(nv[4], 0.2));
    }

    test_that("initialize from NumericVector with weights") {
        FloatChain<TNorm::GOGUEN>::setWeights({1.0, 2.0, 3.0, 4.0, 5.0});
        NumericVector v(5);
        v[0] = 0.8;
        v[1] = 0.3;
        v[2] = 1.0;
        v[3] = 0.0;
        v[4] = 0.2;

        FloatChain<TNorm::GOGUEN> b(3, PredicateType::FOCUS, v);

        expect_true(b.hasPredicate() == true);
        expect_true(b.getPredicate() == 3);
        expect_true(!b.empty());
        expect_true(b.size() == 5);
        expect_true(EQUAL(b.getSum(), 1.0 * 0.8 + 2.0 * 0.3 + 3.0 * 1.0 + 4.0 * 0.0 + 5.0 * 0.2));
        expect_true(!b.isCondition());
        expect_true(b.isFocus());
        expect_true(EQUAL(b.at(0), 0.8));
        expect_true(EQUAL(b.at(1), 0.3));
        expect_true(EQUAL(b.at(2), 1.0));
        expect_true(EQUAL(b.at(3), 0.0));
        expect_true(EQUAL(b.at(4), 0.2));

        LogicalVector lv = b.getValuesAsLogicalVector();
        expect_true(lv.size() == 5);
        expect_true(lv[0] == true);
        expect_true(lv[1] == true);
        expect_true(lv[2] == true);
        expect_true(lv[3] == false);
        expect_true(lv[4] == true);

        NumericVector vv = b.getValuesAsNumericVector();
        expect_true(vv.size() == 5);
        expect_true(EQUAL(vv[0], 0.8));
        expect_true(EQUAL(vv[1], 0.3));
        expect_true(EQUAL(vv[2], 1.0));
        expect_true(EQUAL(vv[3], 0.0));
        expect_true(EQUAL(vv[4], 0.2));

        NumericVector nv = b.getWeightedValuesAsNumericVector();
        expect_true(nv.size() == 5);
        expect_true(EQUAL(nv[0], 1.0 * 0.8));
        expect_true(EQUAL(nv[1], 2.0 * 0.3));
        expect_true(EQUAL(nv[2], 3.0 * 1.0));
        expect_true(EQUAL(nv[3], 4.0 * 0.0));
        expect_true(EQUAL(nv[4], 5.0 * 0.2));
    }

    test_that("initialize by conjunction") {
        FloatChain<TNorm::GOGUEN>::resetWeights();
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
            expect_true(c1.hasPredicate() == true);
            expect_true(c1.getPredicate() == 10);
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
            expect_true(c1.hasPredicate() == true);
            expect_true(c2.getPredicate() == 11);
            expect_true(c2.getSum() == 1);
            expect_true(!c2.isCached());

            FloatChain<TNorm::GOGUEN> d(c1, c2);
            expect_true(c1.hasPredicate() == true);
            expect_true(d.getPredicate() == 11);
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

    test_that("initialize by conjunction with weights") {
        FloatChain<TNorm::GOGUEN>::setWeights({1.0, 2.0, 3.0, 4.0, 5.0});
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
            expect_true(c1.hasPredicate() == true);
            expect_true(c1.getPredicate() == 10);
            expect_true(!c1.empty());
            expect_true(c1.size() == 5);
            expect_true(c1.getSum() == 3.0); // weights[2] = 3.0
            expect_true(c1.isCondition());
            expect_true(c1.isFocus());
            expect_true(!c1.isCached());
            expect_true(c1.at(0) == 0.0);
            expect_true(c1.at(1) == 0.0);
            expect_true(c1.at(2) == 1.0);
            expect_true(c1.at(3) == 0.0);
            expect_true(c1.at(4) == 0.0);

            FloatChain<TNorm::GOGUEN> c2(b, a2);
            expect_true(c1.hasPredicate() == true);
            expect_true(c2.getPredicate() == 11);
            expect_true(c2.getSum() == 3.0);
            expect_true(!c2.isCached());

            FloatChain<TNorm::GOGUEN> d(c1, c2);
            expect_true(c1.hasPredicate() == true);
            expect_true(d.getPredicate() == 11);
            expect_true(d.getSum() == 3.0);
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
        FloatChain<TNorm::GOEDEL>::resetWeights();
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
        FloatChain<TNorm::GOGUEN>::resetWeights();
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
        FloatChain<TNorm::LUKASIEWICZ>::resetWeights();
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

    test_that("test goedel with weights") {
        FloatChain<TNorm::GOEDEL>::setWeights({1.0, 2.0, 3.0, 4.0, 5.0});
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
        expect_true(EQUAL(c.getSum(), 1.0 * 0.8 + 2.0 * 0.3 + 3.0 * 0.5 + 4.0 * 0.0 + 5.0 * 0.0));
    }

    test_that("test goguen with weights") {
        FloatChain<TNorm::GOGUEN>::setWeights({1.0, 2.0, 3.0, 4.0, 5.0});
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
        expect_true(EQUAL(c.getSum(), 1.0 * 0.8 * 0.9 + 2.0 * 0.3 * 0.8 + 3.0 * 0.5 + 4.0 * 0.0 + 5.0 * 0.0));
    }

    test_that("test lukasiewicz with weights") {
        FloatChain<TNorm::LUKASIEWICZ>::setWeights({1.0, 2.0, 3.0, 4.0, 5.0});
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
        expect_true(EQUAL(c.getSum(), 1.0 * 0.7 + 2.0 * 0.1 + 3.0 * 0.5 + 4.0 * 0.0 + 5.0 * 0.0));
    }

    test_that("clone copies const chain") {
        FloatChain<TNorm::GOGUEN>::resetWeights();
        NumericVector v(5);
        v[0] = 0.8;
        v[1] = 0.3;
        v[2] = 1.0;
        v[3] = 0.0;
        v[4] = 0.2;

        FloatChain<TNorm::GOGUEN> original(3, PredicateType::BOTH, v);
        const FloatChain<TNorm::GOGUEN>& constOriginal = original;
        FloatChain<TNorm::GOGUEN> copy = constOriginal.clone();

        original.setPredicateType(PredicateType::FOCUS);

        expect_true(copy.getPredicate() == 3);
        expect_true(EQUAL(copy.getSum(), 2.3));
        expect_true(copy.isCondition());
        expect_true(copy.isFocus());
        expect_true(EQUAL(copy.at(0), 0.8));
        expect_true(EQUAL(copy.at(1), 0.3));
        expect_true(EQUAL(copy.at(2), 1.0));
        expect_true(EQUAL(copy.at(3), 0.0));
        expect_true(EQUAL(copy.at(4), 0.2));
    }
}
