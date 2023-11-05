#pragma once

#include "Argumentator.h"

/**
 * Prepare the 'fociSupports' argument for the R function callback.
 * The 'fociSupports' argument is a double value with supports of
 * foci combined with the condition.
 */
class FociSupportsArgumentator : public Argumentator {
public:
    FociSupportsArgumentator(const integers& predicates,
                             const integers& foci,
                             const integers& disjointPredicates,
                             const integers& disjointFoci,
                             const Data& data)
        : predicates(predicates), foci(foci),
          disjointPredicates(disjointPredicates), disjointFoci(disjointFoci),
          data(data)
    { }

    void prepare(writable::list& arguments, const Task& task) const override
    {
        Argumentator::prepare(arguments, task);

        using namespace cpp11::literals;
        writable::strings names;
        writable::doubles supports;

        for (size_t i = 0; i < data.fociSize(); i++) {
            if (isFocusInCondition(i, task))
                continue;

            if (isFocusDisjointWith(i, task))
                continue;

            names.push_back(foci.names()[i]);
            DualChain chain = data.getFocus(i);
            if (!task.getChain().empty()) {
                // chain is not empty when the condition is of length > 0
                chain.combineWith(task.getChain());
            }
            supports.push_back(chain.getSupport());
        }
        if (!supports.empty()) {
            supports.attr("names") = names;
        }

        arguments.push_back("foci_supports"_nm = supports);
    }

private:
    integers predicates;
    integers foci;
    integers disjointPredicates;
    integers disjointFoci;
    const Data& data;

    bool isFocusInCondition(const int id, const Task& task) const
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

    bool isFocusDisjointWith(const int id, const Task& task) const
    {
        if (disjointPredicates.empty())
            return false;

        if (disjointFoci.empty())
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
