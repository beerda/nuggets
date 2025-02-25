#pragma once

#include "Filter.h"


template <typename TASK>
class MinSupportFilter : public Filter<TASK> {
public:
    MinSupportFilter(double minSupport)
        : minSupport(minSupport)
    { }

    virtual int getCallbacks() const override
    {
        return Filter<TASK>::CALLBACK_IS_CONDITION_PRUNABLE;
    }

    bool isConditionPrunable(TASK& task) const override
    { return task.getPositiveChain().getSupport() < minSupport; }

private:
    double minSupport;
};
