#pragma once

#include <queue>
#include "Task.hpp"

using namespace std;


class TaskQueue {
public:
    TaskQueue()
        : queue(TaskCompare())
    { }

    void add(Task& task)
    { queue.push(task); }

    bool empty() const
    { return queue.empty(); }

    Task pop()
    {
        Task task = queue.top();
        queue.pop();
        return task;
    }

    static bool hasPriority(Task& lhs, Task& rhs)
    {
        // TODO: add better heuristics (e.g. based on parent support)
        return (lhs.getLength() < rhs.getLength());
    }

private:
    class TaskCompare {
    public:
        TaskCompare()
        { }

        bool operator() (Task& lhs, Task& rhs)
        { return !TaskQueue::hasPriority(lhs, rhs); }
    };

    priority_queue<Task, vector<Task>, TaskCompare> queue;
};
