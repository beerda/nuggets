#pragma once

#include <iostream>
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
            Task child;
            Task task = queue.pop();
            //cout << "processing: " << task.toString() << "\n";

            if (!isRedundant(task)) {
                //updateChain(task);
                //computeStatistics(task);
                if (!isPrunable(task)) {
                    store(task);
                    if (isExtendable(task)) {
                        if (task.hasSoFar()) {
                            child = task.createChild();
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
            if (!child.empty()) {
                queue.add(child);
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

    void store(const Task& task)
    {
        cout << "storing: " << task.toString() << "\n";
    }
};
