#pragma once

#include "Filter.h"


template <typename TaskType>
class FilterManager {
public:
    using FilterType = Filter<TaskType>;

    FilterManager()
    { }

    virtual ~FilterManager()
    {
        for (FilterType* filter : filters) {
            delete filter;
        }
    }

    void addFilter(FilterType* filter)
    {
        filters.push_back(filter);
        int cb = filter->getCallbacks();

        if (cb & FilterType::CALLBACK_IS_CONDITION_REDUNDANT)
            filterIsConditionRedundant.push_back(filter);
        if (cb & FilterType::CALLBACK_IS_FOCUS_REDUNDANT)
            filterIsFocusRedundant.push_back(filter);
        if (cb & FilterType::CALLBACK_IS_CONDITION_PRUNABLE)
            filterIsConditionPrunable.push_back(filter);
        if (cb & FilterType::CALLBACK_IS_FOCUS_PRUNABLE)
            filterIsFocusPrunable.push_back(filter);
        if (cb & FilterType::CALLBACK_IS_CONDITION_STORABLE)
            filterIsConditionStorable.push_back(filter);
        if (cb & FilterType::CALLBACK_IS_FOCUS_STORABLE)
            filterIsFocusStorable.push_back(filter);
        if (cb & FilterType::CALLBACK_IS_CONDITION_EXTENDABLE)
            filterIsConditionExtendable.push_back(filter);
        if (cb & FilterType::CALLBACK_IS_FOCUS_EXTENDABLE)
            filterIsFocusExtendable.push_back(filter);
        if (cb & FilterType::CALLBACK_NOTIFY_CONDITION_STORED)
            filterNotifyConditionStored.push_back(filter);
    }

    bool isConditionRedundant(TaskType& task) const
    {
        for (const FilterType* e : filterIsConditionRedundant)
            if (e->isConditionRedundant(task))
                return true;

        return false;
    }

    bool isFocusRedundant(TaskType& task) const
    {
        for (const FilterType* e : filterIsFocusRedundant)
            if (e->isFocusRedundant(task))
                return true;

        return false;
    }

    bool isConditionPrunable(TaskType& task) const
    {
        for (const FilterType* e : filterIsConditionPrunable)
            if (e->isConditionPrunable(task))
                return true;

        return false;
    }

    bool isFocusPrunable(TaskType& task) const
    {
        for (const FilterType* e : filterIsFocusPrunable)
            if (e->isFocusPrunable(task))
                return true;

        return false;
    }

    bool isConditionStorable(TaskType& task) const
    {
        for (const FilterType* e : filterIsConditionStorable)
            if (!e->isConditionStorable(task))
                return false;

        return true;
    }

    bool isFocusStorable(TaskType& task) const
    {
        for (const FilterType* e : filterIsFocusStorable)
            if (!e->isFocusStorable(task))
                return false;

        return true;
    }

    bool isConditionExtendable(TaskType& task) const
    {
        for (const FilterType* e : filterIsConditionExtendable)
            if (!e->isConditionExtendable(task))
                return false;

        return true;
    }

    bool isFocusExtendable(TaskType& task) const
    {
        for (const FilterType* e : filterIsFocusExtendable)
            if (!e->isFocusExtendable(task))
                return false;

        return true;
    }

    void notifyConditionStored(TaskType& task) const
    {
        for (FilterType* e : filterNotifyConditionStored)
            e->notifyConditionStored(task);
    }

private:
    vector<FilterType*> filters;
    vector<FilterType*> filterIsConditionRedundant;
    vector<FilterType*> filterIsFocusRedundant;
    vector<FilterType*> filterIsConditionPrunable;
    vector<FilterType*> filterIsFocusPrunable;
    vector<FilterType*> filterIsConditionStorable;
    vector<FilterType*> filterIsFocusStorable;
    vector<FilterType*> filterIsConditionExtendable;
    vector<FilterType*> filterIsFocusExtendable;
    vector<FilterType*> filterNotifyConditionStored;
};
