#include <testthat.h>
#include "Task.hpp"

context("Task.hpp") {
    Task t0({1, 3, 5});
    Task t1({}, {10, 11, 12}, {5, 6});
    Task t({0, 1, 2}, {10, 11, 12}, {5, 6});

    test_that("getPrefix") {
        expect_true(t.getPrefix() == set<int>({0, 1, 2}));
    }

    test_that("getAvailable") {
        expect_true(t.getAvailable() == vector<int>({10, 11, 12}));
    }

    test_that("getSoFar") {
        expect_true(t.getSoFar() == vector<int>({5, 6}));
    }

    test_that("getLength") {
        expect_true(t0.getLength() == 0);
        expect_true(t1.getLength() == 1);
        expect_true(t.getLength() == 4);
    }

    test_that("predicate enumeration") {
        expect_true(t.hasPredicate());
        expect_true(t.getCurrentPredicate() == 10);
        t.next();
        expect_true(t.hasPredicate());
        expect_true(t.getCurrentPredicate() == 11);
        t.putCurrentToSoFar();
        t.next();
        expect_true(t.hasPredicate());
        expect_true(t.getCurrentPredicate() == 12);
        t.putCurrentToSoFar();
        t.next();
        expect_true(!t.hasPredicate());

        expect_true(t.getSoFar() == vector<int>({5, 6, 11, 12}));

        t.reset();
        expect_true(t.getSoFar().size() == 0);

        expect_true(t.hasPredicate());
        expect_true(t.getCurrentPredicate() == 10);
        t.next();
        expect_true(t.hasPredicate());
        expect_true(t.getCurrentPredicate() == 11);
        t.next();
        expect_true(t.hasPredicate());
        expect_true(t.getCurrentPredicate() == 12);
        t.next();
        expect_true(!t.hasPredicate());
    }

    test_that("constructor n") {
        Task tn(5);
        expect_true(tn.getPrefix().size() == 0);
        expect_true(tn.getAvailable().size() == 0);
        expect_true(tn.getSoFar() == vector<int>({0, 1, 2, 3, 4}));
        expect_true(tn.getLength() == 0);
        expect_false(tn.hasPredicate());
    }
}
