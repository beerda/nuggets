#include <testthat.h>
#include "Task.hpp"

context("Task.hpp") {
    Task t0({1, 3, 5});
    Task t1({}, {10, 11, 12}, {5, 6});
    Task t({0, 1, 2}, {10, 11, 12}, {5, 6});

    test_that("==") {
        Task tA({1, 2, 3}, {4, 5, 6}, {7, 8, 9});
        Task tB({1, 2, 3}, {4, 5, 6}, {7, 8, 9});
        tB.next();

        expect_true(tA == Task({1, 2, 3}, {4, 5, 6}, {7, 8, 9}));
        expect_false(tA == Task({2, 3}, {4, 5, 6}, {7, 8, 9}));
        expect_false(tA == Task({1, 2, 3}, {4, 6}, {7, 8, 9}));
        expect_false(tA == Task({1, 2, 3}, {4, 5, 6}, {7, 8}));
        expect_false(tA == tB);
    }

    test_that("getPrefix") {
        expect_true(t.getPrefix() == set<int>({0, 1, 2}));
    }

    test_that("getAvailable") {
        expect_true(t.getAvailable() == vector<int>({10, 11, 12}));
    }

    test_that("getSoFar") {
        expect_true(t.getSoFar() == vector<int>({5, 6}));
        expect_true(t.hasSoFar());
    }

    test_that("getLength") {
        expect_true(t0.getLength() == 0);
        expect_true(t1.getLength() == 1);
        expect_true(t.getLength() == 4);
    }

    test_that("empty") {
        expect_false(t.empty());
        expect_false(t0.empty());
        expect_false(t1.empty());

        Task empty;
        expect_true(empty.empty());
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
        expect_true(t.hasSoFar());

        t.reset();
        expect_true(t.getSoFar().size() == 0);
        expect_false(t.hasSoFar());

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

    test_that("createChild") {
        Task ch = t.createChild();
        expect_true(ch.getPrefix() == set<int>({0, 1, 2, 10}));
        expect_true(ch.getAvailable() == vector<int>({5, 6}));

        t.next();
        t.next();
        t.next();
        ch = t.createChild();
        expect_true(ch.getPrefix() == set<int>({0, 1, 2}));
        expect_true(ch.getAvailable() == vector<int>({5, 6}));
    }
}
