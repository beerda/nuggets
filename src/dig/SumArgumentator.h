#pragma once

#include "Argumentator.h"


/**
 * Prepare the 'sum' argument for the R function callback. The 'sum' argument
 * is a double value with the sum of the condition in data. for logical data,
 * the sum equals to the count of rows satisfying the condition. For numerical
 * data, it equals to the sum of weights (membership degrees) of the rows
 * satisfying the condition.
 */
template <typename TASK>
class SumArgumentator : public Argumentator<TASK> {
public:
    SumArgumentator(size_t dataLength)
        : dataLength(1.0 * dataLength)
    { }

    void prepare(ArgumentValues& arguments, const TASK& task) const override
    {
        Argumentator<TASK>::prepare(arguments, task);

        ArgumentValue arg("sum", ArgumentType::ARG_NUMERIC);

        if (task.getChain().empty())
            arg.push_back(dataLength);
        else
            arg.push_back(task.getChain().getSum());

        arguments.push_back(arg);
    }

private:
    double dataLength;
};
