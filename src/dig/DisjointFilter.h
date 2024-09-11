#pragma once

#include "Filter.h"


template <typename TASK>
class DisjointFilter : public Filter<TASK> {
public:
    DisjointFilter(const vector<int>& disjoint)
        : disjoint(disjoint)
    { }

    bool isConditionRedundant(const TASK& task) const override
    {
        if (task.getConditionIterator().hasPredicate()) {
            int curr = task.getConditionIterator().getCurrentPredicate();
            int currDisj = disjoint[curr];
            for (int pref : task.getConditionIterator().getPrefix()) {
                if (disjoint[pref] == currDisj) {
                    return true;
                }
            }
        }

        return false;
    }

private:
    vector<int> disjoint;
};
