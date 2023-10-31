#pragma once

#include "Filter.h"


class MinLengthFilter : public Filter {
public:
    MinLengthFilter(int minLength)
        : minLength(minLength)
    { }

    bool isStorable(const Task& task) const override
    { return ((int) task.getLength()) >= minLength; }

private:
    int minLength;
};
