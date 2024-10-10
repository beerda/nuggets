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
    using DataType = typename TASK::DataType;
    using DualChainType = typename TASK::DualChainType;

    ContiPnArgumentator(const vector<string>& fociNames)
        : fociNames(fociNames)
    { }

    void prepare(ArgumentValues& arguments, const TASK& task) const override
    {
        Argumentator<TASK>::prepare(arguments, task);

        ArgumentValue arg("pn", ArgumentType::ARG_NUMERIC);

        for (int i : task.getFocusIterator().getSoFar()) {
            arg.push_back(task.getPnFocusChain(i).getSum(), fociNames[i]);
        }

        arguments.push_back(arg);
    }

private:
    vector<string> fociNames;
};
