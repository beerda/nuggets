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
        for (R_xlen_t i = 0; i < data.size(); ++i) {
            addCondition(data[i]);
        }
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
