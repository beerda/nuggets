#pragma once

#include "Argumentator.h"

/**
 * Prepare the 'fociSupports' argument for the R function callback.
 * The 'fociSupports' argument is a double value with supports of
 * foci combined with the condition.
 */
template <typename TASK>
class FociSupportsArgumentator : public Argumentator<TASK> {
public:
    using DataType = typename TASK::DataType;
    using DualChainType = typename TASK::DualChainType;

    FociSupportsArgumentator(const vector<int>& predicateIndices,
                             const vector<int>& fociIndices,
                             const vector<string>& fociNames,
                             const vector<int>& disjointPredicates,
                             const vector<int>& disjointFoci,
                             const DataType& data)
        : predicateIndices(predicateIndices),
          fociIndices(fociIndices), fociNames(fociNames),
          disjointPredicates(disjointPredicates), disjointFoci(disjointFoci),
          data(data)
    { }

    void prepare(ArgumentValues& arguments, const TASK& task) const override
    {
        Argumentator<TASK>::prepare(arguments, task);

        ArgumentValue arg("foci_supports", ArgumentType::ARG_NUMERIC);

        for (int i : task.getFocusIterator().getSoFar()) {
            if (isFocusInCondition(i, task))
                continue;

            if (isFocusDisjointWith(i, task))
                continue;

            arg.push_back(task.getFocusChain(i).getSupport(), fociNames[i]);
        }

        arguments.push_back(arg);
    }

private:
    vector<int> predicateIndices;
    vector<int> fociIndices;
    vector<string> fociNames;
    vector<int> disjointPredicates;
    vector<int> disjointFoci;
    const DataType& data;

    bool isFocusInCondition(const int id, const TASK& task) const
    {
        if (task.getConditionIterator().hasPredicate()) {
            if (fociIndices[id] == predicateIndices[task.getConditionIterator().getCurrentPredicate()])
                return true;
        }
        for (int pref : task.getConditionIterator().getPrefix()) {
            if (fociIndices[id] == predicateIndices[pref])
                return true;
        }

        return false;
    }

    bool isFocusDisjointWith(const int id, const TASK& task) const
    {
        if (disjointPredicates.size() <= 0)
            return false;

        if (disjointFoci.size() <= 0)
            return false;

        int currDisj = disjointFoci[id];
        if (task.getConditionIterator().hasPredicate()) {
            if (currDisj == disjointPredicates[task.getConditionIterator().getCurrentPredicate()])
                return true;
        }
        for (int pref : task.getConditionIterator().getPrefix()) {
            if (currDisj == disjointPredicates[pref])
                return true;
        }

        return false;
    }
};
