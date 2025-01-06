#pragma once

#include <queue>
#include "Task.h"

using namespace std;


template <typename TASK>
class TaskQueue {
public:
    TaskQueue()
        : q(TaskCompare())
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
    { q = priority_queue<TASK, vector<TASK>, TaskCompare>(TaskCompare()); }

    /// Returns true if the first task has higher priority than the second one.
    static bool hasPriority(TASK& lhs, TASK& rhs)
    {
        if (lhs.getConditionIterator().getLength() > rhs.getConditionIterator().getLength()) {
            return true;
        }
        else if (lhs.getConditionIterator().getLength() == rhs.getConditionIterator().getLength()) {
            return lhs.getConditionIterator().getSoFar().size() < rhs.getConditionIterator().getSoFar().size();
        }

        return false;
    }

private:
    class TaskCompare {
    public:
        TaskCompare()
        { }

        bool operator() (TASK& lhs, TASK& rhs)
        { return !TaskQueue::hasPriority(lhs, rhs); }
    };

    priority_queue<TASK, vector<TASK>, TaskCompare> q;
};
