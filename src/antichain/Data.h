#pragma once

#include <vector>
#include "Condition.h"


class Data {
public:
    Data()
    { }

    Data(const list& data)
    {
        for (const integers& values : data)
            addCondition(values);
    }

    void addCondition(const integers& values)
    { conditions.push_back(Condition(values)); }

    const Condition& getCondition(size_t i) const
    { return conditions.at(i); }

    size_t size() const
    { return conditions.size(); }

private:
    vector<Condition> conditions;
};
