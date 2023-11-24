#include <testthat.h>
#include "common.h"
#include "dig/Task.h"


using DataType = Data<BitsetBitChain, VectorNumChain<GOGUEN>>;
using TaskType = Task<DataType>;
using DualChainType = DataType::DualChainType;

context("dig/Task.h") {
    test_that("==") {
        TaskType tA({1, 2, 3}, {4, 5, 6}, {7, 8, 9});
        TaskType tB({1, 2, 3}, {4, 5, 6}, {7, 8, 9});
        tB.next();

        expect_true(tA == TaskType({1, 2, 3}, {4, 5, 6}, {7, 8, 9}));
        expect_true(tA != TaskType({2, 3}, {4, 5, 6}, {7, 8, 9}));
        expect_true(tA != TaskType({1, 2, 3}, {4, 6}, {7, 8, 9}));
        expect_true(tA != TaskType({1, 2, 3}, {4, 5, 6}, {7, 8}));
        expect_true(tA != tB);
    }

    test_that("getPrefix") {
        TaskType t({0, 1, 2}, {10, 11, 12}, {5, 6});
        expect_true(t.getPrefix() == set<int>({0, 1, 2}));
    }

    test_that("getAvailable") {
        TaskType t({0, 1, 2}, {10, 11, 12}, {5, 6});
        expect_true(t.getAvailable() == vector<int>({10, 11, 12}));
    }

    test_that("getSoFar") {
        TaskType t({0, 1, 2}, {10, 11, 12}, {5, 6});
        expect_true(t.getSoFar() == vector<int>({5, 6}));
        expect_true(t.hasSoFar());
    }

    test_that("getLength & empty") {
        TaskType empty;
        TaskType t({0, 1, 2}, {10, 11, 12}, {5, 6});
        TaskType t0({1, 3, 5});
        TaskType t1({}, {10, 11, 12}, {5, 6});

        expect_true(t.getLength() == 4);
        expect_true(t0.getLength() == 0);
        expect_true(t1.getLength() == 1);

        expect_true(empty.empty());
        expect_true(!t.empty());
        expect_true(!t0.empty());
        expect_true(!t1.empty());

    }

    test_that("predicate enumeration") {
        TaskType t({0, 1, 2}, {10, 11, 12}, {5, 6});

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

    test_that("constructor n") {
        TaskType tn(5);
        expect_true(tn.getPrefix().size() == 0);
        expect_true(tn.getAvailable().size() == 0);
        expect_true(tn.getSoFar() == vector<int>({0, 1, 2, 3, 4}));
        expect_true(tn.getLength() == 0);
        expect_false(tn.hasPredicate());
    }

    test_that("createChild") {
        TaskType t({0, 1, 2}, {10, 11, 12}, {5, 6});

        TaskType ch = t.createChild();
        expect_true(ch.getPrefix() == set<int>({0, 1, 2, 10}));
        expect_true(ch.getAvailable() == vector<int>({5, 6}));

        t.next();
        t.next();
        t.next();
        ch = t.createChild();
        expect_true(ch.getPrefix() == set<int>({0, 1, 2}));
        expect_true(ch.getAvailable() == vector<int>({5, 6}));
    }

    test_that("updateChain") {
        LogicalVector data1(10);
        LogicalVector data2(10);
        NumericVector data3(10);
        for (int i = 0; i < data1.size(); i++) {
            data1[i] = (i == 2 || i == 5);
            data2[i] = (i == 2 || i == 6);
            data3[i] = i / 10.0;
        }

        DataType data;
        data.addChain(data1);
        data.addChain(data2);
        data.addChain(data3);

        TaskType t({0, 1, 2}); // empty task with soFar: 0,1,2
        expect_true(t.getChain().empty());
        expect_true(t.getPrefixChain().empty());

        t.updateChain(data); // chain not changed
        expect_true(t.getChain().empty());
        expect_true(t.getPrefixChain().empty());

        t = t.createChild();
        expect_true(t.getChain().empty());
        expect_true(t.getPrefixChain().empty());

        t.updateChain(data);
        expect_true(t.getChain() == data.getChain(0));
        expect_true(t.getPrefixChain().empty());

        t.putCurrentToSoFar(); // 0
        t.next();
        t.updateChain(data);
        expect_true(t.getChain() == data.getChain(1));
        expect_true(t.getPrefixChain().empty());

        t.putCurrentToSoFar(); // 1
        t.next();
        t.updateChain(data);
        expect_true(t.getChain() == data.getChain(2));
        expect_true(t.getPrefixChain().empty());

        t = t.createChild(); // prefix: 2 current: 0
        expect_true(t.getChain().empty());
        expect_true(t.getPrefixChain() == data.getChain(2));

        t.updateChain(data);
        DualChainType newChain = data.getChain(0);
        newChain.toNumeric();
        newChain.conjunctWith(data.getChain(2));
        expect_true(t.getChain() == newChain);
        expect_true(t.getPrefixChain() == data.getChain(2));
    }
}
