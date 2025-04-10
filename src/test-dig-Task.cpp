#include <testthat.h>
#include "common.h"
#include "dig/Task.h"
#include "dig/BitChain.h"
#include "dig/VectorNumChain.h"


using DataType = Data<BitChain, VectorNumChain<GOGUEN>>;
using TaskType = Task<DataType>;
using DualChainType = DataType::DualChainType;

context("dig/Task.h") {
    test_that("createChild") {
        TaskType* t = new TaskType(Iterator({0, 1, 2}, {10, 11, 12}, {5, 6}), Iterator());

        TaskType* ch = t->createChild();
        expect_true(ch->getConditionIterator().getPrefix() == vector<int>({0, 1, 2, 10}));
        expect_true(ch->getConditionIterator().getAvailable() == vector<int>({5, 6}));
        delete ch;

        t->getMutableConditionIterator().next();
        t->getMutableConditionIterator().next();
        t->getMutableConditionIterator().next();

        ch = t->createChild();
        expect_true(ch->getConditionIterator().getPrefix() == vector<int>({0, 1, 2}));
        expect_true(ch->getConditionIterator().getAvailable() == vector<int>({5, 6}));
        delete ch;
        delete t;
    }

    test_that("updatePositiveChain") {
        LogicalVector data1(10);
        LogicalVector data2(10);
        NumericVector data3(10);
        for (int i = 0; i < data1.size(); i++) {
            data1[i] = (i == 2 || i == 5);
            data2[i] = (i == 2 || i == 6);
            data3[i] = i / 10.0;
        }

        DataType data(data1.size());
        data.addChain(data1, "d1", true, true);
        data.addChain(data2, "d2", true, true);
        data.addChain(data3, "d3", true, true);

        TaskType* t = new TaskType(Iterator({0, 1, 2}), Iterator()); // empty task with soFar: 0,1,2
        expect_true(t->getPositiveChain().empty());
        expect_true(t->getPrefixChain().empty());

        t->updatePositiveChain(data); // chain not changed
        expect_true(t->getPositiveChain().empty());
        expect_true(t->getPrefixChain().empty());

        TaskType* ch = t->createChild();
        delete t;
        t = ch;
        expect_true(t->getPositiveChain().empty());
        expect_true(t->getPrefixChain().empty());

        t->updatePositiveChain(data);
        expect_true(t->getPositiveChain() == data.getPositiveChain(0));
        expect_true(t->getPrefixChain().empty());

        t->getMutableConditionIterator().putCurrentToSoFar(); // 0
        t->getMutableConditionIterator().next();
        t->updatePositiveChain(data);
        expect_true(t->getPositiveChain() == data.getPositiveChain(1));
        expect_true(t->getPrefixChain().empty());

        t->getMutableConditionIterator().putCurrentToSoFar(); // 1
        t->getMutableConditionIterator().next();
        t->updatePositiveChain(data);
        expect_true(t->getPositiveChain() == data.getPositiveChain(2));
        expect_true(t->getPrefixChain().empty());

        ch = t->createChild(); // prefix: 2 current: 0
        delete t;
        t = ch;
        expect_true(t->getPositiveChain().empty());
        expect_true(t->getPrefixChain() == data.getPositiveChain(2));

        t->updatePositiveChain(data);
        DualChainType newChain = data.getPositiveChain(0);
        newChain.toNumeric();
        newChain.conjunctWith(data.getPositiveChain(2));
        expect_true(t->getPositiveChain() == newChain);
        expect_true(t->getPrefixChain() == data.getPositiveChain(2));

        delete t;
    }
}
