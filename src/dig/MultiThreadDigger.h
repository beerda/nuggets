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

    virtual void run() override
    {
        initializeRun();

        #if defined(_OPENMP)
            //#pragma omp parallel num_threads(allThreads) shared(data, initialTask, sequence, filters, argumentators, result, workingThreads, allThreads, sequenceMutex, condVar, endImmediately)
            #pragma omp parallel num_threads(allThreads) default(shared)
        #endif
        {
            TaskType* task = nullptr;
            try {
                while (!workDone()) {
                    if (receiveTask(task)) {
                        if (!this->callbackCaller.isStorageFull()) {
                            this->processTask(task);
                        }
                        taskFinished(task);

                        delete task;
                        task = nullptr;
                    }
                    this->callbackCaller.processAvailableCalls();
                }
            }
            catch (const std::exception& e) {
                processError(e);
            }
            //cout << omp_get_thread_num() << "exit" << endl;
            condVar.notify_all();

            if (task)
                delete task;
        }

        try {
            this->callbackCaller.processAvailableCalls();
        }
        catch (const std::exception& e) {
            processError(e);
        }
        finalizeRun();
    }

protected:
    virtual void processCall(const TaskType* task) override
    { this->callbackCaller.enqueueCall(task); }

    virtual void processChild(TaskType* task) override
    { sendTask(task); }

private:
    TaskSequence<TaskType*> sequence;
    bool endImmediately;
    std::exception caughtException;
    int workingThreads;
    int allThreads;
    mutex sequenceMutex;
    condition_variable condVar;

    void initializeRun()
    {
        sequence.clear();
        sequence.add(this->createInitialTask());
        workingThreads = 0;
        endImmediately = false;
    }

    void finalizeRun()
    {
        while (!sequence.empty()) {
            TaskType* task = sequence.pop();
            delete task;
        }

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

    bool receiveTask(TaskType*& task)
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
            workingThreads++;
            return true;
        }

        return false;
    }

    void sendTask(TaskType* task)
    {
        unique_lock lock(sequenceMutex);
        //cout << omp_get_thread_num() << "sendTask" << endl;
        //cout << "sending: " + task.toString() << endl;
        sequence.add(task);
        lock.unlock();
        condVar.notify_one();
    }

    void taskFinished(TaskType* task)
    {
        unique_lock lock(sequenceMutex);
        //cout << omp_get_thread_num() << "taskFinished" << endl;
        //cout << "finished: " + task.toString() << endl;
        workingThreads--;
    }
};
