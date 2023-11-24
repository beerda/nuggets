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
    IndicesArgumentator(size_t dataSize)
        : dataSize(dataSize)
    { }

    void prepare(List& arguments, const TASK& task) const override
    {
        Argumentator<TASK>::prepare(arguments, task);

        LogicalVector indices;

        if (task.getChain().empty()) {
            for (size_t i = 0; i < dataSize; i++) {
                indices.push_back(true);
            }
        }
        else {
            for (size_t i = 0; i < task.getChain().size(); i++) {
                indices.push_back(task.getChain().getValue(i) > 0);
            }
        }
        arguments.push_back(indices, "indices");
    }

private:
    size_t dataSize;
};
