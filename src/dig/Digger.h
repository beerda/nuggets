#pragma once

//#include <omp.h>
#include <mutex>
#include <condition_variable>
#include <RcppThread.h>

#include "Data.h"
#include "Config.h"
#include "TaskSequence.h"
#include "FilterManager.h"
#include "CallbackCaller.h"


template <typename DATA>
class Digger {
public:
    using DataType = DATA;
    using TaskType = Task<DATA>;
    using FilterType = Filter<TaskType>;
    using ArgumentatorType = Argumentator<TaskType>;

    Digger(DataType& data,
           const Config& config,
           const Function callback)
        : data(data),
          callbackCaller(config.getMaxResults(), callback),
          initialTask(Iterator(data.getCondition()), // condition predicates to "soFar"
                      Iterator({}, data.getFoci())), // focus predicates to "available"
          sequence(),
          allThreads(config.getThreads())
    { }

    void addArgumentator(ArgumentatorType* argumentator)
    { callbackCaller.addArgumentator(argumentator); }

    void addFilter(FilterType* filter)
    { filterManager.addFilter(filter); }

    void run()
    {
        initializeRun();

        #if defined(_OPENMP)
            //#pragma omp parallel num_threads(allThreads) shared(data, initialTask, sequence, filters, argumentators, result, workingThreads, allThreads, sequenceMutex, condVar, endImmediately)
            #pragma omp parallel num_threads(allThreads) default(shared)
        #endif
        {
            try {
                while (!workDone()) {
                    TaskType task;
                    if (receiveTask(task)) {
                        if (!callbackCaller.isStorageFull()) {
                            processTask(task);
                        }
                        taskFinished(task);
                    }
                    callbackCaller.processAvailableCalls();
                }
            }
            catch (const std::exception& e) {
                processError(e);
            }
            //cout << omp_get_thread_num() << "exit" << endl;
            condVar.notify_all();
        }

        callbackCaller.processAvailableCalls();
        finalizeRun();
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

    Rcpp::List getResult() const
    { return callbackCaller.getResult(); }

private:
    DataType& data;
    TaskType initialTask;
    TaskSequence<TaskType> sequence;

    FilterManager<TaskType> filterManager;
    CallbackCaller<TaskType> callbackCaller;

    bool positiveConditionChainsNeeded = false;
    bool negativeConditionChainsNeeded = false;
    bool ppFocusChainsNeeded = false;
    bool npFocusChainsNeeded = false;
    bool pnFocusChainsNeeded = false;
    bool nnFocusChainsNeeded = false;

    bool endImmediately;
    std::exception caughtException;

    int workingThreads;
    int allThreads;
    mutex sequenceMutex;
    condition_variable condVar;

    void initializeRun()
    {
        sequence.clear();
        sequence.add(initialTask);
        workingThreads = 0;
        endImmediately = false;
    }

    void finalizeRun()
    {
        if (endImmediately)
            throw caughtException;
    }

    bool workDone()
    {
        unique_lock lock(sequenceMutex);
        //cout << omp_get_thread_num() << "workDone" << endl;
        return endImmediately || (sequence.empty() && workingThreads <= 0);
    }

    void processError(const std::exception& e)
    {
        RcppThread::Rcout << "Error: " << e.what() << endl;
        unique_lock lock(sequenceMutex);
        endImmediately = true;
        caughtException = e;
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
        if (!sequence.empty()) {
            task = sequence.pop();
            //cout << "receiving: " + task.toString() << endl;
            workingThreads++;
            //cout << "received task - working: " << workingThreads << " queue size: " << queue.size() << endl;
            return true;
        }

        return false;
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
            if (!filterManager.isConditionRedundant(task)) {
                updateConditionChain(task);
                if (!filterManager.isConditionPrunable(task)) {

                    task.resetFoci();
                    Iterator& iter = task.getMutableFocusIterator();
                    while (iter.hasPredicate()) {
                        if (!filterManager.isFocusRedundant(task)) {
                            computeFocusChain(task);
                            if (!filterManager.isFocusPrunable(task)) {
                                if (filterManager.isFocusStorable(task)) {
                                    iter.storeCurrent();
                                }
                                if (filterManager.isFocusExtendable(task)) {
                                    iter.putCurrentToSoFar();
                                }
                            }
                        }
                        iter.next();
                    }

                    if (filterManager.isConditionStorable(task)) {
                        filterManager.notifyConditionStored(task);
                        callbackCaller.enqueueCall(task);
                    }
                    if (filterManager.isConditionExtendable(task)) {
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
};
