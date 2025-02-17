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
    // Inherit constructors
    using Argumentator<TASK>::Argumentator;

    void prepare(ArgumentValues& arguments, const TASK& task) const override
    {
        Argumentator<TASK>::prepare(arguments, task);

        ArgumentValue arg("foci_supports", ArgumentType::ARG_NUMERIC);

        for (int i : task.getFocusIterator().getStored()) {
            arg.push_back(task.getPpFocusChain(i).getSupport(), this->data.getName(i));
        }

        arguments.push_back(arg);
    }
};
