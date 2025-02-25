#include <testthat.h>
#include "common.h"
#include "dig/TautologyTree.h"


context("dig/TautologyTree.h") {
    test_that("empty everything") {
        TautologyTree tree({}, {});
        const TautologyTree::Node* root = tree.getRoot();
        expect_true(root != nullptr);
        expect_true(root->consequents.size() == 0);
        expect_true(root->nChildren() == 0);
        expect_true(root->children.size() == 0);
    }

    test_that("empty tree") {
        vector<int> predicates = {1, 2, 3, 10};
        vector<int> consequents = {11, 12, 13, 14, 15, 16};
        TautologyTree tree(predicates, consequents);

        const TautologyTree::Node* root = tree.getRoot();
        expect_true(root != nullptr);
        expect_true(root->consequents.size() == 0);
        expect_true(root->nChildren() == 0);
        expect_true(root->children.size() == 4);

        // deduction
        vector<int> res;
        res = tree.deduceConsequentsByRevSorted({}, 1);
        expect_true(res.size() == 0);
        res = tree.deduceConsequentsByRevSorted({3, 2}, 1);
        expect_true(res.size() == 0);
    }

    test_that("empty antecedent") {
        vector<int> predicates = {1, 2, 3, 10};
        vector<int> consequents = {11, 12, 13, 14, 15, 16};
        TautologyTree tree(predicates, consequents);
        tree.addTautology({}, 11);

        const TautologyTree::Node* root = tree.getRoot();
        expect_true(root != nullptr);
        expect_true(root->consequents.size() == 1);
        expect_true(root->consequents[0] == 11);
        expect_true(root->nChildren() == 0);
        expect_true(root->children.size() == 4);

        // deduction
        vector<int> res;
        res = tree.deduceConsequentsByRevSorted({}, 1);
        expect_true(res.size() == 1);
        expect_true(res[0] == 11);
        res = tree.deduceConsequentsByRevSorted({3, 2}, 1);
        expect_true(res.size() == 1);
        expect_true(res[0] == 11);
    }

    test_that("antecedent size 1") {
        vector<int> predicates = {1, 2, 3, 10};
        vector<int> consequents = {11, 12, 13, 14, 15, 16};
        TautologyTree tree(predicates, consequents);
        tree.addTautology({2}, 12);

        const TautologyTree::Node* root = tree.getRoot();
        expect_true(root != nullptr);
        expect_true(root->consequents.size() == 0);
        expect_true(root->nChildren() == 1);
        expect_true(root->children.size() == 4);

        const TautologyTree::Node* node = root->children[1]; // 1 is the index of predicate "2"
        expect_true(node != nullptr);
        expect_true(node->consequents.size() == 1);
        expect_true(node->consequents[0] == 12);
        expect_true(node->nChildren() == 0);
        expect_true(node->children.size() == 1); // may contain only predicate "1" at index 0 as a child

        // deduction
        vector<int> res;
        res = tree.deduceConsequentsByRevSorted({}, 1);
        expect_true(res.size() == 0);
        res = tree.deduceConsequentsByRevSorted({}, 2);
        expect_true(res.size() == 1);
        expect_true(res[0] == 12);
        res = tree.deduceConsequentsByRevSorted({1}, 2);
        expect_true(res.size() == 1);
        expect_true(res[0] == 12);
    }

    test_that("antecedent size 2") {
        vector<int> predicates = {1, 2, 3, 10};
        vector<int> consequents = {11, 12, 13, 14, 15, 16};
        TautologyTree tree(predicates, consequents);
        tree.addTautology({1, 3}, 13);

        const TautologyTree::Node* root = tree.getRoot();
        expect_true(root != nullptr);
        expect_true(root->consequents.size() == 0);
        expect_true(root->nChildren() == 1);
        expect_true(root->children.size() == 4);

        const TautologyTree::Node* node1 = root->children[2]; // 2 is the index of predicate "3"
        expect_true(node1 != nullptr);
        expect_true(node1->consequents.size() == 0);
        expect_true(node1->nChildren() == 1);
        expect_true(node1->children.size() == 2);

        const TautologyTree::Node* node2 = node1->children[0]; // 0 is the index of predicate "1"
        expect_true(node2 != nullptr);
        expect_true(node2->consequents.size() == 1);
        expect_true(node2->consequents[0] == 13);
        expect_true(node2->nChildren() == 0);
        expect_true(node2->children.size() == 0);

        // deduction
        vector<int> res;
        res = tree.deduceConsequentsByRevSorted({}, 1);
        expect_true(res.size() == 0);
        res = tree.deduceConsequentsByRevSorted({}, 3);
        expect_true(res.size() == 0);
        res = tree.deduceConsequentsByRevSorted({2}, 3);
        expect_true(res.size() == 0);
        res = tree.deduceConsequentsByRevSorted({2, 1}, 3);
        expect_true(res.size() == 1);
        expect_true(res[0] == 13);
        res = tree.deduceConsequentsByRevSorted({1}, 3);
        expect_true(res.size() == 1);
        expect_true(res[0] == 13);
    }

    test_that("3 tautologies") {
        vector<int> predicates = {1, 2, 3, 10};
        vector<int> consequents = {11, 12, 13, 14, 15, 16};
        TautologyTree tree(predicates, consequents);
        tree.addTautology({3, 10}, 14);
        tree.addTautology({1, 2, 10}, 15);
        tree.addTautology({10}, 16);

        const TautologyTree::Node* root = tree.getRoot();
        expect_true(root != nullptr);
        expect_true(root->consequents.size() == 0);
        expect_true(root->nChildren() == 1);
        expect_true(root->children.size() == 4);

        const TautologyTree::Node* node1 = root->children[3]; // 3 is the index of predicate "10"
        expect_true(node1 != nullptr);
        expect_true(node1->consequents.size() == 1);
        expect_true(node1->consequents[0] == 16);
        expect_true(node1->nChildren() == 2);
        expect_true(node1->children.size() == 3);

        const TautologyTree::Node* node11 = node1->children[2]; // 2 is the index of predicate "3"
        expect_true(node11 != nullptr);
        expect_true(node11->consequents.size() == 1);
        expect_true(node11->consequents[0] == 14);
        expect_true(node11->nChildren() == 0);
        expect_true(node11->children.size() == 2);

        const TautologyTree::Node* node12 = node1->children[1]; // 1 is the index of predicate "2"
        expect_true(node12 != nullptr);
        expect_true(node12->consequents.size() == 0);
        expect_true(node12->nChildren() == 1);
        expect_true(node12->children.size() == 1);

        const TautologyTree::Node* node2 = node12->children[0]; // 0 is the index of predicate "1"
        expect_true(node2 != nullptr);
        expect_true(node2->consequents.size() == 1);
        expect_true(node2->consequents[0] == 15);
        expect_true(node2->nChildren() == 0);
        expect_true(node2->children.size() == 0);

        // deduction
        vector<int> res;
        res = tree.deduceConsequentsByRevSorted({}, 1);
        expect_true(res.size() == 0);
        res = tree.deduceConsequentsByRevSorted({}, 10);
        expect_true(res.size() == 1);
        expect_true(res[0] == 16);
        res = tree.deduceConsequentsByRevSorted({2}, 10);
        expect_true(res.size() == 1);
        expect_true(res[0] == 16);
        res = tree.deduceConsequentsByRevSorted({3}, 10);
        expect_true(res.size() == 2);
        expect_true(res[0] == 16);
        expect_true(res[1] == 14);
        res = tree.deduceConsequentsByRevSorted({2, 1}, 10);
        expect_true(res.size() == 2);
        expect_true(res[0] == 16);
        expect_true(res[1] == 15);
        res = tree.deduceConsequentsByRevSorted({3, 2, 1}, 10);
        expect_true(res.size() == 3);
        expect_true(res[0] == 16);
        expect_true(res[1] == 14);
        expect_true(res[2] == 15);
    }
}
