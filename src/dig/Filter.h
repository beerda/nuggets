#pragma once

#include "Task.h"


/**
 * This abstract class represents an extension that may filter the conditions being generated.
 */
template <typename TASK>
class Filter {
public:
    virtual ~Filter()
    { }

    virtual bool isConditionRedundant(const TASK& task) const
    { return false; }

    virtual bool isFocusRedundant(const TASK& task) const
    { return false; }

    virtual bool isConditionPrunable(const TASK& task) const
    { return false; }

    virtual bool isFocusPrunable(const TASK& task) const
    { return false; }

    virtual bool isStorable(const TASK& task) const
    { return true; }

    virtual bool isExtendable(const TASK& task) const
    { return true; }

};
