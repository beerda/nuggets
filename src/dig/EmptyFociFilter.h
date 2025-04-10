#pragma once

#include "Filter.h"


template <typename TASK>
class EmptyFociFilter : public Filter<TASK> {
public:
    EmptyFociFilter()
    { }

    virtual int getCallbacks() const override
    {
        return Filter<TASK>::CALLBACK_IS_CONDITION_STORABLE
             | Filter<TASK>::CALLBACK_IS_CONDITION_EXTENDABLE;
    }

    bool isConditionStorable(TASK* task) const override
    { return task->getFocusIterator().hasStored(); }

    bool isConditionExtendable(TASK* task) const override
    { return task->getFocusIterator().hasSoFar(); }
};
