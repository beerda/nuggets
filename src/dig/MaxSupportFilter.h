#pragma once

#include "Filter.h"


template <typename TASK>
class MaxSupportFilter : public Filter<TASK> {
public:
    MaxSupportFilter(double maxSupport)
        : maxSupport(maxSupport)
    { }

    virtual int getCallbacks() const override
    {
        return Filter<TASK>::CALLBACK_IS_CONDITION_STORABLE;
    }

    bool isConditionStorable(const TASK& task) const override
    { return task.getPositiveChain().getSupport() <= maxSupport; }

private:
    double maxSupport;
};
