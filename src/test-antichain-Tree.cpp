#include <testthat.h>
#include <iostream>
#include "common.h"
#include "antichain/Tree.h"

context("antichain/Tree.h") {
    test_that("empty tree") {
        Tree t;

        expect_true(t.getRoot().getDepth() == 0);
        expect_true(t.getRoot().getChildren().empty());
        expect_true(t.getRoot().getPrefix().empty());
        expect_true(t.getRoot().getNumDescendants() == 0);
        expect_true(t.getNumNodes() == 1);
    }

    test_that("incremental complex test A") {
        Tree t;
        bool res;

        expect_true(t.getNumNodes() == 1);

        // add {5, 2, 1}
        expect_true(t.insertIfIncomparable(Condition({1, 2, 5})));
        //cout << endl << t.visualize();
        expect_true(t.getNumNodes() == 4);
        expect_false(t.insertIfIncomparable(Condition({1})));
        expect_false(t.insertIfIncomparable(Condition({2})));
        expect_false(t.insertIfIncomparable(Condition({5})));
        expect_false(t.insertIfIncomparable(Condition({1, 2})));
        expect_false(t.insertIfIncomparable(Condition({1, 5})));
        expect_false(t.insertIfIncomparable(Condition({2, 5})));
        expect_false(t.insertIfIncomparable(Condition({1, 2, 5})));
        expect_true(t.getNumNodes() == 4);

        // add {5, 2, 3}
        expect_true(t.insertIfIncomparable(Condition({3, 5, 2})));
        //cout << endl << t.visualize();
        expect_true(t.getNumNodes() == 5);
        expect_false(t.insertIfIncomparable(Condition({3})));
        expect_false(t.insertIfIncomparable(Condition({2, 3})));
        expect_false(t.insertIfIncomparable(Condition({5, 3})));
        expect_false(t.insertIfIncomparable(Condition({2, 5, 3})));

        // add {5, 6, 7}
        expect_true(t.insertIfIncomparable(Condition({5, 6, 7})));
        //cout << endl << t.visualize();
        expect_true(t.getNumNodes() == 7);
        expect_false(t.insertIfIncomparable(Condition({5, 7})));
        expect_false(t.insertIfIncomparable(Condition({6, 7})));
        expect_false(t.insertIfIncomparable(Condition({5, 6, 7})));

        // add {2, 4, 6}
        expect_true(t.insertIfIncomparable(Condition({2, 4, 6})));
        //cout << endl << t.visualize();
        expect_true(t.getNumNodes() == 10);
        expect_false(t.insertIfIncomparable(Condition({4})));
        expect_false(t.insertIfIncomparable(Condition({2, 4})));
        expect_false(t.insertIfIncomparable(Condition({2, 6})));
        expect_false(t.insertIfIncomparable(Condition({4, 6})));
        expect_false(t.insertIfIncomparable(Condition({2, 4, 6})));

        // add {9}
        expect_true(t.insertIfIncomparable(Condition({9})));
        //cout << endl << t.visualize();
        expect_true(t.getNumNodes() == 11);
        expect_false(t.insertIfIncomparable(Condition({9})));
    }

    test_that("bulk 1 complex test A") {
        Tree t;
        bool res;

        expect_true(t.insertIfIncomparable(Condition({1, 2, 5})));
        expect_true(t.insertIfIncomparable(Condition({3, 5, 2})));
        expect_true(t.insertIfIncomparable(Condition({5, 6, 7})));
        expect_true(t.insertIfIncomparable(Condition({2, 4, 6})));
        expect_true(t.insertIfIncomparable(Condition({9})));

        // the same as in "incremental complex test A"
        expect_false(t.insertIfIncomparable(Condition({1})));
        expect_false(t.insertIfIncomparable(Condition({2})));
        expect_false(t.insertIfIncomparable(Condition({5})));
        expect_false(t.insertIfIncomparable(Condition({1, 2})));
        expect_false(t.insertIfIncomparable(Condition({1, 5})));
        expect_false(t.insertIfIncomparable(Condition({2, 5})));
        expect_false(t.insertIfIncomparable(Condition({1, 2, 5})));
        expect_false(t.insertIfIncomparable(Condition({3})));
        expect_false(t.insertIfIncomparable(Condition({2, 3})));
        expect_false(t.insertIfIncomparable(Condition({5, 3})));
        expect_false(t.insertIfIncomparable(Condition({2, 5, 3})));
        expect_false(t.insertIfIncomparable(Condition({5, 7})));
        expect_false(t.insertIfIncomparable(Condition({6, 7})));
        expect_false(t.insertIfIncomparable(Condition({5, 6, 7})));
        expect_false(t.insertIfIncomparable(Condition({2, 4})));
        expect_false(t.insertIfIncomparable(Condition({2, 6})));
        expect_false(t.insertIfIncomparable(Condition({4, 6})));
        expect_false(t.insertIfIncomparable(Condition({2, 4, 6})));
        expect_false(t.insertIfIncomparable(Condition({9})));
    }

    test_that("bulk 2 complex test A") {
        Tree t;
        bool res;

        expect_true(t.insertIfIncomparable(Condition({9})));
        expect_true(t.insertIfIncomparable(Condition({2, 4, 6})));
        expect_true(t.insertIfIncomparable(Condition({3, 5, 2})));
        expect_true(t.insertIfIncomparable(Condition({5, 6, 7})));
        expect_true(t.insertIfIncomparable(Condition({1, 2, 5})));

        // the same as in "incremental complex test A"
        expect_false(t.insertIfIncomparable(Condition({1})));
        expect_false(t.insertIfIncomparable(Condition({2})));
        expect_false(t.insertIfIncomparable(Condition({5})));
        expect_false(t.insertIfIncomparable(Condition({1, 2})));
        expect_false(t.insertIfIncomparable(Condition({1, 5})));
        expect_false(t.insertIfIncomparable(Condition({2, 5})));
        expect_false(t.insertIfIncomparable(Condition({1, 2, 5})));
        expect_false(t.insertIfIncomparable(Condition({3})));
        expect_false(t.insertIfIncomparable(Condition({2, 3})));
        expect_false(t.insertIfIncomparable(Condition({5, 3})));
        expect_false(t.insertIfIncomparable(Condition({2, 5, 3})));
        expect_false(t.insertIfIncomparable(Condition({5, 7})));
        expect_false(t.insertIfIncomparable(Condition({6, 7})));
        expect_false(t.insertIfIncomparable(Condition({5, 6, 7})));
        expect_false(t.insertIfIncomparable(Condition({2, 4})));
        expect_false(t.insertIfIncomparable(Condition({2, 6})));
        expect_false(t.insertIfIncomparable(Condition({4, 6})));
        expect_false(t.insertIfIncomparable(Condition({2, 4, 6})));
        expect_false(t.insertIfIncomparable(Condition({9})));
    }

    test_that("bulk 3 complex test A") {
        Tree t;
        bool res;

        expect_true(t.insertIfIncomparable(Condition({6, 4, 2})));
        expect_true(t.insertIfIncomparable(Condition({5, 1, 2})));
        expect_true(t.insertIfIncomparable(Condition({2, 3, 5})));
        expect_true(t.insertIfIncomparable(Condition({9})));
        expect_true(t.insertIfIncomparable(Condition({7, 5, 6})));

        // the same as in "incremental complex test A"
        expect_false(t.insertIfIncomparable(Condition({1})));
        expect_false(t.insertIfIncomparable(Condition({2})));
        expect_false(t.insertIfIncomparable(Condition({5})));
        expect_false(t.insertIfIncomparable(Condition({1, 2})));
        expect_false(t.insertIfIncomparable(Condition({1, 5})));
        expect_false(t.insertIfIncomparable(Condition({2, 5})));
        expect_false(t.insertIfIncomparable(Condition({1, 2, 5})));
        expect_false(t.insertIfIncomparable(Condition({3})));
        expect_false(t.insertIfIncomparable(Condition({2, 3})));
        expect_false(t.insertIfIncomparable(Condition({5, 3})));
        expect_false(t.insertIfIncomparable(Condition({2, 5, 3})));
        expect_false(t.insertIfIncomparable(Condition({5, 7})));
        expect_false(t.insertIfIncomparable(Condition({6, 7})));
        expect_false(t.insertIfIncomparable(Condition({5, 6, 7})));
        expect_false(t.insertIfIncomparable(Condition({2, 4})));
        expect_false(t.insertIfIncomparable(Condition({2, 6})));
        expect_false(t.insertIfIncomparable(Condition({4, 6})));
        expect_false(t.insertIfIncomparable(Condition({2, 4, 6})));
        expect_false(t.insertIfIncomparable(Condition({9})));
    }
}
