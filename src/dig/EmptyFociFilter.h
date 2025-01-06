#pragma once

#include "Filter.h"


template <typename TASK>
class EmptyFociFilter : public Filter<TASK> {
public:
    EmptyFociFilter()
    { }

    bool isConditionStorable(const TASK& task) const override
    { return task.getFocusIterator().hasSoFar(); }

    bool isConditionExtendable(const TASK& task) const override
    { return task.getFocusIterator().hasSoFar(); }
};
