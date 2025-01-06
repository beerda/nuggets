#include <testthat.h>
#include "common.h"
#include "dig/TaskQueue.h"
#include "dig/BitChain.h"
#include "dig/VectorNumChain.h"

using DataType = Data<BitChain, VectorNumChain<GOGUEN>>;
using TaskType = Task<DataType>;

context("dig/TaskQueue.h") {
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

        t = queue.pop();
        expect_false(queue.empty());

        t = queue.pop();
        expect_true(queue.empty());
    }
}
