#pragma once

#include "Argumentator.h"


/**
 * Prepare the 'sum' argument for the R function callback. The 'sum' argument
 * is a double value with the sum of the condition in data. for logical data,
 * the sum equals to the count of rows satisfying the condition. For numerical
 * data, it equals to the sum of weights (membership degrees) of the rows
 * satisfying the condition.
 */
class SumArgumentator : public Argumentator {
public:
    SumArgumentator(size_t dataLength)
        : dataLength(1.0 * dataLength)
    { }

    void prepare(writable::list& arguments, const Task& task) const override
    {
        Argumentator::prepare(arguments, task);

        using namespace cpp11::literals;

        writable::doubles result;

        if (task.getChain().empty())
            result.push_back(dataLength);
        else
            result.push_back(task.getChain().getSum());

        arguments.push_back("sum"_nm = result);
    }

private:
    double dataLength;
};
