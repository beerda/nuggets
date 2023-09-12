#pragma once

#include "Argumentator.h"


/**
 * Prepare the 'support' argument for the R function callback. The 'support' argument
 * is a double value with the support of the condition in data.
 */
class SupportArgumentator : public Argumentator {
public:
    SupportArgumentator()
    { }

    void prepare(writable::list& arguments, const Task& task) const override
    {
        using namespace cpp11::literals;

        writable::doubles support;
        support.push_back(task.getChain().getSupport());
        arguments.push_back("support"_nm = support);
    }
};
