#pragma once

#include "Argumentator.h"

/**
 * Prepare the 'np' argument for the R function callback.
 * The 'np' argument is a double value with supports of
 * foci combined with the negated condition.
 */
template <typename TASK>
class ContiNpArgumentator : public Argumentator<TASK> {
public:
    using DataType = typename TASK::DataType;
    using DualChainType = typename TASK::DualChainType;

    ContiNpArgumentator(const vector<string>& fociNames)
        : fociNames(fociNames)
    { }

    void prepare(ArgumentValues& arguments, const TASK& task) const override
    {
        Argumentator<TASK>::prepare(arguments, task);

        ArgumentValue arg("np", ArgumentType::ARG_NUMERIC);

        for (int i : task.getFocusIterator().getSoFar()) {
            arg.push_back(task.getNpFocusChain(i).getSum(), fociNames[i]);
        }

        arguments.push_back(arg);
    }

private:
    vector<string> fociNames;
};