#pragma once

#include "../common.h"
#include <vector>


class Config {
public:
    Config(List configuration)
    {
        IntegerVector nrowVec = configuration["nrow"];
        nrow = nrowVec[0];

        parseArguments(configuration["arguments"]);

        IntegerVector disjVec = configuration["disjoint"];
        disjoint.push_back(0); // 0th index is unused, as R uses predicates' indices starting from 1
        copy(disjVec, disjoint);

        excluded = configuration["excluded"];

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

        NumericVector minConditionalFocusSupportVec = configuration["minConditionalFocusSupport"];
        minConditionalFocusSupport = minConditionalFocusSupportVec[0];

        NumericVector maxSupportVec = configuration["maxSupport"];
        maxSupport = maxSupportVec[0];

        IntegerVector maxResultsVec = configuration["maxResults"];
        maxResults = maxResultsVec[0]; // -1 means infinite

        LogicalVector filterEmptyFociVec = configuration["filterEmptyFoci"];
        filterEmptyFoci = filterEmptyFociVec[0];

        if (configuration["tautologyLimit"] == R_NilValue) {
            tautologyLimitEnabled = false;
        } else {
            tautologyLimitEnabled = true;
            NumericVector tautologyLimitVec = configuration["tautologyLimit"];
            tautologyLimit = tautologyLimitVec[0];
        }

        LogicalVector verboseVec = configuration["verbose"];
        verbose = verboseVec[0];

        CharacterVector tnormVec = configuration["tNorm"];
        if (tnormVec[0] == "goedel")
            tNorm = TNorm::GOEDEL;
        else if (tnormVec[0] == "goguen")
            tNorm = TNorm::GOGUEN;
        else if (tnormVec[0] == "lukas")
            tNorm = TNorm::LUKASIEWICZ;
        else
            throw runtime_error("Unknown t-norm in Config");
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

    bool hasDisjoint() const
    { return disjoint.size() > 1; }

    bool hasTautologyLimit() const
    { return tautologyLimitEnabled; }

    double getTautologyLimit() const
    { return tautologyLimit; }

    const vector<int>& getDisjoint() const
    { return disjoint; }

    const List getExcluded() const
    { return excluded; }

    int getNrow() const
    { return nrow; }

    int getThreads() const
    { return threads; }

    int getMinLength() const
    { return minLength; }

    int getMaxLength() const
    { return maxLength; }

    int getMaxResults() const
    { return maxResults; }

    double getMinSupport() const
    { return minSupport; }

    double getMinFocusSupport() const
    { return minFocusSupport; }

    double getMinConditionalFocusSupport() const
    { return minConditionalFocusSupport; }

    double getMaxSupport() const
    { return maxSupport; }

    bool hasFilterEmptyFoci() const
    { return filterEmptyFoci; }

    bool isVerbose() const
    { return verbose; }

    TNorm getTNorm() const
    { return tNorm; }

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
    bool tautologyLimitEnabled = false;

    vector<int> disjoint;
    List excluded;

    int nrow;
    int threads;
    int minLength;
    int maxLength;
    int maxResults; // -1 means infinite
    double minSupport;
    double minFocusSupport;
    double minConditionalFocusSupport;
    double maxSupport;
    double tautologyLimit;
    bool filterEmptyFoci;
    bool verbose;
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
};
