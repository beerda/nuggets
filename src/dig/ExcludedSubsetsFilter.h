#pragma once

#include "Filter.h"
#include "ExcludedSubsets.h"


template <typename TASK>
class ExcludedSubsetsFilter : public Filter<TASK> {
public:
    ExcludedSubsetsFilter(const ExcludedSubsets& excluded)
        : excluded(excluded)
    { }

    bool isConditionRedundant(const TASK& task) const override
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
