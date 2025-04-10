#pragma once

#include <thread>
#include <mutex>
#include <queue>
#include <RcppThread.h>

#include "Argumentator.h"


/**
 * This class is responsible for calling the R function callback on each generated
 * frequent condition. It is also responsible for storing the results of the callback
 * function.
 *
 * The class may be used in two ways: single-threaded and multi-threaded.
 * In the single-threaded mode, the callback function is called directly:
 * use CallbackCaller::processCall(task) to call the callback function.
 * In the multi-threaded mode, the call should be first enqueued by
 * CallbackCaller::enqueueCall(task) and then processed by
 * CallbackCaller::processAvailableCalls().
 */
template <typename TaskType>
class CallbackCaller {
public:
    using ArgumentatorType = Argumentator<TaskType>;

    CallbackCaller(int maxResults, const Function callback)
        : maxResults(maxResults),
          callback(callback),
          mainThreadId(std::this_thread::get_id())
    { }

    virtual ~CallbackCaller()
    {
        for (ArgumentatorType* a : argumentators)
            delete a;
    }

    void addArgumentator(ArgumentatorType* argumentator)
    { argumentators.push_back(argumentator); }

    bool isStorageFull() {
        if (maxResults < 0)
            return false;

        return nResult >= maxResults;
    }

    void processCall(const TaskType* task)
    {
        if (isStorageFull())
            return;

        processCall(prepareCall(task));
    }

    void enqueueCall(const TaskType* task)
    {
        unique_lock lock(callQueueMutex);
        if (!isStorageFull()) {
            callQueue.push(prepareCall(task));
            nResult++;
        }
    }

    void processAvailableCalls()
    {
        if (isMainThread()) {
            ArgumentValues args;
            while (receiveCall(args)) {
                RcppThread::checkUserInterrupt();
                processCall(args);
            }
        }
    }

    Rcpp::List getResult() const
    { return result; }


private:
    int maxResults;
    Function callback;
    vector<ArgumentatorType*> argumentators;
    queue<ArgumentValues> callQueue;
    mutex callQueueMutex;
    std::thread::id mainThreadId;
    Rcpp::List result;
    size_t nResult = 0;

    ArgumentValues prepareCall(const TaskType* task)
    {
        ArgumentValues args;
        for (const ArgumentatorType* a : argumentators) {
            a->prepare(args, task);
        }

        return args;
    }

    void processCall(const ArgumentValues& args)
    {
        List rArgs(args.size());
        CharacterVector rArgNames(args.size());
        for (size_t j = 0; j < args.size(); ++j) {
            const ArgumentValue& a = args[j];
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

    bool isMainThread() const
    { return std::this_thread::get_id() == mainThreadId; }

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

};
