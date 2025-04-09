#pragma once

#include "Data.h"
#include "Config.h"
#include "FilterManager.h"
#include "CallbackCaller.h"


template <typename DATA>
class AbstractDigger {
public:
    using DataType = DATA;
    using TaskType = Task<DATA>;
    using FilterType = Filter<TaskType>;
    using ArgumentatorType = Argumentator<TaskType>;

    AbstractDigger(DataType& data,
                   const Config& config,
                   const Function callback)
        : data(data),
          callbackCaller(config.getMaxResults(), callback),
          initialTask(Iterator(data.getCondition()), // condition predicates to "soFar"
                      Iterator({}, data.getFoci()))  // focus predicates to "available"
    { }

    void addArgumentator(ArgumentatorType* argumentator)
    { callbackCaller.addArgumentator(argumentator); }

    void addFilter(FilterType* filter)
    { filterManager.addFilter(filter); }

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

    virtual void run() = 0;

protected:
    DataType& data;
    TaskType initialTask;
    FilterManager<TaskType> filterManager;
    CallbackCaller<TaskType> callbackCaller;

    bool positiveConditionChainsNeeded = false;
    bool negativeConditionChainsNeeded = false;
    bool ppFocusChainsNeeded = false;
    bool npFocusChainsNeeded = false;
    bool pnFocusChainsNeeded = false;
    bool nnFocusChainsNeeded = false;

    virtual void processCall(const TaskType& task) = 0;

    virtual void processChild(TaskType& task) = 0;

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
                        this->processCall(task);
                    }
                    if (this->filterManager.isConditionExtendable(task)) {
                        if (task.getConditionIterator().hasSoFar()) {
                            TaskType child = task.createChild();
                            processChild(child);
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
