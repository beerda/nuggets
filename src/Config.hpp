#pragma once

#include "common.hpp"
#include <vector>


class Config {
public:
    Config(list configuration)
    {
        parseArguments(configuration["arguments"]);
        predicates = configuration["predicates"];
        integers maxLengthVec = configuration["maxLength"];
        maxLength = maxLengthVec[0];
    }

    bool hasConditionArgument() const
    { return conditionArgument; }

    const integers& getPredicates() const
    { return predicates; }

    int getMaxLength() const
    { return maxLength; }

private:
    bool conditionArgument = false;
    integers predicates;
    int maxLength;

    void parseArguments(strings vec)
    {
        for (string s : vec) {
            if (s == "condition")
                conditionArgument = true;
        }
    }
};
