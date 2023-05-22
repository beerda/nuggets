#pragma once

#include "Task.hpp"


class Argumentator {
public:
    virtual void prepare(writable::list& arguments, const Task& task) const
    { }
};
