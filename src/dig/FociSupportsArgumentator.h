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
    using DataType = typename TASK::DataType;
    using DualChainType = typename TASK::DualChainType;

    FociSupportsArgumentator(const vector<string>& fociNames)
        : fociNames(fociNames)
    { }

    void prepare(ArgumentValues& arguments, const TASK& task) const override
    {
        Argumentator<TASK>::prepare(arguments, task);

        ArgumentValue arg("foci_supports", ArgumentType::ARG_NUMERIC);

        for (int i : task.getFocusIterator().getSoFar()) {
            arg.push_back(task.getFocusChain(i).getSupport(), fociNames[i]);
        }

        arguments.push_back(arg);
    }

private:
    vector<string> fociNames;
};
