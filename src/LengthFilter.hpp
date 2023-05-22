#pragma once

#include "Filter.hpp"


class LengthFilter : public Filter {
public:
    LengthFilter(int maxLength)
        : maxLength(maxLength)
    { }

    bool isRedundant(const Task& task) const override
    { return task.getLength() > maxLength; }

private:
    int maxLength;
};
