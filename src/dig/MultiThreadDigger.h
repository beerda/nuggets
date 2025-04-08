#pragma once

//#include <omp.h>
#include <mutex>
#include <condition_variable>
#include <RcppThread.h>

#include "TaskSequence.h"
#include "AbstractDigger.h"


template <typename DATA>
class MultiThreadDigger : public AbstractDigger<DATA> {
public:
    using DataType = DATA;
    using TaskType = Task<DATA>;
    using FilterType = Filter<TaskType>;
    using ArgumentatorType = Argumentator<TaskType>;

    MultiThreadDigger(DataType& data,
                      const Config& config,
                      const Function callback)
        : AbstractDigger<DATA>(data, config, callback),
          sequence(),
          allThreads(config.getThreads())
    { }

    virtual void run()
    {
        initializeRun();

        #if defined(_OPENMP)
            //#pragma omp parallel num_threads(allThreads) shared(data, initialTask, sequence, filters, argumentators, result, workingThreads, allThreads, sequenceMutex, condVar, endImmediately)
            #pragma omp parallel num_threads(allThreads) default(shared)
        #endif
        {
            try {
                TaskSequence<TaskType> localSequence;
                while (!workDone()) {
                    if (receiveTasks(localSequence)) {
                        while (!localSequence.empty()) {
                            TaskType task = localSequence.pop();
                            if (!this->callbackCaller.isStorageFull()) {
                                processTask(task);
                            }
                        }
                        tasksFinished();
                    }
                    this->callbackCaller.processAvailableCalls();
                }
            }
            catch (const std::exception& e) {
                processError(e);
            }
            //cout << omp_get_thread_num() << "exit" << endl;
            condVar.notify_all();
        }

        this->callbackCaller.processAvailableCalls();
        finalizeRun();
    }

private:
    TaskSequence<TaskType> sequence;
    bool endImmediately;
    std::exception caughtException;
    int workingThreads;
    int allThreads;
    mutex sequenceMutex;
    condition_variable condVar;

    void initializeRun()
    {
        sequence.clear();
        sequence.add(this->initialTask);
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

    bool receiveTasks(TaskSequence<TaskType>& localSequence)
    {
        unique_lock lock(sequenceMutex);
        //cout << omp_get_thread_num() << "receiveTask" << endl;
        while (sequence.empty() && workingThreads > 0) {
            //cout << omp_get_thread_num() << "waiting" << endl;
            condVar.wait(lock);
        }

        //cout << omp_get_thread_num() << "continue" << endl;
        if (!sequence.empty()) {
            size_t receiveN = max(1.0, ceil(1.0 * sequence.size() / allThreads));
            //cout << "receiveN: " << receiveN << endl;
            while (receiveN > 0 && !sequence.empty()) {
                localSequence.add(sequence.pop());
                receiveN--;
            }
            workingThreads++;
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
            if (!this->filterManager.isConditionRedundant(task)) {
                this->updateConditionChain(task);
                if (!this->filterManager.isConditionPrunable(task)) {

                    task.resetFoci();
                    Iterator& iter = task.getMutableFocusIterator();
                    while (iter.hasPredicate()) {
                        if (!this->filterManager.isFocusRedundant(task)) {
                            this->computeFocusChain(task);
                            if (!this->filterManager.isFocusPrunable(task)) {
                                if (this->filterManager.isFocusStorable(task)) {
                                    iter.storeCurrent();
                                }
                                if (this->filterManager.isFocusExtendable(task)) {
                                    iter.putCurrentToSoFar();
                                }
                            }
                        }
                        iter.next();
                    }

                    if (this->filterManager.isConditionStorable(task)) {
                        this->filterManager.notifyConditionStored(task);
                        this->callbackCaller.enqueueCall(task);
                    }
                    if (this->filterManager.isConditionExtendable(task)) {
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

    void tasksFinished()
    {
        unique_lock lock(sequenceMutex);
        //cout << omp_get_thread_num() << "taskFinished" << endl;
        //cout << "finished: " + task.toString() << endl;
        workingThreads--;
    }
};
