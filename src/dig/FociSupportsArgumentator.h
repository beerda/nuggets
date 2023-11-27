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

    FociSupportsArgumentator(const IntegerVector& predicates,
                             const IntegerVector& foci,
                             const IntegerVector& disjointPredicates,
                             const IntegerVector& disjointFoci,
                             const DataType& data)
        : predicates(predicates), foci(foci),
          disjointPredicates(disjointPredicates), disjointFoci(disjointFoci),
          data(data)
    { }

    void prepare(List& arguments, const TASK& task) const override
    {
        Argumentator<TASK>::prepare(arguments, task);

        CharacterVector names = foci.names();
        NumericVector supports;

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
            supports.push_back(chain.getSupport(), as<string>(names[i]));
        }

        arguments.push_back(supports, "foci_supports");
    }

private:
    IntegerVector predicates;
    IntegerVector foci;
    IntegerVector disjointPredicates;
    IntegerVector disjointFoci;
    const DataType& data;

    bool isFocusInCondition(const int id, const TASK& task) const
    {
        if (task.hasPredicate()) {
            if (foci[id] == predicates[task.getCurrentPredicate()])
                return true;
        }
        for (int pref : task.getPrefix()) {
            if (foci[id] == predicates[pref])
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
