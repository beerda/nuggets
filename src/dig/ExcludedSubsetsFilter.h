#pragma once

#include "Filter.h"
#include "ExcludedSubsets.h"


template <typename TASK>
class ExcludedSubsetsFilter : public Filter<TASK> {
public:
    ExcludedSubsetsFilter(const ExcludedSubsets& excluded)
        : excluded(excluded)
    { }

    virtual int getCallbacks() const override
    {
        return Filter<TASK>::CALLBACK_IS_CONDITION_REDUNDANT;
    }

    bool isConditionRedundant(TASK& task) const override
    {
        const Iterator& it = task.getConditionIterator();
        if (it.hasPredicate()) {
            return excluded.isExcluded(it.getPrefix(), it.getCurrentPredicate());
        }

        return false;
    }

private:
    const ExcludedSubsets& excluded;
};
