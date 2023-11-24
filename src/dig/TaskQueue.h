#pragma once

#include <queue>
#include "Task.h"

using namespace std;


template <typename TASK>
class TaskQueue {
public:
    TaskQueue()
        : queue(TaskCompare())
    { }

    void add(const TASK& task)
    { queue.push(task); }

    bool empty() const
    { return queue.empty(); }

    TASK pop()
    {
        TASK task = queue.top();
        queue.pop();
        return task;
    }

    void clear()
    { queue = priority_queue<TASK, vector<TASK>, TaskCompare>(TaskCompare()); }

    static bool hasPriority(TASK& lhs, TASK& rhs)
    {
        // TODO: add better heuristics (e.g. based on parent support)
        return (lhs.getLength() < rhs.getLength());
    }

private:
    class TaskCompare {
    public:
        TaskCompare()
        { }

        bool operator() (TASK& lhs, TASK& rhs)
        { return !TaskQueue::hasPriority(lhs, rhs); }
    };

    priority_queue<TASK, vector<TASK>, TaskCompare> queue;
};
