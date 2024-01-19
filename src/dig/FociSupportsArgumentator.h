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

        for (size_t i = 0; i < data.fociSize(); i++) {
            if (isFocusInCondition(i, task))
                continue;

            if (isFocusDisjointWith(i, task))
                continue;

            DualChainType chain = data.getFocus(i);
            if (!task.getChain().empty()) {
                // chain is not empty when the condition is of length > 0
                chain.conjunctWith(task.getChain());
            }
            arg.push_back(chain.getSupport(), fociNames[i]);
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
        if (task.hasPredicate()) {
            if (fociIndices[id] == predicateIndices[task.getCurrentPredicate()])
                return true;
        }
        for (int pref : task.getPrefix()) {
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
        if (task.hasPredicate()) {
            if (currDisj == disjointPredicates[task.getCurrentPredicate()])
                return true;
        }
        for (int pref : task.getPrefix()) {
            if (currDisj == disjointPredicates[pref])
                return true;
        }

        return false;
    }
};
