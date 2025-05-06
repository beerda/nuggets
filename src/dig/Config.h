#pragma once

#include "../common.h"
#include <vector>


class Config {
public:
    Config(List configuration)
        : nrow(IntegerVector(configuration["nrow"])[0]),
          threads(IntegerVector(configuration["threads"])[0]),
          minLength(IntegerVector(configuration["minLength"])[0]),
          maxLength(IntegerVector(configuration["maxLength"])[0]),
          maxResults(IntegerVector(configuration["maxResults"])[0]), // -1 means infinite

          minSupport(NumericVector(configuration["minSupport"])[0]),
          minSum(minSupport * nrow),

          minFocusSupport(NumericVector(configuration["minFocusSupport"])[0]),
          minFocusSum(minFocusSupport * nrow),

          minConditionalFocusSupport(NumericVector(configuration["minConditionalFocusSupport"])[0]),
          maxSupport(NumericVector(configuration["maxSupport"])[0]),
          tautologyLimit(NumericVector(configuration["tautologyLimit"])[0]),

          filterEmptyFoci(LogicalVector(configuration["filterEmptyFoci"])[0]),
          verbose(LogicalVector(configuration["verbose"])[0]),

          tNorm(parseTNorm(configuration["tNorm"])),
          excluded(configuration["excluded"]),
          disjoint()
    {
        if (maxLength < 0) {
            maxLength = INT_MAX;
        }
        if (maxResults < 0) {
            maxResults = INT_MAX;
        }
        parseArguments(configuration["arguments"]);

        IntegerVector disjVec = configuration["disjoint"];
        disjoint.reserve(disjVec.size() + 1);
        disjoint.push_back(0); // 0th index is unused, as R uses predicates' indices starting from 1
        copy(disjVec, disjoint);
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

    bool hasFilterEmptyFoci() const
    { return filterEmptyFoci; }

    bool isVerbose() const
    { return verbose; }

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

    int getMinSum() const
    { return minSum; }

    double getMinFocusSupport() const
    { return minFocusSupport; }

    int getMinFocusSum() const
    { return minFocusSum; }

    double getMinConditionalFocusSupport() const
    { return minConditionalFocusSupport; }

    double getMaxSupport() const
    { return maxSupport; }

    TNorm getTNorm() const
    { return tNorm; }

private:
    int nrow;
    int threads;
    int minLength;
    int maxLength;
    int maxResults; // -1 means infinite
    double minSupport;
    int minSum;
    double minFocusSupport;
    int minFocusSum;
    double minConditionalFocusSupport;
    double maxSupport;
    double tautologyLimit;
    bool filterEmptyFoci;
    bool verbose;
    TNorm tNorm;
    List excluded;
    vector<int> disjoint;

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

    static void copy(const IntegerVector& source, vector<int>& values)
    {
        for (R_xlen_t i = 0; i < source.size(); ++i) {
            values.push_back(source[i]);
        }
    }

    static TNorm parseTNorm(const CharacterVector& vec)
    {
        if (vec[0] == "goguen")
            return TNorm::GOGUEN;
        else if (vec[0] == "lukas")
            return TNorm::LUKASIEWICZ;
        else
            return TNorm::GOEDEL;
    }

    void parseArguments(const CharacterVector& vec)
    {
        for (R_xlen_t i = 0; i < vec.size(); ++i) {
            if (vec[i] == "condition")
                conditionArgument = true;
            else if (vec[i] == "support")
                supportArgument = true;
            else if (vec[i] == "sum")
                sumArgument = true;
            else if (vec[i] == "pp")
                contiPpArgument = true;
            else if (vec[i] == "np")
                contiNpArgument = true;
            else if (vec[i] == "pn")
                contiPnArgument = true;
            else if (vec[i] == "nn")
                contiNnArgument = true;
            else if (vec[i] == "indices")
                indicesArgument = true;
            else if (vec[i] == "weights")
                weightsArgument = true;
            else if (vec[i] == "foci_supports")
                fociSupportsArgument = true;
        }
    }
};
