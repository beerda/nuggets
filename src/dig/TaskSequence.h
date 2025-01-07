#pragma once

#include <stack>
#include "Task.h"

using namespace std;


/// LIFO stack - accordingly to performance tests, it is not worth implementing
/// priority queue as the overhead of sorting tasks by priority makes the resulting
/// run times much worse.
template <typename TASK>
class TaskSequence {
public:
    TaskSequence()
    { }

    void add(const TASK& task)
    { q.push(task); }

    bool empty() const
    { return q.empty(); }

    size_t size() const
    { return q.size(); }

    TASK pop()
    {
        TASK task = q.top();
        q.pop();
        return task;
    }

    void clear()
    { q = stack<TASK>(); }

private:
    stack<TASK> q;
};

// */
