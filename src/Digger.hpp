#pragma once

#include <iostream>
#include <functional>
#include "Data.hpp"
#include "TaskQueue.hpp"
#include "Filter.hpp"
#include "Argumentator.hpp"


class Digger {
public:
    Digger(Data& data, const cpp11::function fun)
        : data(data), initialTask(data.size()), queue(), func(fun)
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
                updateChain(task);
                if (!isPrunable(task)) {
                    if (isStorable(task)) {
                        store(task);
                    }
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

    void setChainsNeeded()
    { chainsNeeded = true; }

    writable::list getResult() const
    { return result; }

private:
    Data& data;
    Task initialTask;
    TaskQueue queue;
    cpp11::function func;
    vector<Filter*> filters;
    vector<Argumentator*> argumentators;
    writable::list result;
    bool chainsNeeded = false;

    void updateChain(Task& task) const
    {
        if (chainsNeeded)
            task.updateChain(data);
    }

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

    bool isStorable(const Task& task) const
    {
        for (const Filter* e : filters)
            if (!e->isStorable(task))
                return false;

        return true;
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
