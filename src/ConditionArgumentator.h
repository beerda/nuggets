#pragma once

#include "Argumentator.h"


/**
 * Prepare the 'condition' argument for the R function callback. The 'condition' argument
 * is an integer vector of column indices, which represents the conjunctive condition.
 */
class ConditionArgumentator : public Argumentator {
public:
    ConditionArgumentator(const integers& predicates)
        : predicates(predicates)
    { }

    void prepare(writable::list& arguments, const Task& task) const override
    {
        Argumentator::prepare(arguments, task);

        using namespace cpp11::literals;
        writable::strings names;
        writable::integers indices;

        for (int p : task.getCurrentCondition()) {
            names.push_back(predicates.names()[p]);
            indices.push_back(predicates[p]);
        }
        if (!indices.empty()) {
            indices.attr("names") = names;
        }

        arguments.push_back("condition"_nm = indices);
    }

private:
    integers predicates;
};
