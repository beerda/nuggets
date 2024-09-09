#include <testthat.h>
#include "common.h"
#include "dig/TaskQueue.h"
#include "dig/BitChain.h"
#include "dig/VectorNumChain.h"

using DataType = Data<BitChain, VectorNumChain<GOGUEN>>;
using TaskType = Task<DataType>;

context("dig/TaskQueue.h") {
    test_that("shorter has priority over longer") {
        TaskType t0(Iterator({}, {10, 11, 12}), Iterator());
        TaskType t1(Iterator({2, 3}, {10, 11, 12}), Iterator());

        expect_true(TaskQueue<TaskType>::hasPriority(t0, t1));
        expect_false(TaskQueue<TaskType>::hasPriority(t1, t0));
    }

    test_that("push & pop") {
        TaskQueue<TaskType> queue;
        TaskType t0(Iterator({}, {1, 2, 3}), Iterator());
        TaskType t1(Iterator({5}, {1, 2, 3}), Iterator());
        TaskType t2(Iterator({5, 6}, {1, 2, 3}), Iterator());

        expect_true(queue.empty());

        queue.add(t2);
        expect_false(queue.empty());

        queue.add(t0);
        expect_false(queue.empty());

        queue.add(t1);
        expect_false(queue.empty());

        TaskType t = queue.pop();
        expect_false(queue.empty());
        expect_true(t == t0);
        expect_true(t != t1);
        expect_true(t != t2);

        t = queue.pop();
        expect_false(queue.empty());
        expect_true(t != t0);
        expect_true(t == t1);
        expect_true(t != t2);

        t = queue.pop();
        expect_true(queue.empty());
        expect_true(t != t0);
        expect_true(t != t1);
        expect_true(t == t2);
    }
}
