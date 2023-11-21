#pragma once

#include "Argumentator.h"


/**
 * Prepare the 'condition' argument for the R function callback. The 'condition' argument
 * is an integer vector of column indices, which represents the conjunctive condition.
 */
class ConditionArgumentator : public Argumentator {
public:
    ConditionArgumentator(const IntegerVector& predicates)
        : predicates(predicates)
    { }

    void prepare(List& arguments, const Task& task) const override
    {
        Argumentator::prepare(arguments, task);

        CharacterVector names = predicates.names();
        IntegerVector indices;

        for (int p : task.getCurrentCondition()) {
            indices.push_back(predicates[p], as<string>(names[p]));
        }

        arguments.push_back(indices, "condition");
    }

private:
    IntegerVector predicates;
};
