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

    const DualChainType& getNegativeChain() const
    { return negativeChain; }

    const DualChainType& getPrefixChain() const
    { return prefixChain; }

    const DualChainType& getPpFocusChain(int focus) const
    { return ppFocusChains.at(focus); }

    const DualChainType& getNpFocusChain(int focus) const
    { return npFocusChains.at(focus); }

    const DualChainType& getPnFocusChain(int focus) const
    { return pnFocusChains.at(focus); }

    const DualChainType& getNnFocusChain(int focus) const
    { return nnFocusChains.at(focus); }

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

    void updateNegativeChain(const DataType& data)
    {
        // assert positiveChain is already updated

        negativeChain = positiveChain;
        negativeChain.negate();
    }

    void computePpFocusChain(const DataType& data)
    {
        if (focusIterator.hasPredicate()) {
            int focus = focusIterator.getCurrentPredicate();
            ppFocusChains[focus] = data.getFocus(focus);
            if (conditionIterator.getLength() > 0) {
                ppFocusChains[focus].conjunctWith(positiveChain);
            }
        }
    }

    void computePnFocusChain(const DataType& data)
    {
        if (focusIterator.hasPredicate()) {
            int focus = focusIterator.getCurrentPredicate();
            pnFocusChains[focus] = data.getNegativeFocus(focus);
            if (conditionIterator.getLength() > 0) {
                pnFocusChains[focus].conjunctWith(positiveChain);
            }
        }
    }

    void computeNpFocusChain(const DataType& data)
    {
        if (focusIterator.hasPredicate()) {
            int focus = focusIterator.getCurrentPredicate();
            if (conditionIterator.getLength() > 0) {
                npFocusChains[focus] = data.getFocus(focus);
                npFocusChains[focus].conjunctWith(negativeChain);
            } else {
                // result is empty chain because we work with condition of length 0 (tautology)
                // and hence the negation of tautology is contradiction.
                // Empty chain indicates contradiction here.
                npFocusChains[focus] = positiveChain;
            }
        }
    }

    void computeNnFocusChain(const DataType& data)
    {
        if (focusIterator.hasPredicate()) {
            int focus = focusIterator.getCurrentPredicate();
            if (conditionIterator.getLength() > 0) {
                nnFocusChains[focus] = data.getNegativeFocus(focus);
                nnFocusChains[focus].conjunctWith(negativeChain);
            } else {
                // result is empty chain because we work with condition of length 0 (tautology)
                // and hence the negation of tautology is contradiction.
                // Empty chain indicates contradiction here.
                nnFocusChains[focus] = positiveChain;
            }
        }
    }

    void resetFoci()
    {
        focusIterator.reset();
        ppFocusChains.clear();
        npFocusChains.clear();
        pnFocusChains.clear();
        nnFocusChains.clear();
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

    DualChainType prefixChain;
    DualChainType positiveChain;
    DualChainType negativeChain;
    unordered_map<int, DualChainType> ppFocusChains;
    unordered_map<int, DualChainType> npFocusChains;
    unordered_map<int, DualChainType> pnFocusChains;
    unordered_map<int, DualChainType> nnFocusChains;
};
