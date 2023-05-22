#pragma once

#include "Task.hpp"


/**
 * This abstract class represents an extension that may filter the conditions being generated.
 */
class Filter {
public:
    virtual bool isRedundant(const Task& task) const
    { return false; }

    virtual bool isPrunable(const Task& task) const
    { return false; }

    virtual bool isExtendable(const Task& task) const
    { return true; }
};
