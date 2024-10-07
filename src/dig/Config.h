#pragma once

#include "../common.h"
#include <vector>


class Config {
public:
    Config(List configuration)
    {
        parseArguments(configuration["arguments"]);

        IntegerVector predicates = configuration["predicates"];
        copy(predicates, predicateIndices, predicateNames);

        IntegerVector foci = configuration["foci"];
        copy(foci, fociIndices, fociNames);

        IntegerVector disjPred = configuration["disjoint_predicates"];
        copy(disjPred, disjointPredicates);

        IntegerVector disjFoci = configuration["disjoint_foci"];
        copy(disjFoci, disjointFoci);

        IntegerVector threadsVec = configuration["threads"];
        threads = threadsVec[0];

        IntegerVector minLengthVec = configuration["minLength"];
        minLength = minLengthVec[0];

        IntegerVector maxLengthVec = configuration["maxLength"];
        maxLength = maxLengthVec[0];

        NumericVector minSupportVec = configuration["minSupport"];
        minSupport = minSupportVec[0];

        NumericVector minFocusSupportVec = configuration["minFocusSupport"];
        minFocusSupport = minFocusSupportVec[0];

        LogicalVector filterEmptyFociVec = configuration["filterEmptyFoci"];
        filterEmptyFoci = filterEmptyFociVec[0];

        CharacterVector tnormVec = configuration["tNorm"];
        if (tnormVec[0] == "goedel")
            tNorm = TNorm::GOEDEL;
        else if (tnormVec[0] == "goguen")
            tNorm = TNorm::GOGUEN;
        else if (tnormVec[0] == "lukas")
            tNorm = TNorm::LUKASIEWICZ;
        else
            throw new runtime_error("Unknown t-norm in Config");
    }

    bool hasConditionArgument() const
    { return conditionArgument; }

    bool hasFociSupportsArgument() const
    { return fociSupportsArgument; }

    bool hasContiPpArgument() const
    { return contiPpArgument; }

    bool hasContiNpArgument() const
    { return contiNpArgument; }

    bool hasContiPnArgument() const
    { return contiPnArgument; }

    bool hasContiNnArgument() const
    { return contiNnArgument; }

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

    const vector<int>& getPredicateIndices() const
    { return predicateIndices; }

    const vector<string>& getPredicateNames() const
    { return predicateNames; }

    const vector<int>& getFociIndices() const
    { return fociIndices; }

    const vector<string>& getFociNames() const
    { return fociNames; }

    const vector<int>& getDisjointPredicates() const
    { return disjointPredicates; }

    const vector<int>& getDisjointFoci() const
    { return disjointFoci; }

    int getThreads() const
    { return threads; }

    int getMinLength() const
    { return minLength; }

    int getMaxLength() const
    { return maxLength; }

    double getMinSupport() const
    { return minSupport; }

    double getMinFocusSupport() const
    { return minFocusSupport; }

    bool hasFilterEmptyFoci() const
    { return filterEmptyFoci; }

    TNorm getTNorm() const
    { return tNorm; }

    void permuteConditions(const vector<size_t> permutation)
    {
        vector<int> newPredicateIndices;
        permute(predicateIndices, newPredicateIndices, permutation);
        predicateIndices = newPredicateIndices;

        vector<string> newPredicateNames;
        permute(predicateNames, newPredicateNames, permutation);
        predicateNames = newPredicateNames;

        vector<int> newDisjointPredicates;
        permute(disjointPredicates, newDisjointPredicates, permutation);
        disjointPredicates = newDisjointPredicates;
    }

private:
    bool conditionArgument = false;
    bool fociSupportsArgument = false;
    bool contiPpArgument = false;
    bool contiNpArgument = false;
    bool contiPnArgument = false;
    bool contiNnArgument = false;
    bool indicesArgument = false;
    bool sumArgument = false;
    bool supportArgument = false;
    bool weightsArgument = false;

    vector<int> predicateIndices;
    vector<string> predicateNames;

    vector<int> fociIndices;
    vector<string> fociNames;

    vector<int> disjointPredicates;
    vector<int> disjointFoci;

    int threads;
    int minLength;
    int maxLength;
    double minSupport;
    double minFocusSupport;
    bool filterEmptyFoci;
    TNorm tNorm;

    void parseArguments(const CharacterVector& vec)
    {
        for (R_xlen_t i = 0; i < vec.size(); ++i) {
            if (vec[i] == "condition")
                conditionArgument = true;
            if (vec[i] == "foci_supports")
                fociSupportsArgument = true;
            if (vec[i] == "pp")
                contiPpArgument = true;
            if (vec[i] == "np")
                contiNpArgument = true;
            if (vec[i] == "pn")
                contiPnArgument = true;
            if (vec[i] == "nn")
                contiNnArgument = true;
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

    void copy(const IntegerVector& source, vector<int>& values)
    {
        for (R_xlen_t i = 0; i < source.size(); ++i) {
            values.push_back(source[i]);
        }
    }

    void copy(const IntegerVector& source, vector<int>& values, vector<string>& names)
    {
        if (!source.hasAttribute("names")) {
            copy(source, values);
        } else {
            CharacterVector sourceNames = source.names();
            for (R_xlen_t i = 0; i < source.size(); ++i) {
                names.push_back(as<string>(sourceNames[i]));
                values.push_back(source[i]);
            }
        }
    }

    template <typename T>
    void permute(const vector<T>& source, vector<T>& target, const vector<size_t>& permutation)
    {
        target.resize(source.size());
        for (size_t i = 0; i < source.size(); ++i) {
            target[i] = source[permutation[i]];
        }
    }
};
