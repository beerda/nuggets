#pragma once

#include "Filter.h"


class MinSupportFilter : public Filter {
public:
    MinSupportFilter(double minSupport)
        : minSupport(minSupport)
    { }

    bool isPrunable(const Task& task) const override
    {
        return task.getChain().getSupport() < minSupport;
        }

private:
    double minSupport;
};
