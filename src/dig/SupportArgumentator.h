#pragma once

#include "Argumentator.h"


/**
 * Prepare the 'support' argument for the R function callback. The 'support' argument
 * is a double value with the support of the condition in data.
 */
template <typename TASK>
class SupportArgumentator : public Argumentator<TASK> {
public:
    SupportArgumentator()
    { }

    void prepare(List& arguments, const TASK& task) const override
    {
        Argumentator<TASK>::prepare(arguments, task);

        NumericVector support;
        support.push_back(task.getChain().getSupport());
        arguments.push_back(support, "support");
    }
};
