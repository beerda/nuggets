#pragma once

//#include <omp.h>
#include <thread>
#include <mutex>
#include <condition_variable>
#include <RcppThread.h>

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

    Digger(DataType& data, const Config& config, const Function callback)
        : config(config),
          data(data),
          callback(callback),
          initialTask(Iterator(data.getCondition()), // condition predicates to "soFar"
                      Iterator({}, data.getFoci())), // focus predicates to "available"
          sequence(),
          allThreads(config.getThreads()),
          mainThreadId(std::this_thread::get_id())
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
            //#pragma omp parallel num_threads(allThreads) shared(data, initialTask, sequence, filters, argumentators, result, workingThreads, allThreads, sequenceMutex, callQueueMutex, condVar, endImmediately)
            #pragma omp parallel num_threads(allThreads) default(shared)
        #endif
        {
            try {
                while (!workDone()) {
                    TaskType task;
                    if (receiveTask(task)) {
                        if (!isStorageFull()) {
                            processTask(task);
                        }
                        taskFinished(task);
                    }
                    RcppThread::checkUserInterrupt();
                    processAvailableCalls();
                }
            }
            catch (const std::exception& e) {
                processError(e);
            }
            //cout << omp_get_thread_num() << "exit" << endl;
            condVar.notify_all();
        }

        processAvailableCalls();
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
    { return result; }

private:
    const Config& config;
    const Function callback;
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
    queue<ArgumentValues> callQueue;
    Rcpp::List result;
    size_t nResult = 0;

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
    mutex callQueueMutex;
    condition_variable condVar;
    std::thread::id mainThreadId;

    bool isMainThread() const
    { return std::this_thread::get_id() == mainThreadId; }

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
        unique_lock lock(callQueueMutex);
        //cout << omp_get_thread_num() << "store" << endl;
        if (!isStorageFull()) {
            callQueue.push(args);
            nResult++;
        }
    }

    bool receiveCall(ArgumentValues& args)
    {
        unique_lock lock(callQueueMutex);
        if (!callQueue.empty()) {
            args = callQueue.front();
            callQueue.pop();
            return true;
        }

        return false;
    }

    void processAvailableCalls()
    {
        if (isMainThread()) {
            ArgumentValues args;
            while (receiveCall(args)) {
                List rArgs(args.size());
                CharacterVector rArgNames(args.size());
                for (size_t j = 0; j < args.size(); ++j) {
                    ArgumentValue a = args[j];
                    rArgNames[j] = a.getArgumentName();

                    if (a.getType() == ArgumentType::ARG_LOGICAL) {
                        rArgs[j] = a.asLogicalVector();
                    }
                    else if (a.getType() == ArgumentType::ARG_INTEGER) {
                        rArgs[j] = a.asIntegerVector();
                    }
                    else if (a.getType() == ArgumentType::ARG_NUMERIC) {
                        rArgs[j] = a.asNumericVector();
                    } else {
                        throw runtime_error("Unhandled ArgumentType");
                    }
                }
                rArgs.names() = rArgNames;
                result.push_back(callback(rArgs));
            }
        }
    }

    bool isStorageFull() {
        if (config.getMaxResults() < 0)
            return false;

        return nResult >= config.getMaxResults();
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
