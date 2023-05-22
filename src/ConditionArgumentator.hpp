#pragma once

#include "Argumentator.hpp"


class ConditionArgumentator : public Argumentator {
public:
    void prepare(writable::list& arguments, const Task& task) const override
    {
        using namespace cpp11::literals;

        writable::integers condition;
        for (int p : task.getCurrentCondition()) {
            condition.push_back(p);
        }
        arguments.push_back("condition"_nm = condition);
    }
};
