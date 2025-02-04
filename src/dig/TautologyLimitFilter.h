#pragma once

#include "Filter.h"
#include "ExcludedSubsets.h"


template <typename TASK>
class TautologyLimitFilter : public Filter<TASK> {
public:
    TautologyLimitFilter(ExcludedSubsets& excluded,
                         const vector<int>& predicateIndices,
                         const vector<int>& fociIndices,
                         const double limit,
                         const size_t dataLength)
        : excluded(excluded),
          predicateIndices(predicateIndices),
          fociIndices(fociIndices),
          limit(limit),
          dataLength(dataLength)
    { }

    bool isFocusExtendable(const TASK& task) const override
    {
        if (task.getFocusIterator().hasPredicate()) {
            int curr = task.getFocusIterator().getCurrentPredicate();
            float focusSum = task.getPpFocusChain(curr).getSum();
            float conditionSum = task.getPositiveChain().empty() ? dataLength : task.getPositiveChain().getSum();

            return (focusSum / conditionSum) < limit;
        }

        return false;
    }

    void notifyConditionStored(const TASK& task) override
    {
        float conditionSum = task.getPositiveChain().empty() ? dataLength : task.getPositiveChain().getSum();
        set<int> conditionSet = task.getConditionIterator().getCurrentCondition();
        vector<int> conditionVec;
        conditionVec.reserve(conditionSet.size() + 1);
        for (int p : conditionSet) {
            conditionVec.push_back(predicateIndices[p]);
        }
        conditionVec.push_back(-1); // placeholder

        for (int focus : task.getFocusIterator().getStored()) {
            float focusSum = task.getPpFocusChain(focus).getSum();
            if (focusSum / conditionSum >= limit) {
                conditionVec.back() = fociIndices[focus];
                excluded.addExcludedSubset(conditionVec);
            }
        }
    }

private:
    ExcludedSubsets& excluded;
    const vector<int> predicateIndices;
    const vector<int> fociIndices;
    const double limit;
    const size_t dataLength;
};
