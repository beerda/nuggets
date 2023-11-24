#pragma once

#include "Filter.h"


template <typename TASK>
class DisjointFilter : public Filter<TASK> {
public:
    DisjointFilter(const IntegerVector& disjoint)
        : disjoint(disjoint)
    { }

    bool isRedundant(const TASK& task) const override
    {
        if (task.hasPredicate()) {
            int curr = task.getCurrentPredicate();
            int currDisj = disjoint[curr];
            for (int pref : task.getPrefix()) {
                if (disjoint[pref] == currDisj) {
                    return true;
                }
            }
        }

        return false;
    }

private:
    IntegerVector disjoint;
};
