#pragma once

#include "Filter.h"


class MaxLengthFilter : public Filter {
public:
    MaxLengthFilter(int maxLength)
        : maxLength(maxLength)
    { }

    bool isRedundant(const Task& task) const override
    { return ((int) task.getLength()) > maxLength; }

private:
    int maxLength;
};
