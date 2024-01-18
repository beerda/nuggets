#pragma once

#include <functional>
#include "Data.h"
#include "TaskQueue.h"
#include "Filter.h"
#include "Argumentator.h"


template <typename DATA>
class Digger {
public:
    using DataType = DATA;
    using TaskType = Task<DATA>;
    using FilterType = Filter<TaskType>;
    using ArgumentatorType = Argumentator<TaskType>;

    Digger(DataType& data)
        : data(data), initialTask(data.size()), queue()
    { }

    virtual ~Digger()
    {
        for (FilterType* f : filters)
            delete f;

        for (ArgumentatorType* a : argumentators)
            delete a;
    }

    void addFilter(FilterType* filter)
    { filters.push_back(filter); }

    void addArgumentator(ArgumentatorType* argumentator)
    { argumentators.push_back(argumentator); }

    void run()
    {
        TaskType task;

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
    DataType& data;
    TaskType initialTask;
    TaskQueue<TaskType> queue;
    vector<FilterType*> filters;
    vector<ArgumentatorType*> argumentators;
    List result;
    int workingThreads;

    bool chainsNeeded = false;

    void updateChain(TaskType& task) const
    {
        if (chainsNeeded)
            task.updateChain(data);
    }

    bool isRedundant(const TaskType& task) const
    {
        for (const FilterType* e : filters)
            if (e->isRedundant(task))
                return true;

        return false;
    }

    bool isPrunable(const TaskType& task) const
    {
        for (const FilterType* e : filters)
            if (e->isPrunable(task))
                return true;

        return false;
    }

    bool isStorable(const TaskType& task) const
    {
        for (const FilterType* e : filters)
            if (!e->isStorable(task))
                return false;

        return true;
    }

    bool isExtendable(const TaskType& task) const
    {
        for (const FilterType* e : filters)
            if (!e->isExtendable(task))
                return false;

        return true;
    }

    List prepareArguments(const TaskType& task) const
    {
        List result;

        for (const ArgumentatorType* a : argumentators)
            a->prepare(result, task);

        return result;
    }

    void store(const TaskType& task)
    { result.push_back(prepareArguments(task)); }

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

    bool receiveTask(TaskType& task)
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

    void sendTask(const TaskType& task)
    {
        {
            queue.add(task);
        }
    }

    void processTask(TaskType& task)
    {
        TaskType child;

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
