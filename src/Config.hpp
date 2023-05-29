#pragma once

#include "common.hpp"
#include <vector>


class Config {
public:
    Config(list configuration)
    {
        parseArguments(configuration["arguments"]);

        predicates = configuration["predicates"];
        disjoint = configuration["disjoint"];

        integers minLengthVec = configuration["minLength"];
        minLength = minLengthVec[0];

        integers maxLengthVec = configuration["maxLength"];
        maxLength = maxLengthVec[0];

        doubles minSupportVec = configuration["minSupport"];
        minSupport = minSupportVec[0];
    }

    bool hasConditionArgument() const
    { return conditionArgument; }

    bool hasIndicesArgument() const
    { return indicesArgument; }

    bool hasSupportArgument() const
    { return supportArgument; }

    bool hasWeightsArgument() const
    { return weightsArgument; }

    bool hasDisjoint() const
    { return !disjoint.empty(); }

    const integers& getPredicates() const
    { return predicates; }

    const integers& getDisjoint() const
    { return disjoint; }

    int getMinLength() const
    { return minLength; }

    int getMaxLength() const
    { return maxLength; }

    double getMinSupport() const
    { return minSupport; }

private:
    bool conditionArgument = false;
    bool indicesArgument = false;
    bool supportArgument = false;
    bool weightsArgument = false;

    integers predicates;
    integers disjoint;
    int minLength;
    int maxLength;
    double minSupport;

    void parseArguments(strings vec)
    {
        for (string s : vec) {
            if (s == "condition")
                conditionArgument = true;
            if (s == "indices")
                indicesArgument = true;
            if (s == "support")
                supportArgument = true;
            if (s == "weights")
                weightsArgument = true;
        }
    }
};
