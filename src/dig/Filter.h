#pragma once

#include "Task.h"


/**
 * This abstract class represents an extension that may filter the conditions being generated.
 */
template <typename TASK>
class Filter {
public:
    static constexpr int CALLBACK_IS_CONDITION_REDUNDANT = 1;
    static constexpr int CALLBACK_IS_FOCUS_REDUNDANT = 2;
    static constexpr int CALLBACK_IS_CONDITION_PRUNABLE = 4;
    static constexpr int CALLBACK_IS_FOCUS_PRUNABLE = 8;
    static constexpr int CALLBACK_IS_CONDITION_STORABLE = 16;
    static constexpr int CALLBACK_IS_FOCUS_STORABLE = 32;
    static constexpr int CALLBACK_IS_CONDITION_EXTENDABLE = 64;
    static constexpr int CALLBACK_IS_FOCUS_EXTENDABLE = 128;
    static constexpr int CALLBACK_NOTIFY_CONDITION_STORED = 256;

    virtual ~Filter()
    { }

    virtual int getCallbacks() const = 0;

    virtual bool isConditionRedundant(TASK* task) const
    { return false; }

    virtual bool isFocusRedundant(TASK* task) const
    { return false; }

    virtual bool isConditionPrunable(TASK* task) const
    { return false; }

    virtual bool isFocusPrunable(TASK* task) const
    { return false; }

    virtual bool isConditionStorable(TASK* task) const
    { return true; }

    virtual bool isFocusStorable(TASK* task) const
    { return true; }

    virtual bool isConditionExtendable(TASK* task) const
    { return true; }

    virtual bool isFocusExtendable(TASK* task) const
    { return true; }

    virtual void notifyConditionStored(TASK* task)
    { }
};
