#pragma once

#include "Filter.h"


template <typename TASK>
class DisjointFilter : public Filter<TASK> {
public:
    DisjointFilter(vector<int> disjoint)
        : disjoint(disjoint)
    { }

    virtual int getCallbacks() const override
    {
        return Filter<TASK>::CALLBACK_IS_CONDITION_REDUNDANT
             | Filter<TASK>::CALLBACK_IS_FOCUS_REDUNDANT;
    }

    bool isConditionRedundant(TASK& task) const override
    {
        if (disjoint.size() <= 1)
            return false;

        if (task.getConditionIterator().hasPredicate()) {
            int curr = task.getConditionIterator().getCurrentPredicate();

            if (task.getConditionIterator().hasPrefix()) {
                // It is enough to check the last element of the prefix because
                // previous elements were already checked in parent tasks
                int pref = task.getConditionIterator().getPrefix().back();
                if (disjoint[pref] == disjoint[curr]) {
                    return true;
                }
            }
        }

        return false;
    }

    bool isFocusRedundant(TASK& task) const override
    {
        if (task.getFocusIterator().hasPredicate()) {
            int curr = task.getFocusIterator().getCurrentPredicate();

            // test if focus is present in condition
            // (no need to compare with prefix, since that is done in parent task)
            if (task.getConditionIterator().hasPredicate()) {
                if (curr == task.getConditionIterator().getCurrentPredicate())
                    return true;
            }

            if (disjoint.size() <= 1)
                return false;

            // test if focus is disjoint with condition
            // (no need to compare with prefix, since that is done in parent task)
            if (task.getConditionIterator().hasPredicate()) {
                if (disjoint[curr] == disjoint[task.getConditionIterator().getCurrentPredicate()])
                    return true;
            }
        }

        return false;
    }

private:
    vector<int> disjoint;
};
