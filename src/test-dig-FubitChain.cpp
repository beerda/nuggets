#include <testthat.h>
#include "common.h"
#include "dig/FubitChain.h"

context("dig/FubitChain.h") {
    test_that("initialize GOEDEL from LogicalVector") {
        LogicalVector v(5);
        v[0] = true;
        v[1] = false;
        v[2] = true;
        v[3] = true;
        v[4] = false;

        FubitChain<TNorm::GOEDEL, 4> b(3, PredicateType::FOCUS, v);

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

    test_that("initialize GOEDEL from NumericVector") {
        NumericVector v(5);
        v[0] = 0.8;
        v[1] = 0.3;
        v[2] = 1.0;
        v[3] = 0.0;
        v[4] = 0.2;

        FubitChain<TNorm::GOEDEL, 8> b(3, PredicateType::FOCUS, v);

        expect_true(b.getClause().size() == 1);
        expect_true(b.getClause()[0] == 3);
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
    }

    test_that("initialize LUKASIEWICZ from LogicalVector") {
        LogicalVector v(5);
        v[0] = true;
        v[1] = false;
        v[2] = true;
        v[3] = true;
        v[4] = false;

        FubitChain<TNorm::LUKASIEWICZ, 4> b(3, PredicateType::FOCUS, v);

        expect_true(b.getClause().size() == 1);
        expect_true(b.getClause()[0] == 3);
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

    test_that("initialize LUKASIEWICZ from NumericVector") {
        NumericVector v(5);
        v[0] = 0.8;
        v[1] = 0.3;
        v[2] = 1.0;
        v[3] = 0.0;
        v[4] = 0.2;

        FubitChain<TNorm::LUKASIEWICZ, 8> b(3, PredicateType::FOCUS, v);

        expect_true(b.getClause().size() == 1);
        expect_true(b.getClause()[0] == 3);
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

    test_that("initialize GOGUEN from LogicalVector") {
        LogicalVector v(5);
        v[0] = true;
        v[1] = false;
        v[2] = true;
        v[3] = true;
        v[4] = false;

        FubitChain<TNorm::GOGUEN, 4> b(3, PredicateType::FOCUS, v);

        expect_true(b.getClause().size() == 1);
        expect_true(b.getClause()[0] == 3);
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

    test_that("initialize GOGUEN from NumericVector") {
        NumericVector v(5);
        v[0] = 0.8;
        v[1] = 0.3;
        v[2] = 1.0;
        v[3] = 0.0;
        v[4] = 0.2;

        FubitChain<TNorm::GOGUEN, 8> b(3, PredicateType::FOCUS, v);

        expect_true(b.getClause().size() == 1);
        expect_true(b.getClause()[0] == 3);
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

    test_that("conjunct") {
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

        for (size_t i = 0; i < 1; i += 5) {
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
}
