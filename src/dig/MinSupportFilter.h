#pragma once

#include "Filter.h"


template <typename TASK>
class MinSupportFilter : public Filter<TASK> {
public:
    MinSupportFilter(double minSupport)
        : minSupport(minSupport)
    { }

    bool isConditionPrunable(const TASK& task) const override
    {
        return task.getChain().getSupport() < minSupport;
        }

private:
    double minSupport;
};
