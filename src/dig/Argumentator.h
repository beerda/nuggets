#pragma once

#include "Task.h"


/**
 * This abstract class represents objects responsible for initialization of arguments for
 * the R callback function that is called on each generated condition.
 */
template <typename TASK>
class Argumentator {
public:
    virtual ~Argumentator()
    { }

    virtual void prepare(List& arguments, const TASK& task) const
    { }
};
