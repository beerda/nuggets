#pragma once

#include "Filter.h"


template <typename TASK>
class MinFocusSupportFilter : public Filter<TASK> {
public:
    MinFocusSupportFilter(double minFocusSupport)
        : minFocusSupport(minFocusSupport)
    { }

    bool isFocusPrunable(const TASK& task) const override
    {
        if (task.getFocusIterator().hasPredicate()) {
            int curr = task.getFocusIterator().getCurrentPredicate();
            return task.getFocusChain(curr).getSupport() < minFocusSupport;
        }

        return false;
    }

private:
    double minFocusSupport;
};
