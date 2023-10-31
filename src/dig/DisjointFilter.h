#pragma once

#include "Filter.h"


class DisjointFilter : public Filter {
public:
    DisjointFilter(const integers& disjoint)
        : disjoint(disjoint)
    { }

    bool isRedundant(const Task& task) const override
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
    integers disjoint;
};
