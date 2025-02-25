#pragma once

#include <vector>
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
            vector<int> newPrefix = conditionIterator.getPrefix();
            newPrefix.push_back(conditionIterator.getCurrentPredicate());
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

    void setDeducedPredicates(const vector<int>& deduced)
    { deducedPredicates = deduced; }

    const vector<int>& getDeducedPredicates() const
    { return deducedPredicates; }

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
            positiveChain = data.getPositiveChain(predicate); // always either numeric or bitwise+numeric
            if (!prefixChain.empty()) {
                if (positiveChain.isBitwise() != prefixChain.isBitwise() && positiveChain.isNumeric() != prefixChain.isNumeric()) {
                    if (prefixChain.isBitwise()) {
                        prefixChain.toNumeric();
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
            ppFocusChains[focus] = data.getPositiveChain(focus); // always either numeric or bitwise+numeric
            if (conditionIterator.getLength() > 0) {
                if (ppFocusChains[focus].isBitwise() != positiveChain.isBitwise() && ppFocusChains[focus].isNumeric() != positiveChain.isNumeric()) {
                    if (positiveChain.isBitwise()) {
                        positiveChain.toNumeric();
                    }
                }
                ppFocusChains[focus].conjunctWith(positiveChain);
            }
        }
    }

    void computePnFocusChain(const DataType& data)
    {
        if (focusIterator.hasPredicate()) {
            int focus = focusIterator.getCurrentPredicate();
            pnFocusChains[focus] = data.getNegativeChain(focus); // always either numeric or bitwise+numeric
            if (conditionIterator.getLength() > 0) {
                if (pnFocusChains[focus].isBitwise() != positiveChain.isBitwise() && pnFocusChains[focus].isNumeric() != positiveChain.isNumeric()) {
                    if (positiveChain.isBitwise()) {
                        positiveChain.toNumeric();
                    }
                }
                pnFocusChains[focus].conjunctWith(positiveChain);
            }
        }
    }

    void computeNpFocusChain(const DataType& data)
    {
        if (focusIterator.hasPredicate()) {
            int focus = focusIterator.getCurrentPredicate();
            npFocusChains[focus] = data.getPositiveChain(focus); // always either numeric or bitwise+numeric
            if (conditionIterator.getLength() > 0) {
                if (npFocusChains[focus].isBitwise() != negativeChain.isBitwise() && npFocusChains[focus].isNumeric() != negativeChain.isNumeric()) {
                    if (negativeChain.isBitwise()) {
                        negativeChain.toNumeric();
                    }
                }
                npFocusChains[focus].conjunctWith(negativeChain);
            }
        }
    }

    void computeNnFocusChain(const DataType& data)
    {
        if (focusIterator.hasPredicate()) {
            int focus = focusIterator.getCurrentPredicate();
            nnFocusChains[focus] = data.getNegativeChain(focus); // always either numeric or bitwise+numeric
            if (conditionIterator.getLength() > 0) {
                if (nnFocusChains[focus].isBitwise() != negativeChain.isBitwise() && nnFocusChains[focus].isNumeric() != negativeChain.isNumeric()) {
                    if (negativeChain.isBitwise()) {
                        negativeChain.toNumeric();
                    }
                }
                nnFocusChains[focus].conjunctWith(negativeChain);
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
    { return "(condition: " + conditionIterator.toString() + ")(focus: " + focusIterator.toString() + ")"; }

private:
    Iterator conditionIterator;
    Iterator focusIterator;
    vector<int> deducedPredicates;

    DualChainType prefixChain;
    DualChainType positiveChain;
    DualChainType negativeChain;
    unordered_map<int, DualChainType> ppFocusChains;
    unordered_map<int, DualChainType> npFocusChains;
    unordered_map<int, DualChainType> pnFocusChains;
    unordered_map<int, DualChainType> nnFocusChains;
};
