#pragma once

#include "Filter.h"
#include "ExcludedSubsets.h"


template <typename TASK>
class ExcludedSubsetsFilter : public Filter<TASK> {
public:
    ExcludedSubsetsFilter(const ExcludedSubsets& excluded,
                          const vector<int>& predicateIndices)
        : excluded(excluded),
          predicateIndices(predicateIndices)
    { }

    bool isConditionRedundant(const TASK& task) const override
    {
        const Iterator& it = task.getConditionIterator();
        if (it.hasPredicate()) {
            vector<int> translated;
            translated.reserve(it.getPrefix().size());
            for (int p : it.getPrefix()) {
                translated.push_back(predicateIndices[p]);
            }
            return excluded.isExcluded(translated, predicateIndices[it.getCurrentPredicate()]);
        }

        return false;
    }

private:
    const ExcludedSubsets& excluded;
    const vector<int>& predicateIndices;
};
