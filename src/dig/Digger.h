#pragma once

//#include <omp.h>
#include <mutex>
#include <condition_variable>

#include "Data.h"
#include "Config.h"
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

    Digger(DataType& data, const Config& config)
        : data(data),
          initialTask(Iterator(data.size()),          // condition predicates to "soFar"
                      Iterator({}, data.fociSize())), // focus predicates to "available"
          queue(),
          allThreads(config.getThreads())
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
        {
            while (!workDone()) {
                TaskType task;
                if (receiveTask(task)) {
                    processTask(task);
                    taskFinished(task);
                }
            }
            //cout << omp_get_thread_num() << "exit" << endl;
            condVar.notify_all();
        }
    }

    void setPositiveConditionChainsNeeded()
    { positiveConditionChainsNeeded = true; }

    void setNegativeConditionChainsNeeded()
    {
        setPositiveConditionChainsNeeded(); // cannot compute negative condition chains without positive condition chains
        negativeConditionChainsNeeded = true;
    }

    void setPpFocusChainsNeeded()
    {
        setPositiveConditionChainsNeeded(); // cannot compute focus chains without condition chains
        ppFocusChainsNeeded = true;
    }

    void setNpFocusChainsNeeded()
    {
        setNegativeConditionChainsNeeded();
        npFocusChainsNeeded = true;
    }

    void setPnFocusChainsNeeded()
    {
        setPositiveConditionChainsNeeded();
        pnFocusChainsNeeded = true;
    }

    void setNnFocusChainsNeeded()
    {
        setNegativeConditionChainsNeeded();
        nnFocusChainsNeeded = true;
    }

    bool isNegativeFociChainsNeeded() const
    { return npFocusChainsNeeded || pnFocusChainsNeeded || nnFocusChainsNeeded; }

    vector<ArgumentValues> getResult() const
    { return result; }

private:
    DataType& data;
    TaskType initialTask;
    TaskQueue<TaskType> queue;
    vector<FilterType*> filters;
    vector<ArgumentatorType*> argumentators;
    vector<ArgumentValues> result;
    bool positiveConditionChainsNeeded = false;
    bool negativeConditionChainsNeeded = false;
    bool ppFocusChainsNeeded = false;
    bool npFocusChainsNeeded = false;
    bool pnFocusChainsNeeded = false;
    bool nnFocusChainsNeeded = false;

    int workingThreads;
    int allThreads;
    mutex queueMutex;
    mutex resultMutex;
    condition_variable condVar;


    void initializeRun()
    {
        queue.clear();
        queue.add(initialTask);
        workingThreads = 0;
    }

    bool workDone()
    {
        unique_lock lock(queueMutex);
        //cout << omp_get_thread_num() << "workDone" << endl;
        return queue.empty() && workingThreads <= 0;
    }

    bool receiveTask(TaskType& task)
    {
        unique_lock lock(queueMutex);
        //cout << omp_get_thread_num() << "receiveTask" << endl;
        while (queue.empty() && workingThreads > 0) {
            //cout << omp_get_thread_num() << "waiting" << endl;
            condVar.wait(lock);
        }

        //cout << omp_get_thread_num() << "continue" << endl;
        bool received = false;
        if (!queue.empty()) {
            task = queue.pop();
            //cout << "receiving: " + task.toString() << endl;
            workingThreads++;
            received = true;
        }

        return received;
    }

    void sendTask(const TaskType& task)
    {
        unique_lock lock(queueMutex);
        //cout << omp_get_thread_num() << "sendTask" << endl;
        //cout << "sending: " + task.toString() << endl;
        queue.add(task);
        lock.unlock();
        condVar.notify_one();
    }

    void processTask(TaskType& task)
    {
        //cout << "processing: " + task.toString() << endl;
        TaskType child;

        if (!isConditionRedundant(task)) {
            updateConditionChain(task);
            if (!isConditionPrunable(task)) {

                task.resetFoci();
                Iterator& iter = task.getMutableFocusIterator();
                while (iter.hasPredicate()) {
                    if (!isFocusRedundant(task)) {
                        computeFocusChain(task);
                        if (!isFocusPrunable(task)) {
                            iter.putCurrentToSoFar();
                        }
                    }
                    iter.next();
                }

                if (isStorable(task)) {
                    store(task);
                }
                if (isExtendable(task)) {
                    if (task.getConditionIterator().hasSoFar()) {
                        child = task.createChild();
                    }
                    if (task.getConditionIterator().hasPredicate()) {
                        task.getMutableConditionIterator().putCurrentToSoFar();
                    }
                }
            }
        }

        task.getMutableConditionIterator().next();
        if (task.getConditionIterator().hasPredicate()) {
            sendTask(task);
        }
        if (!child.getConditionIterator().empty()) {
            sendTask(child);
        }
    }

    void taskFinished(TaskType& task)
    {
        unique_lock lock(queueMutex);
        //cout << omp_get_thread_num() << "taskFinished" << endl;
        //cout << "finished: " + task.toString() << endl;
        workingThreads--;
    }

    void store(const TaskType& task)
    {
        //cout << "storing: " + task.toString() << endl;
        ArgumentValues args;
        for (const ArgumentatorType* a : argumentators) {
            a->prepare(args, task);
        }
        unique_lock lock(resultMutex);
        //cout << omp_get_thread_num() << "store" << endl;
        result.push_back(args);
    }

    void updateConditionChain(TaskType& task) const
    {
        if (positiveConditionChainsNeeded) {
            task.updatePositiveChain(data);

            if (negativeConditionChainsNeeded) {
                task.updateNegativeChain(data);
            }
        }

    }

    void computeFocusChain(TaskType& task) const
    {
        if (ppFocusChainsNeeded)
            task.computePpFocusChain(data);

        if (npFocusChainsNeeded)
            task.computeNpFocusChain(data);

        if (pnFocusChainsNeeded)
            task.computePnFocusChain(data);

        if (nnFocusChainsNeeded)
            task.computeNnFocusChain(data);
    }

    bool isConditionRedundant(const TaskType& task) const
    {
        for (const FilterType* e : filters)
            if (e->isConditionRedundant(task))
                return true;

        return false;
    }

    bool isFocusRedundant(const TaskType& task) const
    {
        for (const FilterType* e : filters)
            if (e->isFocusRedundant(task))
                return true;

        return false;
    }

    bool isConditionPrunable(const TaskType& task) const
    {
        for (const FilterType* e : filters)
            if (e->isConditionPrunable(task))
                return true;

        return false;
    }

    bool isFocusPrunable(const TaskType& task) const
    {
        for (const FilterType* e : filters)
            if (e->isFocusPrunable(task))
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
};
