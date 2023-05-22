#pragma once

#include "Task.hpp"


class Filter {
public:
    virtual bool isRedundant(const Task& task) const
    { return false; }

    virtual bool isPrunable(const Task& task) const
    { return false; }

    virtual bool isExtendable(const Task& task) const
    { return true; }
};
