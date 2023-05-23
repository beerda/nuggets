#pragma once

#include <iostream>
#include <functional>
#include "Data.hpp"
#include "TaskQueue.hpp"
#include "Filter.hpp"
#include "Argumentator.hpp"


class Digger {
public:
    Digger(const Config& config, const Data& data, const cpp11::function fun)
        : config(config), data(data), initialTask(data.size()), queue(), func(fun)
    { }

    virtual ~Digger()
    {
        for (Filter* f : filters)
            delete f;

        for (Argumentator* a : argumentators)
            delete a;
    }

    void addFilter(Filter* filter)
    { filters.push_back(filter); }

    void addArgumentator(Argumentator* argumentator)
    { argumentators.push_back(argumentator); }

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

    writable::list getResult() const
    { return result; }

private:
    Config config;
    Data data;
    Task initialTask;
    TaskQueue queue;
    cpp11::function func;
    vector<Filter*> filters;
    vector<Argumentator*> argumentators;
    writable::list result;

    bool isRedundant(const Task& task) const
    {
        for (const Filter* e : filters)
            if (e->isRedundant(task))
                return true;

        return false;
    }

    bool isPrunable(const Task& task) const
    {
        for (const Filter* e : filters)
            if (e->isPrunable(task))
                return true;

        return false;
    }

    bool isExtendable(const Task& task) const
    {
        for (const Filter* e : filters)
            if (!e->isExtendable(task))
                return false;

        return true;
    }

    list prepareArguments(const Task& task) const
    {
        writable::list result;

        for (const Argumentator* a : argumentators)
            a->prepare(result, task);

        return result;
    }

    void store(const Task& task)
    {
        list args = prepareArguments(task);
        result.push_back(func(args));
    }
};
