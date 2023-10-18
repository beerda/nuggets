#include <testthat.h>
#include "common.h"
#include "TaskQueue.h"

context("TaskQueue.h") {
    test_that("shorter has priority over longer") {
        Task t0({}, {10, 11, 12});
        Task t1({2, 3}, {10, 11, 12});

        expect_true(TaskQueue::hasPriority(t0, t1));
        expect_false(TaskQueue::hasPriority(t1, t0));
    }

    test_that("push & pop") {
        TaskQueue queue;
        Task t0({}, {1, 2, 3});
        Task t1({5}, {1, 2, 3});
        Task t2({5, 6}, {1, 2, 3});

        expect_true(queue.empty());

        queue.add(t2);
        expect_false(queue.empty());

        queue.add(t0);
        expect_false(queue.empty());

        queue.add(t1);
        expect_false(queue.empty());

        Task t = queue.pop();
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
