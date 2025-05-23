#pragma once

#include "../common.h"
#include <vector>


class Config {
public:
    Config(List configuration, CharacterVector namesVector)
        : nrow(as<IntegerVector>(configuration["nrow"])[0]),
          threads(as<IntegerVector>(configuration["threads"])[0]),
          minLength(as<IntegerVector>(configuration["minLength"])[0]),
          maxLength(as<IntegerVector>(configuration["maxLength"])[0]),
          maxResults(as<IntegerVector>(configuration["maxResults"])[0]), // -1 means infinite

          minSupport(as<NumericVector>(configuration["minSupport"])[0]),
          minSum(minSupport * nrow),

          minFocusSupport(as<NumericVector>(configuration["minFocusSupport"])[0]),
          minFocusSum(minFocusSupport * nrow),

          minConditionalFocusSupport(as<NumericVector>(configuration["minConditionalFocusSupport"])[0]),

          maxSupport(as<NumericVector>(configuration["maxSupport"])[0]),
          maxSum(maxSupport * nrow),

          tautologyLimit(as<NumericVector>(configuration["tautologyLimit"])[0]),
          tNorm(parseTNorm(configuration["tNorm"])),
          excluded(as<List>(configuration["excluded"])),
          disjoint(),
          chainNames(),
          filterEmptyFoci(as<LogicalVector>(configuration["filterEmptyFoci"])[0]),
          verbose(as<LogicalVector>(configuration["verbose"])[0])
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
        for (R_xlen_t i = 0; i < disjVec.size(); ++i) {
            disjoint.push_back(disjVec[i]);
        }
        disjointDefined = disjoint.size() > 1;
        filterExcluded = excluded.size() > 0 || tautologyLimit >= 0;

        chainNames.reserve(namesVector.size() + 1);
        chainNames.push_back(""); // 0th index is unused, as R uses predicates' indices starting from 1
        for (R_xlen_t i = 0; i < namesVector.size(); ++i) {
            chainNames.push_back(as<string>(namesVector[i]));
        }
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

    bool hasAnyContiArgument() const
    { return anyContiArgument; }

    bool hasIndicesArgument() const
    { return indicesArgument; }

    bool hasSumArgument() const
    { return sumArgument; }

    bool hasSupportArgument() const
    { return supportArgument; }

    bool hasWeightsArgument() const
    { return weightsArgument; }

    bool hasDisjoint() const
    { return disjointDefined; }

    bool hasFilterEmptyFoci() const
    { return filterEmptyFoci; }

    bool hasFilterExcluded() const
    { return filterExcluded; }

    bool isVerbose() const
    { return verbose; }

    float getTautologyLimit() const
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

    float getMinSupport() const
    { return minSupport; }

    float getMinSum() const
    { return minSum; }

    float getMinFocusSupport() const
    { return minFocusSupport; }

    float getMinFocusSum() const
    { return minFocusSum; }

    float getMinConditionalFocusSupport() const
    { return minConditionalFocusSupport; }

    float getMaxSupport() const
    { return maxSupport; }

    float getMaxSum() const
    { return maxSum; }

    TNorm getTNorm() const
    { return tNorm; }

    const string& getChainName(size_t i) const
    { return chainNames[i]; }

private:
    int nrow;
    int threads;
    int minLength;
    int maxLength;
    int maxResults; // -1 means infinite
    float minSupport;
    float minSum;
    float minFocusSupport;
    float minFocusSum;
    float minConditionalFocusSupport;
    float maxSupport;
    float maxSum;
    float tautologyLimit;
    TNorm tNorm;
    List excluded;
    vector<int> disjoint;
    vector<string> chainNames;

    bool filterEmptyFoci;
    bool verbose;
    bool filterExcluded;
    bool disjointDefined;

    bool conditionArgument = false;
    bool fociSupportsArgument = false;
    bool contiPpArgument = false;
    bool contiNpArgument = false;
    bool contiPnArgument = false;
    bool contiNnArgument = false;
    bool anyContiArgument = false;
    bool indicesArgument = false;
    bool sumArgument = false;
    bool supportArgument = false;
    bool weightsArgument = false;

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

        anyContiArgument = contiPpArgument || contiNpArgument || contiPnArgument || contiNnArgument;
    }
};
