#pragma once

#include "Argumentator.hpp"


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
        using namespace cpp11::literals;

        writable::integers condition;
        for (int p : task.getCurrentCondition()) {
            condition.push_back(predicates[p]);
        }
        arguments.push_back("condition"_nm = condition);
    }
private:
    integers predicates;
};
