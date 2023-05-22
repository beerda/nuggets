#pragma once

#include "Task.hpp"


/**
 * This abstract class represents objects responsible for initialization of arguments for
 * the R callback function that is called on each generated condition.
 */
class Argumentator {
public:
    virtual void prepare(writable::list& arguments, const Task& task) const
    { }
};
