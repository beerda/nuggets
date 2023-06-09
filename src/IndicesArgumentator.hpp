#pragma once

#include "Argumentator.hpp"


/**
 * Prepare the 'indices' argument for the R function callback. The 'indices' argument
 * is a logical vector of size equal to the number of data rows, that represents selected
 * rows by the current condition. For numeric inputs, 'TRUE' appears wherever the row's
 * weight is greater than 0.
 */
class IndicesArgumentator : public Argumentator {
public:
    IndicesArgumentator(size_t dataSize)
        : dataSize(dataSize)
    { }

    void prepare(writable::list& arguments, const Task& task) const override
    {
        using namespace cpp11::literals;
        writable::logicals indices;

        indices.reserve(dataSize);
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
        arguments.push_back("indices"_nm = indices);
    }

private:
    size_t dataSize;
};
