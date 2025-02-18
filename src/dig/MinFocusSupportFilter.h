#pragma once

#include "Filter.h"


template <typename TASK>
class MinFocusSupportFilter : public Filter<TASK> {
public:
    MinFocusSupportFilter(double minFocusSupport)
        : minFocusSupport(minFocusSupport)
    { }

    virtual int getCallbacks() const override
    {
        return Filter<TASK>::CALLBACK_IS_FOCUS_PRUNABLE;
    }

    bool isFocusPrunable(const TASK& task) const override
    {
        if (task.getFocusIterator().hasPredicate()) {
            int curr = task.getFocusIterator().getCurrentPredicate();
            return task.getPpFocusChain(curr).getSupport() < minFocusSupport;
        }

        return false;
    }

private:
    double minFocusSupport;
};
