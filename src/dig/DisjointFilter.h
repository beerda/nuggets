#pragma once

#include "Filter.h"


template <typename TASK>
class DisjointFilter : public Filter<TASK> {
public:
    DisjointFilter(const vector<int>& predicateIndices,
                   const vector<int>& fociIndices,
                   const vector<int>& disjointPredicates,
                   const vector<int>& disjointFoci)
        : predicateIndices(predicateIndices), fociIndices(fociIndices),
          disjointPredicates(disjointPredicates), disjointFoci(disjointFoci)
    { }

    bool isConditionRedundant(const TASK& task) const override
    {
        if (disjointPredicates.size() <= 0)
            return false;

        if (task.getConditionIterator().hasPredicate()) {
            int curr = task.getConditionIterator().getCurrentPredicate();
            int currDisj = disjointPredicates[curr];

            if (task.getConditionIterator().hasPrefix()) {
                // It is enough to check the last element of the prefix because
                // previous elements were already checked in parent tasks
                int pref = task.getConditionIterator().getPrefix().back();
                if (disjointPredicates[pref] == currDisj) {
                    return true;
                }
            }
        }

        return false;
    }

    bool isFocusRedundant(const TASK& task) const override
    {
        if (task.getFocusIterator().hasPredicate()) {
            int curr = task.getFocusIterator().getCurrentPredicate();

            // test if focus is present in condition
            // (no need to compare with prefix, since that is done in parent task)
            if (task.getConditionIterator().hasPredicate()) {
                if (fociIndices[curr] == predicateIndices[task.getConditionIterator().getCurrentPredicate()])
                    return true;
            }

            if (disjointPredicates.size() <= 0)
                return false;

            if (disjointFoci.size() <= 0)
                return false;

            int currDisj = disjointFoci[curr];

            // test if focus is disjoint with condition
            // (no need to compare with prefix, since that is done in parent task)
            if (task.getConditionIterator().hasPredicate()) {
                if (currDisj == disjointPredicates[task.getConditionIterator().getCurrentPredicate()])
                    return true;
            }
        }

        return false;
    }

private:
    vector<int> predicateIndices;
    vector<int> fociIndices;
    vector<int> disjointPredicates;
    vector<int> disjointFoci;
};
