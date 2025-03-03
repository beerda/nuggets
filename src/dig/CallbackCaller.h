#pragma once

#include <thread>
#include <mutex>
#include <queue>
#include <RcppThread.h>

#include "Argumentator.h"


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

    void enqueueCall(const TaskType& task)
    {
        unique_lock lock(callQueueMutex);
        if (!isStorageFull()) {
            ArgumentValues args;
            for (const ArgumentatorType* a : argumentators) {
                a->prepare(args, task);
            }
            callQueue.push(args);
            nResult++;
        }

    }

    void processAvailableCalls()
    {
        if (isMainThread()) {
            ArgumentValues args;
            while (receiveCall(args)) {
                RcppThread::checkUserInterrupt();
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
