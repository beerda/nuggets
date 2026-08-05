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
#include "../timer.h"
#include <vector>


/**
 * Stores and validates configuration passed from R to the digging algorithm.
 *
 * The class converts R vectors and lists to native values, derives support
 * sums from support thresholds, and records which optional result arguments
 * were requested.
 */
class Config {
public:
    /**
     * Constructs a configuration from R inputs.
     *
     * Validates numeric bounds, converts predicate indices to one-based
     * vectors, and maps chain names to their R predicate indices.
     *
     * @param configuration R list containing algorithm configuration values.
     * @param namesVector R character vector of predicate chain names.
     * @throws std::invalid_argument If a count is negative or a support is
     * outside the inclusive range [0, 1].
     */
    Config(const List& configuration, const CharacterVector& namesVector)
    {
        BLOCK_TIMER(bt, "Config::Config - load config");

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

    /**
     * Returns whether the "condition" result argument was requested.
     *
     * @return True if the argument was requested, otherwise false.
     */
    inline bool hasConditionArgument() const
    { return conditionArgument; }

    /**
     * Returns whether the "foci_supports" result argument was requested.
     *
     * @return True if the argument was requested, otherwise false.
     */
    inline bool hasFociSupportsArgument() const
    { return fociSupportsArgument; }

    /**
     * Returns whether the positive-positive contingency result was requested.
     *
     * @return True if the result was requested, otherwise false.
     */
    inline bool hasContiPpArgument() const
    { return contiPpArgument; }

    /**
     * Returns whether the negative-positive contingency result was requested.
     *
     * @return True if the result was requested, otherwise false.
     */
    inline bool hasContiNpArgument() const
    { return contiNpArgument; }

    /**
     * Returns whether the positive-negative contingency result was requested.
     *
     * @return True if the result was requested, otherwise false.
     */
    inline bool hasContiPnArgument() const
    { return contiPnArgument; }

    /**
     * Returns whether the negative-negative contingency result was requested.
     *
     * @return True if the result was requested, otherwise false.
     */
    inline bool hasContiNnArgument() const
    { return contiNnArgument; }

    /**
     * Returns whether any contingency-table result was requested.
     *
     * @return True if at least one contingency result was requested,
     * otherwise false.
     */
    inline bool hasAnyContiArgument() const
    { return anyContiArgument; }

    /**
     * Returns whether predicate indices should be included in results.
     *
     * @return True if indices should be included, otherwise false.
     */
    inline bool hasIndicesArgument() const
    { return indicesArgument; }

    /**
     * Returns whether support sums should be included in results.
     *
     * @return True if support sums should be included, otherwise false.
     */
    inline bool hasSumArgument() const
    { return sumArgument; }

    /**
     * Returns whether support values should be included in results.
     *
     * @return True if support values should be included, otherwise false.
     */
    inline bool hasSupportArgument() const
    { return supportArgument; }

    /**
     * Returns whether predicate weights should be included in results.
     *
     * @return True if weights should be included, otherwise false.
     */
    inline bool hasWeightsArgument() const
    { return weightsArgument; }

    /**
     * Returns whether disjoint predicate constraints were supplied.
     *
     * @return True if constraints were supplied, otherwise false.
     */
    inline bool hasDisjoint() const
    { return disjointDefined; }

    /**
     * Returns whether patterns with empty foci should be filtered out.
     *
     * @return True if empty foci should be filtered, otherwise false.
     */
    inline bool hasFilterEmptyFoci() const
    { return filterEmptyFoci; }

    /**
     * Returns whether excluded patterns should be filtered out.
     *
     * @return True if excluded patterns should be filtered, otherwise false.
     */
    inline bool hasFilterExcluded() const
    { return filterExcluded; }

    /**
     * Returns whether verbose algorithm output is enabled.
     *
     * @return True if verbose output is enabled, otherwise false.
     */
    inline bool isVerbose() const
    { return verbose; }

    /**
     * Returns one-based disjoint-set identifiers for predicates.
     *
     * Element zero is unused so that vector positions match R predicate
     * indices.
     *
     * @return One-based predicate-to-disjoint-set identifier mapping.
     */
    inline const vector<int>& getDisjoint() const
    { return disjoint; }

    /**
     * Returns R descriptions of patterns excluded from the result.
     *
     * @return R list of excluded pattern descriptions.
     */
    inline const List getExcluded() const
    { return excluded; }

    /**
     * Returns the number of input data rows.
     *
     * @return Input data row count.
     */
    inline size_t getNrow() const
    { return nrow; }

    /**
     * Returns the requested number of worker threads.
     *
     * @return Requested worker thread count.
     */
    inline size_t getThreads() const
    { return threads; }

    /**
     * Returns the minimum number of predicates in a pattern.
     *
     * @return Minimum pattern length.
     */
    inline size_t getMinLength() const
    { return minLength; }

    /**
     * Returns the maximum number of predicates in a pattern.
     *
     * @return Maximum pattern length.
     */
    inline size_t getMaxLength() const
    { return maxLength; }

    /**
     * Returns the maximum number of patterns to return.
     *
     * @return Maximum result count.
     */
    inline size_t getMaxResults() const
    { return maxResults; }

    /**
     * Returns the minimum allowed support proportion.
     *
     * @return Minimum support proportion.
     */
    inline double getMinSupport() const
    { return minSupport; }

    /**
     * Returns the minimum support sum derived from the row count.
     *
     * @return Minimum support sum.
     */
    inline double getMinSum() const
    { return minSum; }

    /**
     * Returns the minimum allowed focus support proportion.
     *
     * @return Minimum focus support proportion.
     */
    inline double getMinFocusSupport() const
    { return minFocusSupport; }

    /**
     * Returns the minimum focus support sum derived from the row count.
     *
     * @return Minimum focus support sum.
     */
    inline double getMinFocusSum() const
    { return minFocusSum; }

    /**
     * Returns the minimum allowed support conditional on the focus.
     *
     * @return Minimum conditional focus support proportion.
     */
    inline double getMinConditionalFocusSupport() const
    { return minConditionalFocusSupport; }

    /**
     * Returns the maximum allowed support proportion.
     *
     * @return Maximum support proportion.
     */
    inline double getMaxSupport() const
    { return maxSupport; }

    /**
     * Returns the maximum support sum derived from the row count.
     *
     * @return Maximum support sum.
     */
    inline double getMaxSum() const
    { return maxSum; }

    /**
     * Returns the configured fuzzy t-norm.
     *
     * @return Configured t-norm enumeration value.
     */
    inline TNorm getTNorm() const
    { return tNorm; }

    /**
     * Returns the name of a predicate chain by its one-based R index.
     *
     * @param i One-based predicate chain index.
     * @return Predicate chain name at index `i`.
     */
    inline const string& getChainName(const size_t i) const
    { return chainNames[i]; }

private:
    /**
     * Number of rows in the input data.
     */
    size_t nrow;
    /**
     * Number of worker threads requested for the algorithm.
     */
    size_t threads;
    /**
     * Minimum number of predicates allowed in a pattern.
     */
    size_t minLength;
    /**
     * Maximum number of predicates allowed in a pattern, or SIZE_MAX.
     */
    size_t maxLength;
    /**
     * Maximum number of patterns to return, or SIZE_MAX.
     */
    size_t maxResults;
    /**
     * Minimum allowed support proportion.
     */
    double minSupport;
    /**
     * Minimum support sum, computed as minSupport multiplied by nrow.
     */
    double minSum;
    /**
     * Minimum allowed focus support proportion.
     */
    double minFocusSupport;
    /**
     * Minimum focus support sum, computed as minFocusSupport multiplied by nrow.
     */
    double minFocusSum;
    /**
     * Minimum allowed support proportion conditional on the focus.
     */
    double minConditionalFocusSupport;
    /**
     * Maximum allowed support proportion.
     */
    double maxSupport;
    /**
     * Maximum support sum, computed as maxSupport multiplied by nrow.
     */
    double maxSum;
    /**
     * T-norm used to combine fuzzy predicate memberships.
     */
    TNorm tNorm;
    /**
     * R descriptions of patterns to exclude.
     */
    List excluded;
    /**
     * One-based mapping from predicate indices to disjoint-set identifiers.
     */
    vector<int> disjoint;
    /**
     * One-based mapping from predicate indices to chain names.
     */
    vector<string> chainNames;

    /**
     * Whether patterns with empty foci should be removed.
     */
    bool filterEmptyFoci;
    /**
     * Whether verbose algorithm output is enabled.
     */
    bool verbose;
    /**
     * Whether one or more excluded patterns were supplied.
     */
    bool filterExcluded;
    /**
     * Whether one or more disjoint-set constraints were supplied.
     */
    bool disjointDefined;

    /**
     * Whether the "condition" result argument was requested.
     */
    bool conditionArgument = false;
    /**
     * Whether the "foci_supports" result argument was requested.
     */
    bool fociSupportsArgument = false;
    /**
     * Whether the positive-positive contingency result was requested.
     */
    bool contiPpArgument = false;
    /**
     * Whether the negative-positive contingency result was requested.
     */
    bool contiNpArgument = false;
    /**
     * Whether the positive-negative contingency result was requested.
     */
    bool contiPnArgument = false;
    /**
     * Whether the negative-negative contingency result was requested.
     */
    bool contiNnArgument = false;
    /**
     * Whether any contingency-table result was requested.
     */
    bool anyContiArgument = false;
    /**
     * Whether predicate indices should be included in results.
     */
    bool indicesArgument = false;
    /**
     * Whether support sums should be included in results.
     */
    bool sumArgument = false;
    /**
     * Whether support values should be included in results.
     */
    bool supportArgument = false;
    /**
     * Whether predicate weights should be included in results.
     */
    bool weightsArgument = false;

    /**
     * Converts an R t-norm name to its native enumeration value.
     *
     * "goguen" and "lukas" select their corresponding t-norms; all other
     * values select the Goedel t-norm.
     *
     * @param vec R character vector containing the t-norm name.
     * @return Corresponding t-norm enumeration value.
     */
    static inline TNorm parseTNorm(const CharacterVector& vec)
    {
        if (vec[0] == "goguen")
            return TNorm::GOGUEN;
        else if (vec[0] == "lukas")
            return TNorm::LUKASIEWICZ;
        else
            return TNorm::GOEDEL;
    }

    /**
     * Records which optional result arguments were requested from R.
     *
     * @param vec R character vector of requested argument names.
     */
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
