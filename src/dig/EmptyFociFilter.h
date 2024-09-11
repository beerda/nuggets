#pragma once

#include "Filter.h"


template <typename TASK>
class EmptyFociFilter : public Filter<TASK> {
public:
    EmptyFociFilter()
    { }

    bool isStorable(const TASK& task) const override
    { return task.getFocusIterator().hasSoFar(); }

    bool isExtendable(const TASK& task) const override
    { return task.getFocusIterator().hasSoFar(); }
};
