#include <testthat.h>
#include "TaskQueue.hpp"

context("TaskQueue.hpp") {
    test_that("shorter has priority over longer") {
        Task t0({}, {10, 11, 12});
        Task t1({2, 3}, {10, 11, 12});

        expect_true(TaskQueue::hasPriority(t0, t1));
        expect_false(TaskQueue::hasPriority(t1, t0));
    }
}
