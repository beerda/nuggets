#pragma once

#include <vector>
#include <set>
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

    Task(Iterator conditionIterator)
        : conditionIterator(conditionIterator)
    { }

    const Iterator& getConditionIterator() const
    { return conditionIterator; }

     Iterator& getMutableConditionIterator()
    { return conditionIterator; }

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

        Task result = Task(newConditionIterator);

        if (!chain.empty()) {
            result.prefixChain = chain;
        }

        return result;
    }

    const DualChainType& getChain() const
    { return chain; }

    const DualChainType& getPrefixChain() const
    { return prefixChain; }

    void updateChain(const DataType& data)
    {
        if (conditionIterator.hasPredicate()) {
            chain = data.getChain(conditionIterator.getCurrentPredicate());
            if (!prefixChain.empty()) {
                if (chain.isBitwise() != prefixChain.isBitwise() && chain.isNumeric() != prefixChain.isNumeric()) {
                    if (prefixChain.isBitwise()) {
                        prefixChain.toNumeric();
                    } else {
                        chain.toNumeric();
                    }
                }
                chain.conjunctWith(prefixChain);
            }
        }
    }

    bool operator == (const Task& other) const
    { return conditionIterator == other.conditionIterator; }

    bool operator != (const Task& other) const
    { return !(*this == other); }

    string toString() const
    { return conditionIterator.toString(); }

private:
    Iterator conditionIterator;

    DualChainType chain;

    DualChainType prefixChain;

};
