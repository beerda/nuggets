#pragma once

#include "Filter.h"


template <typename TASK>
class MaxLengthFilter : public Filter<TASK> {
public:
    MaxLengthFilter(int maxLength)
        : maxLength(maxLength)
    { }

    bool isRedundant(const TASK& task) const override
    { return ((int) task.getLength()) > maxLength; }

private:
    int maxLength;
};
