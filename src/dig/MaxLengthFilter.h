#pragma once

#include "Filter.h"


template <typename TASK>
class MaxLengthFilter : public Filter<TASK> {
public:
    MaxLengthFilter(int maxLength)
        : maxLength(maxLength)
    { }

    virtual int getCallbacks() const override
    {
        return Filter<TASK>::CALLBACK_IS_CONDITION_REDUNDANT;
    }

    bool isConditionRedundant(TASK* task) const override
    { return ((int) task->getConditionIterator().getLength()) > maxLength; }

private:
    int maxLength;
};
