#pragma once

#include "Filter.h"
#include "TautologyTree.h"


template <typename TASK>
class ExcludedTautologiesFilter : public Filter<TASK> {
public:
    ExcludedTautologiesFilter(const TautologyTree& tree)
        : tree(tree)
    { }

    virtual int getCallbacks() const override
    {
        return Filter<TASK>::CALLBACK_IS_CONDITION_REDUNDANT
             | Filter<TASK>::CALLBACK_IS_FOCUS_REDUNDANT;
    }

    bool isConditionRedundant(TASK* task) const override
    {
        const Iterator& it = task->getConditionIterator();
        if (it.hasPredicate()) {
            vector<int> deduced = tree.deduceConsequentsByRevSorted(it.getPrefix(), it.getCurrentPredicate());
            for (int d : deduced) {
                if (it.getCurrentPredicate() == d) {
                    return true;
                }
                for (int p : it.getPrefix()) {
                    if (d == p) {
                        return true;
                    }
                }
            }
            task->setDeducedPredicates(deduced);
        }

        return false;
    }

    bool isFocusRedundant(TASK* task) const override
    {
        const Iterator& it = task->getFocusIterator();
        if (it.hasPredicate()) {
            vector<int> deduced = task->getDeducedPredicates();
            for (int d : deduced) {
                if (d == it.getCurrentPredicate()) {
                    return true;
                }
            }
        }

        return false;
    }

private:
    const TautologyTree& tree;
};
