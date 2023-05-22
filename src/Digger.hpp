#pragma once

#include "Data.hpp"
#include "TaskQueue.hpp"
#include "Extension.hpp"


class Digger {
public:
    Digger(Data& data, Task& task)
        : data(data), initialTask(task), queue()
    { }

    void addExtension(Extension& extension)
    { extensions.push_back(extension); }

    void run()
    {
        queue.add(initialTask);
        while (!queue.empty()) {
            Task task = queue.pop();

            if (!isRedundant(task)) {
                //updateChain(task);
                //computeStatistics(task);
                if (!isPrunable(task)) {
                    //storeCandidate(task);
                    if (isExtendable(task)) {
                        if (task.hasSoFar()) {
                            Task child = task.createChild();
                        }
                        if (task.hasPredicate()) {
                            task.putCurrentToSoFar();
                        }
                    }
                }
            }

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
    vector<Extension> extensions;

    bool isRedundant(const Task& task) const
    {
        for (const Extension& e : extensions)
            if (e.isRedundant(task))
                return true;

        return false;
    }

    bool isPrunable(const Task& task) const
    {
        for (const Extension& e : extensions)
            if (e.isPrunable(task))
                return true;

        return false;
    }

    bool isExtendable(const Task& task) const
    {
        for (const Extension& e : extensions)
            if (!e.isExtendable(task))
                return false;

        return true;
    }
};
