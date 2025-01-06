#pragma once

#include "Filter.h"


template <typename TASK>
class MinLengthFilter : public Filter<TASK> {
public:
    MinLengthFilter(int minLength)
        : minLength(minLength)
    { }

    bool isConditionStorable(const TASK& task) const override
    { return ((int) task.getConditionIterator().getLength()) >= minLength; }

private:
    int minLength;
};
