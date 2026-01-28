/**********************************************************************
 * nuggets: An R framework for exploration of patterns in data
 * Copyright (C) 2025 Michal Burda
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program. If not, see <https://www.gnu.org/licenses/>.
 **********************************************************************/


#pragma once

#include "../common.h"
#include <vector>


class Config {
public:
    Config(const List& configuration, const CharacterVector& namesVector)
    {
        LogStartEnd log("Config::Config - load config");

        int nrow_i = as<IntegerVector>(configuration["nrow"])[0];
        if (nrow_i < 0)
            throw invalid_argument("nrow must be non-negative");
        else
            nrow = static_cast<size_t>(nrow_i);

        int threads_i = as<IntegerVector>(configuration["threads"])[0];
        if (threads_i < 0)
            throw invalid_argument("threads must be non-negative");
        else
            threads = static_cast<size_t>(threads_i);

        int minLength_i = as<IntegerVector>(configuration["minLength"])[0];
        if (minLength_i < 0)
            throw invalid_argument("minLength must be non-negative");
        else
            minLength = static_cast<size_t>(minLength_i);

        int maxLength_i = as<IntegerVector>(configuration["maxLength"])[0];
        if (maxLength_i < 0)
            maxLength = SIZE_MAX;
        else
            maxLength = static_cast<size_t>(maxLength_i);

        int maxResults_i = as<IntegerVector>(configuration["maxResults"])[0];
        if (maxResults_i < 0)
            maxResults = SIZE_MAX;
        else
            maxResults = static_cast<size_t>(maxResults_i);

        minSupport = as<NumericVector>(configuration["minSupport"])[0];
        if (minSupport < 0.0 || minSupport > 1.0)
            throw invalid_argument("minSupport must be in the range [0, 1]");

        minSum = minSupport * nrow;

        minFocusSupport = as<NumericVector>(configuration["minFocusSupport"])[0];
        if (minFocusSupport < 0.0 || minFocusSupport > 1.0)
            throw invalid_argument("minFocusSupport must be in the range [0, 1]");

        minFocusSum = minFocusSupport * nrow;

        minConditionalFocusSupport = as<NumericVector>(configuration["minConditionalFocusSupport"])[0];
        if (minConditionalFocusSupport < 0.0 || minConditionalFocusSupport > 1.0)
            throw invalid_argument("minConditionalFocusSupport must be in the range [0, 1]");

        maxSupport = as<NumericVector>(configuration["maxSupport"])[0];
        if (maxSupport < 0.0 || maxSupport > 1.0)
            throw invalid_argument("maxSupport must be in the range [0, 1]");

        maxSum = maxSupport * nrow;

        tNorm = parseTNorm(configuration["tNorm"]);

        excluded = as<List>(configuration["excluded"]);

        filterEmptyFoci = as<LogicalVector>(configuration["filterEmptyFoci"])[0];

        verbose = as<LogicalVector>(configuration["verbose"])[0];

        parseArguments(configuration["arguments"]);

        IntegerVector disjVec = configuration["disjoint"];
        disjoint.reserve(disjVec.size() + 1);
        disjoint.push_back(0); // 0th index is unused, as R uses predicates' indices starting from 1
        for (R_xlen_t i = 0; i < disjVec.size(); ++i) {
            disjoint.push_back(disjVec[i]);
        }
        disjointDefined = disjoint.size() > 1;
        filterExcluded = excluded.size() > 0;

        chainNames.reserve(namesVector.size() + 1);
        chainNames.push_back(""); // 0th index is unused, as R uses predicates' indices starting from 1
        for (R_xlen_t i = 0; i < namesVector.size(); ++i) {
            chainNames.push_back(as<string>(namesVector[i]));
        }
    }

    inline bool hasConditionArgument() const
    { return conditionArgument; }

    inline bool hasFociSupportsArgument() const
    { return fociSupportsArgument; }

    inline bool hasContiPpArgument() const
    { return contiPpArgument; }

    inline bool hasContiNpArgument() const
    { return contiNpArgument; }

    inline bool hasContiPnArgument() const
    { return contiPnArgument; }

    inline bool hasContiNnArgument() const
    { return contiNnArgument; }

    inline bool hasAnyContiArgument() const
    { return anyContiArgument; }

    inline bool hasIndicesArgument() const
    { return indicesArgument; }

    inline bool hasSumArgument() const
    { return sumArgument; }

    inline bool hasSupportArgument() const
    { return supportArgument; }

    inline bool hasWeightsArgument() const
    { return weightsArgument; }

    inline bool hasDisjoint() const
    { return disjointDefined; }

    inline bool hasFilterEmptyFoci() const
    { return filterEmptyFoci; }

    inline bool hasFilterExcluded() const
    { return filterExcluded; }

    inline bool isVerbose() const
    { return verbose; }

    inline const vector<int>& getDisjoint() const
    { return disjoint; }

    inline const List getExcluded() const
    { return excluded; }

    inline size_t getNrow() const
    { return nrow; }

    inline size_t getThreads() const
    { return threads; }

    inline size_t getMinLength() const
    { return minLength; }

    inline size_t getMaxLength() const
    { return maxLength; }

    inline size_t getMaxResults() const
    { return maxResults; }

    inline double getMinSupport() const
    { return minSupport; }

    inline double getMinSum() const
    { return minSum; }

    inline double getMinFocusSupport() const
    { return minFocusSupport; }

    inline double getMinFocusSum() const
    { return minFocusSum; }

    inline double getMinConditionalFocusSupport() const
    { return minConditionalFocusSupport; }

    inline double getMaxSupport() const
    { return maxSupport; }

    inline double getMaxSum() const
    { return maxSum; }

    inline TNorm getTNorm() const
    { return tNorm; }

    inline const string& getChainName(const size_t i) const
    { return chainNames[i]; }

private:
    size_t nrow;
    size_t threads;
    size_t minLength;
    size_t maxLength;
    size_t maxResults;
    double minSupport;
    double minSum;
    double minFocusSupport;
    double minFocusSum;
    double minConditionalFocusSupport;
    double maxSupport;
    double maxSum;
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

    static inline TNorm parseTNorm(const CharacterVector& vec)
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
