#pragma once

#include "Argumentator.h"


/**
 * Prepare the 'condition' argument for the R function callback. The 'condition' argument
 * is an integer vector of column indices, which represents the conjunctive condition.
 */
template <typename TASK>
class ConditionArgumentator : public Argumentator<TASK> {
public:
    // Inherit constructors
    using Argumentator<TASK>::Argumentator;

    void prepare(ArgumentValues& arguments, const TASK& task) const override
    {
        Argumentator<TASK>::prepare(arguments, task);

        ArgumentValue arg("condition", ArgumentType::ARG_INTEGER);

        for (int p : task.getConditionIterator().getCurrentCondition()) {
            arg.push_back(p, this->data.getName(p));
        }

        arguments.push_back(arg);
    }
};
