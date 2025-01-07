#pragma once

#include <stack>
#include <queue>
#include <memory>
#include "Task.h"

using namespace std;

//*
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


/*/


template <typename TASK>
class TaskSequence {
public:
    TaskSequence()
        : q(TaskCompare())
    { }

    void add(const TASK& task)
    { q.push(make_shared<TASK>(task)); }

    bool empty() const
    { return q.empty(); }

    size_t size() const
    { return q.size(); }

    TASK pop()
    {
        TASK task = *(q.top());
        q.pop();
        return task;
    }

    void clear()
    { q = priority_queue<shared_ptr<TASK>, vector<shared_ptr<TASK>>, TaskCompare>(TaskCompare()); }

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

        bool operator() (const shared_ptr<TASK>& lhs, const shared_ptr<TASK> rhs)
        { return !TaskSequence::hasPriority(*lhs, *rhs); }
    };

    priority_queue<shared_ptr<TASK>, vector<shared_ptr<TASK>>, TaskCompare> q;
};

// */
