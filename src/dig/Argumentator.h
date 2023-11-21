#pragma once

#include "Task.h"


/**
 * This abstract class represents objects responsible for initialization of arguments for
 * the R callback function that is called on each generated condition.
 */
class Argumentator {
public:
    virtual ~Argumentator()
    { }

    virtual void prepare(List& arguments, const Task& task) const
    { }
};
