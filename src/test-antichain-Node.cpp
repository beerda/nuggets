#include <testthat.h>
#include "common.h"
#include "antichain/Node.h"
#include <iostream>

context("antichain/Node.h") {
    test_that("empty default node") {
        Node n;

        expect_true(n.getPredicate() == -1);
        expect_true(n.getDepth() == 0);
        expect_true(n.getPrefix().empty());
        expect_true(n.getChildren().empty());
    }

    test_that("initialized empty node") {
        Node n(10, 20, {1, 2, 5});

        expect_true(n.getPredicate() == 10);
        expect_true(n.getDepth() == 20);
        expect_true(n.getChildren().empty());
        expect_true(!n.getPrefix().empty());
        expect_true(n.getPrefix().size()== 3);
        expect_true(n.getPrefix().count(1) == 1);
        expect_true(n.getPrefix().count(2) == 1);
        expect_true(n.getPrefix().count(5) == 1);
    }

    test_that("insert nodes to root") {
        vector<int> foundPredicates;
        Node n;
        Node child;
        Condition c(unordered_set<int>({1, 2, 5}));
        n.insertAsChildren(c);

        expect_true(n.getChildren().size() == 1);
        child = n.getChildren().at(0);
        expect_true(child.getDepth() == 1);
        expect_true(child.getPrefix().size() == 0);
        foundPredicates.push_back(child.getPredicate());

        expect_true(child.getChildren().size() == 1);
        child = child.getChildren().at(0);
        expect_true(child.getDepth() == 2);
        expect_true(child.getPrefix().size() == 1);
        expect_true(child.getPrefix().count(foundPredicates[0]) == 1);
        foundPredicates.push_back(child.getPredicate());

        expect_true(child.getChildren().size() == 1);
        child = child.getChildren().at(0);
        expect_true(child.getDepth() == 3);
        expect_true(child.getPrefix().size() == 2);
        expect_true(child.getPrefix().count(foundPredicates[0]) == 1);
        expect_true(child.getPrefix().count(foundPredicates[1]) == 1);
        foundPredicates.push_back(child.getPredicate());

        expect_true(child.getChildren().size() == 0);

        bool found1 = false;
        bool found2 = false;
        bool found5 = false;
        expect_true(foundPredicates.size() == 3);
        for (int f : foundPredicates) {
            if (f == 1)
                found1 = true;
            if (f == 2)
                found2 = true;
            if (f == 5)
                found5 = true;
        }
        expect_true(found1);
        expect_true(found2);
        expect_true(found5);
    }
}
