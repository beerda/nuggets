#pragma once

#include "../common.h"
#include <vector>


class Config {
public:
    Config(List configuration)
    {
        parseArguments(configuration["arguments"]);

        predicates = configuration["predicates"];
        foci = configuration["foci"];
        disjointPredicates = configuration["disjoint_predicates"];
        disjointFoci = configuration["disjoint_foci"];

        IntegerVector minLengthVec = configuration["minLength"];
        minLength = minLengthVec[0];

        IntegerVector maxLengthVec = configuration["maxLength"];
        maxLength = maxLengthVec[0];

        NumericVector minSupportVec = configuration["minSupport"];
        minSupport = minSupportVec[0];
    }

    bool hasConditionArgument() const
    { return conditionArgument; }

    bool hasFociSupportsArgument() const
    { return fociSupportsArgument; }

    bool hasIndicesArgument() const
    { return indicesArgument; }

    bool hasSumArgument() const
    { return sumArgument; }

    bool hasSupportArgument() const
    { return supportArgument; }

    bool hasWeightsArgument() const
    { return weightsArgument; }

    bool hasDisjointPredicates() const
    { return disjointPredicates.size() > 0; }

    bool hasDisjointFoci() const
    { return disjointFoci.size() > 0; }

    const IntegerVector& getPredicates() const
    { return predicates; }

    const IntegerVector& getFoci() const
    { return foci; }

    const IntegerVector& getDisjointPredicates() const
    { return disjointPredicates; }

    const IntegerVector& getDisjointFoci() const
    { return disjointFoci; }

    int getMinLength() const
    { return minLength; }

    int getMaxLength() const
    { return maxLength; }

    double getMinSupport() const
    { return minSupport; }

private:
    bool conditionArgument = false;
    bool fociSupportsArgument = false;
    bool indicesArgument = false;
    bool sumArgument = false;
    bool supportArgument = false;
    bool weightsArgument = false;

    IntegerVector predicates;
    IntegerVector foci;
    IntegerVector disjointPredicates;
    IntegerVector disjointFoci;
    int minLength;
    int maxLength;
    double minSupport;

    void parseArguments(const CharacterVector& vec)
    {
        for (size_t i = 0; i < vec.size(); ++i) {
            if (vec[i] == "condition")
                conditionArgument = true;
            if (vec[i] == "foci_supports")
                fociSupportsArgument = true;
            if (vec[i] == "indices")
                indicesArgument = true;
            if (vec[i] == "sum")
                sumArgument = true;
            if (vec[i] == "support")
                supportArgument = true;
            if (vec[i] == "weights")
                weightsArgument = true;
        }
    }
};
