#pragma once

#include "Argumentator.h"

/**
 * Prepare the 'nn' argument for the R function callback.
 * The 'nn' argument is a double value with supports of
 * foci combined with the condition.
 */
template <typename TASK>
class ContiNnArgumentator : public Argumentator<TASK> {
public:
    // Inherit constructors
    using Argumentator<TASK>::Argumentator;

    void prepare(ArgumentValues& arguments, const TASK* task) const override
    {
        Argumentator<TASK>::prepare(arguments, task);

        ArgumentValue arg("nn", ArgumentType::ARG_NUMERIC);

        for (int i : task->getFocusIterator().getStored()) {
            arg.push_back(task->getNnFocusChain(i).getSum(), this->data.getName(i));
        }

        arguments.push_back(arg);
    }
};
