#pragma once

#include "Filter.h"


template <typename TASK>
class MaxSupportFilter : public Filter<TASK> {
public:
    MaxSupportFilter(double maxSupport)
        : maxSupport(maxSupport)
    { }

    bool isStorable(const TASK& task) const override
    { return task.getPositiveChain().getSupport() <= maxSupport; }

private:
    double maxSupport;
};
