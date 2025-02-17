#pragma once

#include "Argumentator.h"


/**
 * Prepare the 'weights' argument for the R function callback. The 'weights' argument
 * is a double vector of size equal to the number of data rows, which represents the weights
 * of the rows accordingly to the current condition.
 */
template <typename TASK>
class WeightsArgumentator : public Argumentator<TASK> {
public:
    // Inherit constructors
    using Argumentator<TASK>::Argumentator;

    void prepare(ArgumentValues& arguments, const TASK& task) const override
    {
        Argumentator<TASK>::prepare(arguments, task);

        ArgumentValue arg("weights", ArgumentType::ARG_NUMERIC);

        if (task.getPositiveChain().empty()) {
            for (size_t i = 0; i < this->data.nrow(); i++) {
                arg.push_back(1.0);
            }
        }
        else {
            for (size_t i = 0; i < task.getPositiveChain().size(); i++) {
                arg.push_back(task.getPositiveChain().getValue(i));
            }
        }

        arguments.push_back(arg);
    }
};
