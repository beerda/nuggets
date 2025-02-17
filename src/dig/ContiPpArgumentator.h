#pragma once

#include "Argumentator.h"

/**
 * Prepare the 'pp' argument for the R function callback.
 * The 'pp' argument is a double value with supports of
 * foci combined with the condition.
 */
template <typename TASK>
class ContiPpArgumentator : public Argumentator<TASK> {
public:
    // Inherit constructors
    using Argumentator<TASK>::Argumentator;

    void prepare(ArgumentValues& arguments, const TASK& task) const override
    {
        Argumentator<TASK>::prepare(arguments, task);

        ArgumentValue arg("pp", ArgumentType::ARG_NUMERIC);

        for (int i : task.getFocusIterator().getStored()) {
            arg.push_back(task.getPpFocusChain(i).getSum(), this->data.getName(i));
        }

        arguments.push_back(arg);
    }
};
