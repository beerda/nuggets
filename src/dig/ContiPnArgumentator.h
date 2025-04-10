#pragma once

#include "Argumentator.h"

/**
 * Prepare the 'pn' argument for the R function callback.
 * The 'pn' argument is a double value with supports of
 * foci combined with the condition.
 */
template <typename TASK>
class ContiPnArgumentator : public Argumentator<TASK> {
public:
    // Inherit constructors
    using Argumentator<TASK>::Argumentator;

    void prepare(ArgumentValues& arguments, const TASK* task) const override
    {
        Argumentator<TASK>::prepare(arguments, task);

        ArgumentValue arg("pn", ArgumentType::ARG_NUMERIC);

        for (int i : task->getFocusIterator().getStored()) {
            arg.push_back(task->getPnFocusChain(i).getSum(), this->data.getName(i));
        }

        arguments.push_back(arg);
    }
};
