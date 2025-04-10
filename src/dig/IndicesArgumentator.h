#pragma once

#include "Argumentator.h"


/**
 * Prepare the 'indices' argument for the R function callback. The 'indices' argument
 * is a logical vector of size equal to the number of data rows, that represents selected
 * rows by the current condition. For numeric inputs, 'TRUE' appears wherever the row's
 * weight is greater than 0.
 */
template <typename TASK>
class IndicesArgumentator : public Argumentator<TASK> {
public:
    // Inherit constructors
    using Argumentator<TASK>::Argumentator;

    void prepare(ArgumentValues& arguments, const TASK* task) const override
    {
        Argumentator<TASK>::prepare(arguments, task);

        ArgumentValue arg("indices", ArgumentType::ARG_LOGICAL);
        if (task->getPositiveChain().empty()) {
            for (size_t i = 0; i < this->data.nrow(); i++) {
                arg.push_back(true);
            }
        }
        else {
            for (size_t i = 0; i < task->getPositiveChain().size(); i++) {
                arg.push_back(task->getPositiveChain().getValue(i) > 0);
            }
        }

        arguments.push_back(arg);
    }
};
