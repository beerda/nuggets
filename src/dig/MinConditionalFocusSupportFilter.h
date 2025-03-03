#pragma once

#include "Filter.h"


template <typename TASK>
class MinConditionalFocusSupportFilter : public Filter<TASK> {
public:
    MinConditionalFocusSupportFilter(double minConditionalFocusSupport, size_t dataLength)
        : minConditionalFocusSupport(minConditionalFocusSupport),
          dataLength(dataLength)
    { }

    virtual int getCallbacks() const override
    {
        return Filter<TASK>::CALLBACK_IS_FOCUS_STORABLE;
    }

    bool isFocusStorable(TASK& task) const override
    {
        if (task.getFocusIterator().hasPredicate()) {
            int curr = task.getFocusIterator().getCurrentPredicate();
            float focusSum = task.getPpFocusChain(curr).getSum();
            float conditionSum = task.getPositiveChain().empty() ? dataLength : task.getPositiveChain().getSum();

            return (focusSum / conditionSum) >= minConditionalFocusSupport;
        }

        return false;
    }

private:
    double minConditionalFocusSupport;
    size_t dataLength;
};
