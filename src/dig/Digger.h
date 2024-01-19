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

    Digger(DataType& data, int threads)
        : data(data), initialTask(data.size()), queue(), allThreads(threads)
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
        initializeRun();

        #if defined(_OPENMP)
            #pragma omp parallel num_threads(allThreads) default(shared)
        #endif
        while (!workDone()) {
            TaskType task;
            if (receiveTask(task)) {
                processTask(task);
                taskFinished(task);
            }
        }
    }

    void setChainsNeeded()
    { chainsNeeded = true; }

    vector<ArgumentValues> getResult() const
    { return result; }

private:
    DataType& data;
    TaskType initialTask;
    TaskQueue<TaskType> queue;
    vector<FilterType*> filters;
    vector<ArgumentatorType*> argumentators;
    vector<ArgumentValues> result;
    int workingThreads;
    int allThreads;

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

    void store(const TaskType& task)
    {
        #if defined(_OPENMP)
            #pragma omp critical(TASK_QUEUE)
        #endif
        {
            //cout << "storing: " + task.toString() << endl;
            ArgumentValues args;
            for (const ArgumentatorType* a : argumentators) {
                a->prepare(args, task);
            }
            result.push_back(args);
        }
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

        #if defined(_OPENMP)
            #pragma omp critical(TASK_QUEUE)
        #endif
        {
            done = queue.empty() && workingThreads <= 0;
        }

        return done;
    }

    bool receiveTask(TaskType& task)
    {
        bool received = false;

        #if defined(_OPENMP)
            #pragma omp critical(TASK_QUEUE)
        #endif
        {
            if (!queue.empty()) {
                task = queue.pop();
                //cout << "receiving: " + task.toString() << endl;
                workingThreads++;
                received = true;
            }
        }

        return received;
    }

    void sendTask(const TaskType& task)
    {
        #if defined(_OPENMP)
            #pragma omp critical(TASK_QUEUE)
        #endif
        {
            //cout << "sending: " + task.toString() << endl;
            queue.add(task);
        }
    }

    void processTask(TaskType& task)
    {
        //cout << "processing: " + task.toString() << endl;
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

    void taskFinished(TaskType& task)
    {
        #if defined(_OPENMP)
            #pragma omp critical(TASK_QUEUE)
        #endif
        {
            //cout << "finished: " + task.toString() << endl;
            workingThreads--;
        }
    }
};
