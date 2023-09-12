#pragma once

#include "Task.h"


/**
 * This abstract class represents an extension that may filter the conditions being generated.
 */
class Filter {
public:
    virtual ~Filter()
    { }

    virtual bool isRedundant(const Task& task) const
    { return false; }

    virtual bool isPrunable(const Task& task) const
    { return false; }

    virtual bool isStorable(const Task& task) const
    { return true; }

    virtual bool isExtendable(const Task& task) const
    { return true; }
};
