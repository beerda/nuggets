#pragma once

#include "Argumentator.h"

/**
 * Prepare the 'conti_np' argument for the R function callback.
 * The 'conti_np' argument is a double value with supports of
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

        ArgumentValue arg("conti_np", ArgumentType::ARG_NUMERIC);

        for (int i : task.getFocusIterator().getSoFar()) {
            DualChainType chain = task.getNpFocusChain(i);
            if (chain.empty()) {
                // special case: empty chain occurs on empty condition and indicates contradiction
                // (see Task::computeNpFocusChain)
                arg.push_back(0.0, fociNames[i]);
            } else {
                arg.push_back(chain.getSupport(), fociNames[i]);
            }
        }

        arguments.push_back(arg);
    }

private:
    vector<string> fociNames;
};
