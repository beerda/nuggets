#pragma once

#include "Filter.h"


template <typename TASK>
class MaxLengthFilter : public Filter<TASK> {
public:
    MaxLengthFilter(int maxLength)
        : maxLength(maxLength)
    { }

    bool isConditionRedundant(const TASK& task) const override
    { return ((int) task.getConditionIterator().getLength()) > maxLength; }

private:
    int maxLength;
};
