#include <testthat.h>
#include "common.h"
#include "dig/TaskSequence.h"
#include "dig/BitChain.h"
#include "dig/VectorNumChain.h"

using DataType = Data<BitChain, VectorNumChain<GOGUEN>>;
using TaskType = Task<DataType>;

context("dig/TaskSequence.h") {
    test_that("push & pop") {
        TaskSequence<TaskType> sequence;
        TaskType t0(Iterator({}, {1, 2, 3}), Iterator());
        TaskType t1(Iterator({5}, {1, 2, 3}), Iterator());
        TaskType t2(Iterator({5, 6}, {1, 2, 3}), Iterator());

        expect_true(sequence.empty());

        sequence.add(t2);
        expect_false(sequence.empty());

        sequence.add(t0);
        expect_false(sequence.empty());

        sequence.add(t1);
        expect_false(sequence.empty());

        TaskType t = sequence.pop();
        expect_false(sequence.empty());

        t = sequence.pop();
        expect_false(sequence.empty());

        t = sequence.pop();
        expect_true(sequence.empty());
    }
}
