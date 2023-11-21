#pragma once

#include <vector>
#include "../common.h"
#include "Condition.h"


class AntichainData {
public:
    AntichainData()
    { }

    AntichainData(List data)
    {
        for (const IntegerVector& values : data)
            addCondition(values);
    }

    void addCondition(const IntegerVector& values)
    { conditions.push_back(Condition(values)); }

    const Condition& getCondition(size_t i) const
    { return conditions.at(i); }

    size_t size() const
    { return conditions.size(); }

private:
    vector<Condition> conditions;
};
