#include <testthat.h>
#include "common.h"
#include "dig/Iterator.h"

context("dig/Iterator.h") {
    test_that("==") {
        Iterator tA({1, 2, 3}, {4, 5, 6}, {7, 8, 9});
        Iterator tB({1, 2, 3}, {4, 5, 6}, {7, 8, 9});
        tB.next();

        expect_true(tA == Iterator({1, 2, 3}, {4, 5, 6}, {7, 8, 9}));
        expect_true(tA != Iterator({2, 3}, {4, 5, 6}, {7, 8, 9}));
        expect_true(tA != Iterator({1, 2, 3}, {4, 6}, {7, 8, 9}));
        expect_true(tA != Iterator({1, 2, 3}, {4, 5, 6}, {7, 8}));
        expect_true(tA != tB);
    }

    test_that("getPrefix") {
        Iterator i({0, 1, 2}, {10, 11, 12}, {5, 6});
        expect_true(i.getPrefix() == vector<int>({0, 1, 2}));
    }

    test_that("getPrefix") {
        Iterator t({0, 1, 2}, {10, 11, 12}, {5, 6});
        expect_true(t.getPrefix() == vector<int>({0, 1, 2}));
    }

    test_that("getAvailable") {
        Iterator t({0, 1, 2}, {10, 11, 12}, {5, 6});
        expect_true(t.getAvailable() == vector<int>({10, 11, 12}));
    }

    test_that("getSoFar") {
        Iterator t({0, 1, 2}, {10, 11, 12}, {5, 6});
        expect_true(t.getSoFar() == vector<int>({5, 6}));
        expect_true(t.hasSoFar());
    }

    test_that("getLength & empty") {
        Iterator empty;
        Iterator t({0, 1, 2}, {10, 11, 12}, {5, 6});
        Iterator t0({1, 3, 5});
        Iterator t1({}, {10, 11, 12}, {5, 6});

        expect_true(t.getLength() == 4);
        expect_true(t0.getLength() == 0);
        expect_true(t1.getLength() == 1);

        expect_true(empty.empty());
        expect_true(!t.empty());
        expect_true(!t0.empty());
        expect_true(!t1.empty());

    }

    test_that("predicate enumeration") {
        Iterator t({0, 1, 2}, {10, 11, 12}, {5, 6});

        expect_true(t.hasPredicate());
        expect_true(t.getCurrentPredicate() == 10);
        expect_true(t.getCurrentCondition() == set<int>({0, 1, 2, 10}));
        t.next();
        expect_true(t.hasPredicate());
        expect_true(t.getCurrentPredicate() == 11);
        expect_true(t.getCurrentCondition() == set<int>({0, 1, 2, 11}));
        t.putCurrentToSoFar();
        t.next();
        expect_true(t.hasPredicate());
        expect_true(t.getCurrentPredicate() == 12);
        expect_true(t.getCurrentCondition() == set<int>({0, 1, 2, 12}));
        t.putCurrentToSoFar();
        t.next();
        expect_true(!t.hasPredicate());

        expect_true(t.getSoFar() == vector<int>({5, 6, 11, 12}));
        expect_true(t.hasSoFar());

        t.reset();
        expect_true(t.getSoFar().size() == 0);
        expect_false(t.hasSoFar());

        expect_true(t.hasPredicate());
        expect_true(t.getCurrentPredicate() == 10);
        expect_true(t.getCurrentCondition() == set<int>({0, 1, 2, 10}));
        t.next();
        expect_true(t.hasPredicate());
        expect_true(t.getCurrentPredicate() == 11);
        expect_true(t.getCurrentCondition() == set<int>({0, 1, 2, 11}));
        t.next();
        expect_true(t.hasPredicate());
        expect_true(t.getCurrentPredicate() == 12);
        expect_true(t.getCurrentCondition() == set<int>({0, 1, 2, 12}));
        t.next();
        expect_true(!t.hasPredicate());
    }
}
