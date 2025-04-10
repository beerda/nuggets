#pragma once

#include "Filter.h"
#include "TautologyTree.h"


template <typename TASK>
class TautologyLimitFilter : public Filter<TASK> {
public:
    TautologyLimitFilter(TautologyTree& tree,
                         const double limit,
                         const size_t dataLength)
        : tree(tree),
          limit(limit),
          dataLength(dataLength)
    { }

    virtual int getCallbacks() const override
    {
        return Filter<TASK>::CALLBACK_IS_FOCUS_EXTENDABLE
             | Filter<TASK>::CALLBACK_NOTIFY_CONDITION_STORED;
    }

    bool isFocusExtendable(TASK* task) const override
    {
        bool result = false;
        if (task->getFocusIterator().hasPredicate()) {
            int curr = task->getFocusIterator().getCurrentPredicate();
            float focusSum = task->getPpFocusChain(curr).getSum();
            float conditionSum = task->getPositiveChain().empty() ? dataLength : task->getPositiveChain().getSum();

            result = (focusSum / conditionSum) < limit;
        }

        //cout << "isFocusExtendable: " << task->toString() << " : " << result << endl;

        return result;
    }

    void notifyConditionStored(TASK* task) override
    {
        float conditionSum = task->getPositiveChain().empty() ? dataLength : task->getPositiveChain().getSum();

        const Iterator& iter = task->getConditionIterator();
        vector<int> condition = iter.getPrefix();
        if (iter.hasPredicate()) {
            condition.push_back(iter.getCurrentPredicate());
        }

        for (int focus : task->getFocusIterator().getStored()) {
            float focusSum = task->getPpFocusChain(focus).getSum();
            if (focusSum / conditionSum >= limit) {
                tree.addTautology(condition, focus);
            }
        }
    }

private:
    TautologyTree& tree;
    const double limit;
    const size_t dataLength;
};
