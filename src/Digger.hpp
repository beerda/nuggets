#pragma once

#include "Data.hpp"
#include "TaskQueue.hpp"


class Digger {
public:
    Digger(Data& data, Task& task)
        : data(data), initialTask(task), queue()
    { }

    void run()
    {
        queue.add(initialTask);
        while (!queue.empty()) {
            Task task = queue.pop();

            /*
            if (!isRedundant(task)) {
                updateChain(task);
                computeStatistics(task);
                if (!isPrunable(task)) {
                    storeCandidate(task);
                    if (isExtendable(task)) {
                        if (task.hasSoFar()) {
                            Task child = createChildTask(task);
                        }
                        if (task.hasPredicate()) {
                            task.putCurrentToSoFar();
                        }
                    }
                }
            }

             */
            task.next();
            if (task.hasPredicate()) {
                queue.add(task);
            }
        }
    }

private:
    Data data;
    Task initialTask;
    TaskQueue queue;

    bool isRedundant(const Task& task) const
    { }

    bool isPrunable(const Task& task) const
    { }

    bool isExtendable(const Task& task) const
    { }
};
