#pragma once

//#include <omp.h>
#include <mutex>
#include <condition_variable>

#include "Data.h"
#include "Config.h"
#include "TaskSequence.h"
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
        : config(config),
          data(data),
          initialTask(Iterator(data.getCondition()), // condition predicates to "soFar"
                      Iterator({}, data.getFoci())), // focus predicates to "available"
          sequence(),
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
    {
        filters.push_back(filter);
        int cb = filter->getCallbacks();

        if (cb & FilterType::CALLBACK_IS_CONDITION_REDUNDANT)
            filterIsConditionRedundant.push_back(filter);
        if (cb & FilterType::CALLBACK_IS_FOCUS_REDUNDANT)
            filterIsFocusRedundant.push_back(filter);
        if (cb & FilterType::CALLBACK_IS_CONDITION_PRUNABLE)
            filterIsConditionPrunable.push_back(filter);
        if (cb & FilterType::CALLBACK_IS_FOCUS_PRUNABLE)
            filterIsFocusPrunable.push_back(filter);
        if (cb & FilterType::CALLBACK_IS_CONDITION_STORABLE)
            filterIsConditionStorable.push_back(filter);
        if (cb & FilterType::CALLBACK_IS_FOCUS_STORABLE)
            filterIsFocusStorable.push_back(filter);
        if (cb & FilterType::CALLBACK_IS_CONDITION_EXTENDABLE)
            filterIsConditionExtendable.push_back(filter);
        if (cb & FilterType::CALLBACK_IS_FOCUS_EXTENDABLE)
            filterIsFocusExtendable.push_back(filter);
        if (cb & FilterType::CALLBACK_NOTIFY_CONDITION_STORED)
            filterNotifyConditionStored.push_back(filter);
    }

    void addArgumentator(ArgumentatorType* argumentator)
    { argumentators.push_back(argumentator); }

    void run()
    {
        initializeRun();

        #if defined(_OPENMP)
            //#pragma omp parallel num_threads(allThreads) default(shared)
            #pragma omp parallel num_threads(allThreads) shared(data, initialTask, sequence, filters, argumentators, result, workingThreads, allThreads, sequenceMutex, resultMutex, condVar)
        #endif
        {
            while (!workDone()) {
                TaskType task;
                if (receiveTask(task)) {
                    if (!isStorageFull()) {
                        processTask(task);
                    }
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
    const Config& config;
    DataType& data;
    TaskType initialTask;
    TaskSequence<TaskType> sequence;

    vector<FilterType*> filters;
    vector<FilterType*> filterIsConditionRedundant;
    vector<FilterType*> filterIsFocusRedundant;
    vector<FilterType*> filterIsConditionPrunable;
    vector<FilterType*> filterIsFocusPrunable;
    vector<FilterType*> filterIsConditionStorable;
    vector<FilterType*> filterIsFocusStorable;
    vector<FilterType*> filterIsConditionExtendable;
    vector<FilterType*> filterIsFocusExtendable;
    vector<FilterType*> filterNotifyConditionStored;


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
    mutex sequenceMutex;
    mutex resultMutex;
    condition_variable condVar;


    void initializeRun()
    {
        sequence.clear();
        sequence.add(initialTask);
        workingThreads = 0;
    }

    bool workDone()
    {
        unique_lock lock(sequenceMutex);
        //cout << omp_get_thread_num() << "workDone" << endl;
        return sequence.empty() && workingThreads <= 0;
    }

    bool receiveTask(TaskType& task)
    {
        unique_lock lock(sequenceMutex);
        //cout << omp_get_thread_num() << "receiveTask" << endl;
        while (sequence.empty() && workingThreads > 0) {
            //cout << omp_get_thread_num() << "waiting" << endl;
            condVar.wait(lock);
        }

        //cout << omp_get_thread_num() << "continue" << endl;
        bool received = false;
        if (!sequence.empty()) {
            task = sequence.pop();
            //cout << "receiving: " + task.toString() << endl;
            workingThreads++;
            received = true;
            //cout << "received task - working: " << workingThreads << " queue size: " << queue.size() << endl;
        }

        return received;
    }

    void sendTask(const TaskType& task)
    {
        unique_lock lock(sequenceMutex);
        //cout << omp_get_thread_num() << "sendTask" << endl;
        //cout << "sending: " + task.toString() << endl;
        sequence.add(task);
        lock.unlock();
        condVar.notify_one();
    }

    void processTask(TaskType& task)
    {
        //cout << "processing: " + task.toString() << endl;
        do {
            if (!isConditionRedundant(task)) {
                updateConditionChain(task);
                if (!isConditionPrunable(task)) {

                    task.resetFoci();
                    Iterator& iter = task.getMutableFocusIterator();
                    while (iter.hasPredicate()) {
                        if (!isFocusRedundant(task)) {
                            computeFocusChain(task);
                            if (!isFocusPrunable(task)) {
                                if (isFocusStorable(task)) {
                                    iter.storeCurrent();
                                }
                                if (isFocusExtendable(task)) {
                                    iter.putCurrentToSoFar();
                                }
                            }
                        }
                        iter.next();
                    }

                    if (isConditionStorable(task)) {
                        notifyConditionStored(task);
                        store(task);
                    }
                    if (isConditionExtendable(task)) {
                        if (task.getConditionIterator().hasSoFar()) {
                            TaskType child = task.createChild();
                            sendTask(child);
                        }
                        if (task.getConditionIterator().hasPredicate()) {
                            task.getMutableConditionIterator().putCurrentToSoFar();
                        }
                    }
                }
            }

            task.getMutableConditionIterator().next();
        }
        while (task.getConditionIterator().hasPredicate());
    }

    void taskFinished(TaskType& task)
    {
        unique_lock lock(sequenceMutex);
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
        if (!isStorageFull()) {
            result.push_back(args);
        }
    }

    bool isStorageFull() {
        if (config.getMaxResults() < 0)
            return false;

        return result.size() >= config.getMaxResults();
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

    bool isConditionRedundant(TaskType& task) const
    {
        for (const FilterType* e : filterIsConditionRedundant)
            if (e->isConditionRedundant(task))
                return true;

        return false;
    }

    bool isFocusRedundant(TaskType& task) const
    {
        for (const FilterType* e : filterIsFocusRedundant)
            if (e->isFocusRedundant(task))
                return true;

        return false;
    }

    bool isConditionPrunable(TaskType& task) const
    {
        for (const FilterType* e : filterIsConditionPrunable)
            if (e->isConditionPrunable(task))
                return true;

        return false;
    }

    bool isFocusPrunable(TaskType& task) const
    {
        for (const FilterType* e : filterIsFocusPrunable)
            if (e->isFocusPrunable(task))
                return true;

        return false;
    }

    bool isConditionStorable(TaskType& task) const
    {
        for (const FilterType* e : filterIsConditionStorable)
            if (!e->isConditionStorable(task))
                return false;

        return true;
    }

    bool isFocusStorable(TaskType& task) const
    {
        for (const FilterType* e : filterIsFocusStorable)
            if (!e->isFocusStorable(task))
                return false;

        return true;
    }

    bool isConditionExtendable(TaskType& task) const
    {
        for (const FilterType* e : filterIsConditionExtendable)
            if (!e->isConditionExtendable(task))
                return false;

        return true;
    }

    bool isFocusExtendable(TaskType& task) const
    {
        for (const FilterType* e : filterIsFocusExtendable)
            if (!e->isFocusExtendable(task))
                return false;

        return true;
    }

    void notifyConditionStored(TaskType& task) const
    {
        for (FilterType* e : filterNotifyConditionStored)
            e->notifyConditionStored(task);
    }

};
