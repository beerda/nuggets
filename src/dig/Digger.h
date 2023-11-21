#pragma once

#include <functional>
#include "Data.h"
#include "TaskQueue.h"
#include "Filter.h"
#include "Argumentator.h"


class Digger {
public:
    Digger(Data& data, const Function fun)
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
        Task task;

        initializeRun();
        while (!workDone()) {
            if (receiveTask(task)) {
                processTask(task);
                taskFinished();
            }
        }
    }

    void setChainsNeeded()
    { chainsNeeded = true; }

    List getResult() const
    { return result; }

private:
    Data& data;
    Task initialTask;
    TaskQueue queue;
    Function func;
    vector<Filter*> filters;
    vector<Argumentator*> argumentators;
    List result;
    int workingThreads;

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

    List prepareArguments(const Task& task) const
    {
        List result;

        for (const Argumentator* a : argumentators)
            a->prepare(result, task);

        return result;
    }

    void store(const Task& task)
    {
        List args = prepareArguments(task);
        result.push_back(func(args));
    }

    void initializeRun()
    {
        queue.clear();
        queue.add(initialTask);
        workingThreads = 0;
    }

    bool workDone()
    {
        bool done;

        done = queue.empty() && workingThreads <= 0;

        return done;
    }

    bool receiveTask(Task& task)
    {
        bool received = false;

        {
            if (!queue.empty()) {
                task = queue.pop();
                workingThreads++;
                received = true;
            }
        }

        return received;
    }

    void sendTask(const Task& task)
    {
        {
            queue.add(task);
        }
    }

    void processTask(Task& task)
    {
        Task child;

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
            sendTask(task);
        }
        if (!child.empty()) {
            sendTask(child);
        }
    }

    void taskFinished()
    {
        workingThreads--;
    }
};
