#include <testthat.h>
#include "common.h"

#ifndef __arm64__
// This code works only on Linux or Windows

#include "dig/FubitChain.h"


context("dig/FubitChain.h") {
    test_that("empty chain") {
        FubitChain<TNorm::GOGUEN, 4>::resetWeights();
        FubitChain<TNorm::GOGUEN, 4> b(5.0);

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
        FubitChain<TNorm::GOGUEN, 4>::setWeights({1.0, 2.0, 3.0, 4.0, 5.0});
        FubitChain<TNorm::GOGUEN, 4> b(5);

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

    test_that("initialize GOEDEL from LogicalVector") {
        FubitChain<TNorm::GOEDEL, 4>::resetWeights();
        LogicalVector v(5);
        v[0] = true;
        v[1] = false;
        v[2] = true;
        v[3] = true;
        v[4] = false;

        FubitChain<TNorm::GOEDEL, 4> b(3, PredicateType::FOCUS, v);

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

    test_that("initialize GOEDEL from LogicalVector with weights") {
        FubitChain<TNorm::GOEDEL, 4>::setWeights({1.0, 2.0, 3.0, 4.0, 5.0});
        LogicalVector v(5);
        v[0] = true;
        v[1] = false;
        v[2] = true;
        v[3] = true;
        v[4] = false;

        FubitChain<TNorm::GOEDEL, 4> b(3, PredicateType::FOCUS, v);

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

    test_that("initialize GOEDEL from NumericVector") {
        FubitChain<TNorm::GOEDEL, 4>::resetWeights();
        NumericVector v(5);
        v[0] = 0.8;
        v[1] = 0.3;
        v[2] = 1.0;
        v[3] = 0.0;
        v[4] = 0.2;

        FubitChain<TNorm::GOEDEL, 8> b(3, PredicateType::FOCUS, v);

        expect_true(b.hasPredicate() == true);
        expect_true(b.getPredicate() == 3);
        expect_true(!b.empty());
        expect_true(b.size() == 5);
        expect_true(abs(b.getSum() - 2.3) < 0.01);
        expect_true(!b.isCondition());
        expect_true(b.isFocus());
        expect_true(EQUAL100(b.at(0), 0.8));
        expect_true(EQUAL100(b.at(1), 0.3));
        expect_true(EQUAL100(b.at(2), 1.0));
        expect_true(EQUAL100(b.at(3), 0.0));
        expect_true(EQUAL100(b.at(4), 0.2));

        LogicalVector lv = b.getValuesAsLogicalVector();
        expect_true(lv.size() == 5);
        expect_true(lv[0] == true);
        expect_true(lv[1] == true);
        expect_true(lv[2] == true);
        expect_true(lv[3] == false);
        expect_true(lv[4] == true);

        NumericVector vv = b.getValuesAsNumericVector();
        expect_true(vv.size() == 5);
        expect_true(EQUAL100(vv[0], 0.8));
        expect_true(EQUAL100(vv[1], 0.3));
        expect_true(EQUAL100(vv[2], 1.0));
        expect_true(EQUAL100(vv[3], 0.0));
        expect_true(EQUAL100(vv[4], 0.2));

        NumericVector nv = b.getWeightedValuesAsNumericVector();
        expect_true(nv.size() == 5);
        expect_true(EQUAL100(nv[0], 0.8));
        expect_true(EQUAL100(nv[1], 0.3));
        expect_true(EQUAL100(nv[2], 1.0));
        expect_true(EQUAL100(nv[3], 0.0));
        expect_true(EQUAL100(nv[4], 0.2));
    }

    test_that("initialize GOEDEL from NumericVector with weights") {
        FubitChain<TNorm::GOEDEL, 4>::setWeights({1.0, 2.0, 3.0, 4.0, 5.0});
        NumericVector v(5);
        v[0] = 0.8;
        v[1] = 0.3;
        v[2] = 1.0;
        v[3] = 0.0;
        v[4] = 0.2;

        FubitChain<TNorm::GOEDEL, 8> b(3, PredicateType::FOCUS, v);

        expect_true(b.hasPredicate() == true);
        expect_true(b.getPredicate() == 3);
        expect_true(!b.empty());
        expect_true(b.size() == 5);
        expect_true(EQUAL100(b.getSum(), 1.0 * 0.8 + 2.0 * 0.3 + 3.0 * 1.0 + 4.0 * 0.0 + 5.0 * 0.2));
        expect_true(!b.isCondition());
        expect_true(b.isFocus());
        expect_true(EQUAL100(b.at(0), 0.8));
        expect_true(EQUAL100(b.at(1), 0.3));
        expect_true(EQUAL100(b.at(2), 1.0));
        expect_true(EQUAL100(b.at(3), 0.0));
        expect_true(EQUAL100(b.at(4), 0.2));

        LogicalVector lv = b.getValuesAsLogicalVector();
        expect_true(lv.size() == 5);
        expect_true(lv[0] == true);
        expect_true(lv[1] == true);
        expect_true(lv[2] == true);
        expect_true(lv[3] == false);
        expect_true(lv[4] == true);

        NumericVector vv = b.getValuesAsNumericVector();
        expect_true(vv.size() == 5);
        expect_true(EQUAL100(vv[0], 0.8));
        expect_true(EQUAL100(vv[1], 0.3));
        expect_true(EQUAL100(vv[2], 1.0));
        expect_true(EQUAL100(vv[3], 0.0));
        expect_true(EQUAL100(vv[4], 0.2));

        NumericVector nv = b.getWeightedValuesAsNumericVector();
        expect_true(nv.size() == 5);
        expect_true(EQUAL100(nv[0], 1.0 * 0.8));
        expect_true(EQUAL100(nv[1], 2.0 * 0.3));
        expect_true(EQUAL100(nv[2], 3.0 * 1.0));
        expect_true(EQUAL100(nv[3], 4.0 * 0.0));
        expect_true(EQUAL100(nv[4], 5.0 * 0.2));
    }

    test_that("initialize LUKASIEWICZ from LogicalVector") {
        FubitChain<TNorm::LUKASIEWICZ, 4>::resetWeights();
        LogicalVector v(5);
        v[0] = true;
        v[1] = false;
        v[2] = true;
        v[3] = true;
        v[4] = false;

        FubitChain<TNorm::LUKASIEWICZ, 4> b(3, PredicateType::FOCUS, v);

        expect_true(b.hasPredicate() == true);
        expect_true(b.getPredicate() == 3);
        expect_true(!b.empty());
        expect_true(b.size() == 5);
        expect_true(EQUAL100(b.getSum(), 3));
        expect_true(!b.isCondition());
        expect_true(b.isFocus());
        expect_true(EQUAL(b.at(0), 1.0));
        expect_true(EQUAL(b.at(1), 0.0));
        expect_true(EQUAL(b.at(2), 1.0));
        expect_true(EQUAL(b.at(3), 1.0));
        expect_true(EQUAL(b.at(4), 0.0));
    }

    test_that("initialize LUKASIEWICZ from LogicalVector with weights") {
        FubitChain<TNorm::LUKASIEWICZ, 4>::setWeights({1.0, 2.0, 3.0, 4.0, 5.0});
        LogicalVector v(5);
        v[0] = true;
        v[1] = false;
        v[2] = true;
        v[3] = true;
        v[4] = false;

        FubitChain<TNorm::LUKASIEWICZ, 4> b(3, PredicateType::FOCUS, v);

        expect_true(b.hasPredicate() == true);
        expect_true(b.getPredicate() == 3);
        expect_true(!b.empty());
        expect_true(b.size() == 5);
        expect_true(EQUAL100(b.getSum(), 1.0 + 3.0 + 4.0));
        expect_true(!b.isCondition());
        expect_true(b.isFocus());
        expect_true(EQUAL(b.at(0), 1.0));
        expect_true(EQUAL(b.at(1), 0.0));
        expect_true(EQUAL(b.at(2), 1.0));
        expect_true(EQUAL(b.at(3), 1.0));
        expect_true(EQUAL(b.at(4), 0.0));
    }

    test_that("initialize LUKASIEWICZ from NumericVector") {
        FubitChain<TNorm::LUKASIEWICZ, 4>::resetWeights();
        NumericVector v(5);
        v[0] = 0.8;
        v[1] = 0.3;
        v[2] = 1.0;
        v[3] = 0.0;
        v[4] = 0.2;

        FubitChain<TNorm::LUKASIEWICZ, 8> b(3, PredicateType::FOCUS, v);

        expect_true(b.hasPredicate() == true);
        expect_true(b.getPredicate() == 3);
        expect_true(!b.empty());
        expect_true(b.size() == 5);
        expect_true(EQUAL100(b.getSum(), 2.3));
        expect_true(!b.isCondition());
        expect_true(b.isFocus());
        expect_true(EQUAL100(b.at(0), 0.8));
        expect_true(EQUAL100(b.at(1), 0.3));
        expect_true(EQUAL100(b.at(2), 1.0));
        expect_true(EQUAL100(b.at(3), 0.0));
        expect_true(EQUAL100(b.at(4), 0.2));
    }

    test_that("initialize LUKASIEWICZ from NumericVector with weights") {
        FubitChain<TNorm::LUKASIEWICZ, 4>::setWeights({1.0, 2.0, 3.0, 4.0, 5.0});
        NumericVector v(5);
        v[0] = 0.8;
        v[1] = 0.3;
        v[2] = 1.0;
        v[3] = 0.0;
        v[4] = 0.2;

        FubitChain<TNorm::LUKASIEWICZ, 8> b(3, PredicateType::FOCUS, v);

        expect_true(b.hasPredicate() == true);
        expect_true(b.getPredicate() == 3);
        expect_true(!b.empty());
        expect_true(b.size() == 5);
        expect_true(EQUAL100(b.getSum(), 1.0 * 0.8 + 2.0 * 0.3 + 3.0 * 1.0 + 4.0 * 0.0 + 5.0 * 0.2));
        expect_true(!b.isCondition());
        expect_true(b.isFocus());
        expect_true(EQUAL100(b.at(0), 0.8));
        expect_true(EQUAL100(b.at(1), 0.3));
        expect_true(EQUAL100(b.at(2), 1.0));
        expect_true(EQUAL100(b.at(3), 0.0));
        expect_true(EQUAL100(b.at(4), 0.2));
    }

    test_that("initialize GOGUEN from LogicalVector") {
        FubitChain<TNorm::GOGUEN, 4>::resetWeights();
        LogicalVector v(5);
        v[0] = true;
        v[1] = false;
        v[2] = true;
        v[3] = true;
        v[4] = false;

        FubitChain<TNorm::GOGUEN, 4> b(3, PredicateType::FOCUS, v);

        expect_true(b.hasPredicate() == true);
        expect_true(b.getPredicate() == 3);
        expect_true(!b.empty());
        expect_true(b.size() == 5);
        expect_true(EQUAL100(b.getSum(), 3));
        expect_true(!b.isCondition());
        expect_true(b.isFocus());
        expect_true(EQUAL(b.at(0), 1.0));
        expect_true(EQUAL(b.at(1), 0.0));
        expect_true(EQUAL(b.at(2), 1.0));
        expect_true(EQUAL(b.at(3), 1.0));
        expect_true(EQUAL(b.at(4), 0.0));
    }

    test_that("initialize GOGUEN from LogicalVector with weights") {
        FubitChain<TNorm::GOGUEN, 4>::setWeights({1.0, 2.0, 3.0, 4.0, 5.0});
        LogicalVector v(5);
        v[0] = true;
        v[1] = false;
        v[2] = true;
        v[3] = true;
        v[4] = false;

        FubitChain<TNorm::GOGUEN, 4> b(3, PredicateType::FOCUS, v);

        expect_true(b.hasPredicate() == true);
        expect_true(b.getPredicate() == 3);
        expect_true(!b.empty());
        expect_true(b.size() == 5);
        expect_true(EQUAL100(b.getSum(), 1.0 + 3.0 + 4.0));
        expect_true(!b.isCondition());
        expect_true(b.isFocus());
        expect_true(EQUAL(b.at(0), 1.0));
        expect_true(EQUAL(b.at(1), 0.0));
        expect_true(EQUAL(b.at(2), 1.0));
        expect_true(EQUAL(b.at(3), 1.0));
        expect_true(EQUAL(b.at(4), 0.0));
    }

    test_that("initialize GOGUEN from NumericVector") {
        FubitChain<TNorm::GOGUEN, 4>::resetWeights();
        NumericVector v(5);
        v[0] = 0.8;
        v[1] = 0.3;
        v[2] = 1.0;
        v[3] = 0.0;
        v[4] = 0.2;

        FubitChain<TNorm::GOGUEN, 8> b(3, PredicateType::FOCUS, v);

        expect_true(b.hasPredicate() == true);
        expect_true(b.getPredicate() == 3);
        expect_true(!b.empty());
        expect_true(b.size() == 5);
        expect_true(EQUAL100(b.getSum(), 2.3));
        expect_true(!b.isCondition());
        expect_true(b.isFocus());
        expect_true(EQUAL100(b.at(0), 0.8));
        expect_true(EQUAL100(b.at(1), 0.3));
        expect_true(EQUAL100(b.at(2), 1.0));
        expect_true(EQUAL100(b.at(3), 0.0));
        expect_true(EQUAL100(b.at(4), 0.2));
    }

    test_that("initialize GOGUEN from NumericVector with weights") {
        FubitChain<TNorm::GOGUEN, 4>::setWeights({1.0, 2.0, 3.0, 4.0, 5.0});
        NumericVector v(5);
        v[0] = 0.8;
        v[1] = 0.3;
        v[2] = 1.0;
        v[3] = 0.0;
        v[4] = 0.2;

        FubitChain<TNorm::GOGUEN, 8> b(3, PredicateType::FOCUS, v);

        expect_true(b.hasPredicate() == true);
        expect_true(b.getPredicate() == 3);
        expect_true(!b.empty());
        expect_true(b.size() == 5);
        expect_true(EQUAL100(b.getSum(), 1.0 * 0.8 + 2.0 * 0.3 + 3.0 * 1.0 + 4.0 * 0.0 + 5.0 * 0.2));
        expect_true(!b.isCondition());
        expect_true(b.isFocus());
        expect_true(EQUAL100(b.at(0), 0.8));
        expect_true(EQUAL100(b.at(1), 0.3));
        expect_true(EQUAL100(b.at(2), 1.0));
        expect_true(EQUAL100(b.at(3), 0.0));
        expect_true(EQUAL100(b.at(4), 0.2));
    }

    test_that("conjunct") {
        FubitChain<TNorm::GOEDEL, 4>::resetWeights();
        FubitChain<TNorm::GOGUEN, 4>::resetWeights();
        FubitChain<TNorm::LUKASIEWICZ, 4>::resetWeights();
        NumericVector a(100);
        NumericVector b(100);

        for (size_t i = 0; i < 100; i += 5) {
            a[i] = 1.0;
            b[i] = 0.8;

            a[i+1] = 0.0;
            b[i+1] = 0.4;

            a[i+2] = 0.5;
            b[i+2] = 0.5;

            a[i+3] = 0.8;
            b[i+3] = 0.3;

            a[i+4] = 0.2;
            b[i+4] = 0.1;
        }

        FubitChain<TNorm::GOEDEL, 8> goeA(3, PredicateType::BOTH, a);
        FubitChain<TNorm::GOEDEL, 8> goeB(3, PredicateType::BOTH, b);
        FubitChain<TNorm::GOGUEN, 8> gogA(3, PredicateType::BOTH, a);
        FubitChain<TNorm::GOGUEN, 8> gogB(3, PredicateType::BOTH, b);
        FubitChain<TNorm::LUKASIEWICZ, 8> lukA(3, PredicateType::BOTH, a);
        FubitChain<TNorm::LUKASIEWICZ, 8> lukB(3, PredicateType::BOTH, b);

        FubitChain<TNorm::GOEDEL, 8> goe(goeA, goeB);
        FubitChain<TNorm::GOGUEN, 8> gog(gogA, gogB);
        FubitChain<TNorm::LUKASIEWICZ, 8> luk(lukA, lukB);

        expect_true(goe.size() == 100);
        expect_true(gog.size() == 100);
        expect_true(luk.size() == 100);

        for (size_t i = 0; i < 100; i += 5) {
            expect_true(EQUAL100(goe[i], 0.8));
            expect_true(EQUAL100(goe[i+1], 0.0));
            expect_true(EQUAL100(goe[i+2], 0.5));
            expect_true(EQUAL100(goe[i+3], 0.3));
            expect_true(EQUAL100(goe[i+4], 0.1));

            expect_true(EQUAL100(gog[i], 0.8));
            expect_true(EQUAL100(gog[i+1], 0.0));
            expect_true(EQUAL100(gog[i+2], 0.25));
            expect_true(EQUAL100(gog[i+3], 0.8 * 0.3));
            expect_true(EQUAL100(gog[i+4], 0.2 * 0.1));

            expect_true(EQUAL100(luk[i], 0.8));
            expect_true(EQUAL100(luk[i+1], 0.0));
            expect_true(EQUAL100(luk[i+2], 0.0));
            expect_true(EQUAL100(luk[i+3], 0.1));
            expect_true(EQUAL100(luk[i+4], 0.0));
        }

        expect_true(EQUAL1(goe.getSum(), 34));
        expect_true(EQUAL1(gog.getSum(), 26.2));
        expect_true(EQUAL1(luk.getSum(), 18));
    }

    test_that("conjunct with weights") {
        std::vector<float> weights(100);
        for (size_t i = 0; i < 100; i++) {
            weights[i] = i + 1;
        }

        FubitChain<TNorm::GOEDEL, 4>::setWeights(weights);
        FubitChain<TNorm::GOGUEN, 4>::setWeights(weights);
        FubitChain<TNorm::LUKASIEWICZ, 4>::setWeights(weights);
        NumericVector a(100);
        NumericVector b(100);

        for (size_t i = 0; i < 100; i += 5) {
            a[i] = 1.0;
            b[i] = 0.8;

            a[i+1] = 0.0;
            b[i+1] = 0.4;

            a[i+2] = 0.5;
            b[i+2] = 0.5;

            a[i+3] = 0.8;
            b[i+3] = 0.3;

            a[i+4] = 0.2;
            b[i+4] = 0.1;
        }

        FubitChain<TNorm::GOEDEL, 8> goeA(3, PredicateType::BOTH, a);
        FubitChain<TNorm::GOEDEL, 8> goeB(3, PredicateType::BOTH, b);
        FubitChain<TNorm::GOGUEN, 8> gogA(3, PredicateType::BOTH, a);
        FubitChain<TNorm::GOGUEN, 8> gogB(3, PredicateType::BOTH, b);
        FubitChain<TNorm::LUKASIEWICZ, 8> lukA(3, PredicateType::BOTH, a);
        FubitChain<TNorm::LUKASIEWICZ, 8> lukB(3, PredicateType::BOTH, b);

        FubitChain<TNorm::GOEDEL, 8> goe(goeA, goeB);
        FubitChain<TNorm::GOGUEN, 8> gog(gogA, gogB);
        FubitChain<TNorm::LUKASIEWICZ, 8> luk(lukA, lukB);

        expect_true(goe.size() == 100);
        expect_true(gog.size() == 100);
        expect_true(luk.size() == 100);

        double goeSum = 0.0;
        double gogSum = 0.0;
        double lukSum = 0.0;
        for (size_t i = 0; i < 100; i += 5) {
            expect_true(EQUAL100(goe[i], 0.8));
            expect_true(EQUAL100(goe[i+1], 0.0));
            expect_true(EQUAL100(goe[i+2], 0.5));
            expect_true(EQUAL100(goe[i+3], 0.3));
            expect_true(EQUAL100(goe[i+4], 0.1));
            goeSum += goe[i] * weights[i] + goe[i+1] * weights[i+1] + goe[i+2] * weights[i+2] + goe[i+3] * weights[i+3] + goe[i+4] * weights[i+4];

            expect_true(EQUAL100(gog[i], 0.8));
            expect_true(EQUAL100(gog[i+1], 0.0));
            expect_true(EQUAL100(gog[i+2], 0.25));
            expect_true(EQUAL100(gog[i+3], 0.8 * 0.3));
            expect_true(EQUAL100(gog[i+4], 0.2 * 0.1));
            gogSum += gog[i] * weights[i] + gog[i+1] * weights[i+1] + gog[i+2] * weights[i+2] + gog[i+3] * weights[i+3] + gog[i+4] * weights[i+4];

            expect_true(EQUAL100(luk[i], 0.8));
            expect_true(EQUAL100(luk[i+1], 0.0));
            expect_true(EQUAL100(luk[i+2], 0.0));
            expect_true(EQUAL100(luk[i+3], 0.1));
            expect_true(EQUAL100(luk[i+4], 0.0));
            lukSum += luk[i] * weights[i] + luk[i+1] * weights[i+1] + luk[i+2] * weights[i+2] + luk[i+3] * weights[i+3] + luk[i+4] * weights[i+4];
        }

        expect_true(EQUAL100(goe.getSum(), goeSum));
        expect_true(EQUAL100(gog.getSum(), gogSum));
        expect_true(EQUAL100(luk.getSum(), lukSum));
    }

    test_that("clone copies const chain") {
        FubitChain<TNorm::GOGUEN, 4>::resetWeights();
        NumericVector v(5);
        v[0] = 0.8;
        v[1] = 0.3;
        v[2] = 1.0;
        v[3] = 0.0;
        v[4] = 0.2;

        FubitChain<TNorm::GOGUEN, 8> original(3, PredicateType::BOTH, v);
        const FubitChain<TNorm::GOGUEN, 8>& constOriginal = original;
        FubitChain<TNorm::GOGUEN, 8> copy = constOriginal.clone();

        original.setPredicateType(PredicateType::FOCUS);

        expect_true(copy.getPredicate() == 3);
        expect_true(EQUAL100(copy.getSum(), 2.3));
        expect_true(copy.isCondition());
        expect_true(copy.isFocus());
        expect_true(EQUAL100(copy.at(0), 0.8));
        expect_true(EQUAL100(copy.at(1), 0.3));
        expect_true(EQUAL100(copy.at(2), 1.0));
        expect_true(EQUAL100(copy.at(3), 0.0));
        expect_true(EQUAL100(copy.at(4), 0.2));
    }
}

#endif // __arm64__
