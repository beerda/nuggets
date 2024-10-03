#pragma once

#include <vector>
#include <set>
#include <unordered_map>

#include "../common.h"
#include "Data.h"
#include "Iterator.h"


/**
 * Task represents a single level of traversal through the search space of conditions.
 */
template <typename DATA>
class Task {
public:
    using DataType = DATA;
    using DualChainType = typename DataType::DualChainType;

    Task()
    { }

    Task(Iterator conditionIterator, Iterator focusIterator)
        : conditionIterator(conditionIterator), focusIterator(focusIterator)
    { }

    const Iterator& getConditionIterator() const
    { return conditionIterator; }

     Iterator& getMutableConditionIterator()
    { return conditionIterator; }

    const Iterator& getFocusIterator() const
    { return focusIterator; }

    Iterator& getMutableFocusIterator()
    { return focusIterator; }

    Task createChild() const
    {
        Iterator newConditionIterator;

        if (conditionIterator.hasPredicate()) {
            set<int> newPrefix = conditionIterator.getPrefix();
            newPrefix.insert(conditionIterator.getCurrentPredicate());
            newConditionIterator = Iterator(newPrefix, conditionIterator.getSoFar());
        }
        else {
            newConditionIterator = Iterator(conditionIterator.getPrefix(), conditionIterator.getSoFar());
        }

        Iterator newFocusIterator = Iterator({}, focusIterator.getSoFar()); // prefix is always empty
        Task result = Task(newConditionIterator, newFocusIterator);

        if (!positiveChain.empty()) {
            result.prefixChain = positiveChain;
        }

        return result;
    }

    const DualChainType& getPositiveChain() const
    { return positiveChain; }

    const DualChainType& getPrefixChain() const
    { return prefixChain; }

    const DualChainType& getPpFocusChain(int focus) const
    { return ppFocusChains.at(focus); }

    void updatePositiveChain(const DataType& data)
    {
        if (conditionIterator.hasPredicate()) {
            int predicate = conditionIterator.getCurrentPredicate();
            positiveChain = data.getChain(predicate);
            if (!prefixChain.empty()) {
                if (positiveChain.isBitwise() != prefixChain.isBitwise() && positiveChain.isNumeric() != prefixChain.isNumeric()) {
                    if (prefixChain.isBitwise()) {
                        prefixChain.toNumeric();
                    } else {
                        positiveChain.toNumeric();
                    }
                }
                positiveChain.conjunctWith(prefixChain);
            }
        }
    }

    void computePpFocusChain(const DataType& data)
    {
        if (focusIterator.hasPredicate()) {
            int focus = focusIterator.getCurrentPredicate();
            ppFocusChains[focus] = data.getFocus(focus);
            if (!getPositiveChain().empty()) {
                // chain is not empty when the condition is of length > 0
                ppFocusChains[focus].conjunctWith(positiveChain);
            }
        }
    }

    void resetFoci()
    {
        focusIterator.reset();
        ppFocusChains.clear();
    }

    bool operator == (const Task& other) const
    { return conditionIterator == other.conditionIterator; }

    bool operator != (const Task& other) const
    { return !(*this == other); }

    string toString() const
    { return conditionIterator.toString(); }

private:
    Iterator conditionIterator;
    Iterator focusIterator;

    DualChainType positiveChain;
    DualChainType prefixChain;
    unordered_map<int, DualChainType> ppFocusChains;
};
