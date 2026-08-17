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
#include "Clause.h"
#include "Config.h"
#include "ChainCollection.h"
#include "Selector.h"


/**
 * A class applicable for STORAGE template parameter of Digger.
 * It takes a chain type (CHAIN) as a template parameter. The CHAIN type must be
 * a descendant of the BaseChain class. The CallbackCaller class is responsible
 * for preparing the arguments for the callback function based on the discovered
 * chain and its associated data, and then calling the callback function with
 * those arguments. The results of the callback function calls are stored in a
 * vector and can be retrieved as an R List.
 */
template <typename CHAIN>
class CallbackCaller {
    /**
     * The initial capacity of the result vector. It is used to reserve memory for
     * the result vector to avoid frequent reallocations during the search process.
     */
    static constexpr size_t INITIAL_RESULT_CAPACITY = 65536;

    /**
     * The initial capacity of the arguments vector. It is used to reserve memory for
     * the arguments vector to avoid frequent reallocations during the search process.
     */
    static constexpr size_t INITIAL_ARGUMENTS_CAPACITY = 10;

public:
    /**
     * Constructs a new CallbackCaller instance with the given configuration and
     * callback function.
     *
     * @param config The configuration object containing search parameters.
     * @param callback The Rcpp::Function object representing the callback function
     *     to be called for each discovered chain.
     */
    CallbackCaller(const Config& config, const Function& callback)
        : config(config),
          callback(callback),
          result()
    { result.reserve(INITIAL_RESULT_CAPACITY); }

    // Disable copy
    CallbackCaller(const CallbackCaller&) = delete;
    CallbackCaller& operator=(const CallbackCaller&) = delete;

    // Allow move
    CallbackCaller(CallbackCaller&&) = default;
    CallbackCaller& operator=(CallbackCaller&&) = default;

    /**
     * For a given condition chain and collection of focus chains, prepares the
     * arguments for the callback function based on the discovered chain and its
     * associated data, and then calls the callback function with those arguments.
     * The results of the callback function calls are stored in a vector of
     * results.
     *
     * @param chain The condition chain representing the antecedent of the rule.
     * @param collection The collection of focus chains representing the consequents
     *     of the rules.
     * @param selector The Selector object used to filter the focus chains based on
     *     user-defined criteria.
     * @param predicateSums A vector containing the sums of TRUEs or membership
     *     degrees for each predicate in the data. The index of the vector corresponds
     *     to the predicate ID, and the value at that index represents the sum of
     *     TRUEs or membership degrees for that predicate.
     */
    void store(const Clause& prefix,
               const CHAIN& chain,
               const ChainCollection<CHAIN>& collection,
               const Selector& selector,
               const vector<double>& predicateSums)
    {
        vector<RObject> args;
        args.reserve(INITIAL_ARGUMENTS_CAPACITY);

        vector<string> argNames;
        argNames.reserve(INITIAL_ARGUMENTS_CAPACITY);

        processConditionArgument(args, argNames, prefix, chain);
        processSumArgument(args, argNames, chain);
        processSupportArgument(args, argNames, chain);
        processIndicesArgument(args, argNames, prefix, chain);
        processWeightsArgument(args, argNames, prefix, chain);
        processFociSupportsArgument(args, argNames, chain, collection, selector);
        processContiArguments(args, argNames, chain, collection, selector, predicateSums);

        List argList = wrap(args);
        argList.names() = wrap(argNames);

        try {
            RObject callbackResult = callback(argList);
            result.push_back(callbackResult);
        }
        catch (...) {
            throw runtime_error("Error in callback function");
        }
    }

    /**
     * Returns the number of stored results from the callback function calls.
     *
     * @return The number of stored results.
     */
    inline size_t size() const
    { return result.size(); }

    /**
     * Returns the final results of the callback function calls as an R List.
     *
     * @return A List containing the results of the callback function calls.
     */
    inline List getResult() const
    { return wrap(result); }

private:
    /**
     * The configuration object containing search parameters.
     */
    const Config& config;

    /**
     * The Rcpp::Function object representing the callback function to be called
     * for each discovered chain.
     */
    const Function& callback;

    /**
     * A vector that stores the results of the callback function calls. Each element
     * in the vector corresponds to the result of a single callback function call
     * for a discovered chain.
     */
    vector<RObject> result;

    /**
     * Processes the condition argument for the callback function based on the
     * discovered chain. If the configuration specifies that the condition argument
     * should be included, this method creates a NumericVector containing the
     * predicate IDs of the condition chain and adds it to the arguments vector.
     *
     * @param args A reference to the vector of arguments for the callback function.
     * @param argNames A reference to the vector of argument names for the callback function.
     * @param chain The condition chain representing the antecedent of the rule.
     */
    inline void processConditionArgument(vector<RObject>& args,
                                         vector<string>& argNames,
                                         const Clause& prefix,
                                         const CHAIN& chain)
    {
        if (config.hasConditionArgument()) {
            IntegerVector vals(prefix.size() + chain.hasPredicate());
            CharacterVector valNames(prefix.size() + chain.hasPredicate());
            for (size_t i = 0; i < prefix.size(); ++i) {
                size_t predicate = prefix[i];
                vals[i] = predicate;
                valNames[i] = config.getChainName(predicate);
            }
            if (chain.hasPredicate()) {
                size_t predicate = chain.getPredicate();
                vals[prefix.size()] = predicate;
                valNames[prefix.size()] = config.getChainName(predicate);
            }
            if (vals.size() > 0) {
                vals.names() = valNames;
            }
            args.push_back(vals);
            argNames.push_back("condition");
        }
    }

    /**
     * Processes the sum argument for the callback function based on the
     * discovered chain. If the configuration specifies that the sum argument
     * should be included, this method creates a NumericVector containing the
     * sum of TRUEs or membership degrees for the condition chain and adds it to
     * the arguments vector.
     *
     * @param args A reference to the vector of arguments for the callback function.
     * @param argNames A reference to the vector of argument names for the callback function.
     * @param chain The condition chain representing the antecedent of the rule.
     */
    inline void processSumArgument(vector<RObject>& args,
                                   vector<string>& argNames,
                                   const CHAIN& chain)
    {
        if (config.hasSumArgument()) {
            NumericVector vals({ chain.getSum() });
            args.push_back(vals);
            argNames.push_back("sum");
        }
    }

    /**
     * Processes the support argument for the callback function based on the
     * discovered chain. If the configuration specifies that the support argument
     * should be included, this method creates a NumericVector containing the
     * support value (sum divided by total number of rows) for the condition chain
     * and adds it to the arguments vector.
     *
     * @param args A reference to the vector of arguments for the callback function.
     * @param argNames A reference to the vector of argument names for the callback function.
     * @param chain The condition chain representing the antecedent of the rule.
     */
    inline void processSupportArgument(vector<RObject>& args,
                                       vector<string>& argNames,
                                       const CHAIN& chain)
    {
        if (config.hasSupportArgument()) {
            NumericVector vals({ chain.getSum() / config.getNrow() });
            args.push_back(vals);
            argNames.push_back("support");
        }
    }

    /**
     * Processes the indices argument for the callback function based on the
     * discovered chain. If the configuration specifies that the indices argument
     * should be included, this method creates a LogicalVector indicating which
     * rows are included in the condition chain and adds it to the arguments vector.
     *
     * @param args A reference to the vector of arguments for the callback function.
     * @param argNames A reference to the vector of argument names for the callback function.
     * @param chain The condition chain representing the antecedent of the rule.
     */
    inline void processIndicesArgument(vector<RObject>& args,
                                       vector<string>& argNames,
                                       const Clause& prefix,
                                       const CHAIN& chain)
    {
        if (config.hasIndicesArgument()) {
            if (prefix.empty() && !chain.hasPredicate()) {
                LogicalVector vals(config.getNrow(), true);
                args.push_back(vals);
                argNames.push_back("indices");
            }
            else {
                LogicalVector vals(config.getNrow());
                for (size_t i = 0; i < chain.size(); ++i) {
                    vals[i] = chain[i] > 0;
                }
                args.push_back(vals);
                argNames.push_back("indices");
            }
        }
    }

    /**
     * Processes the weights argument for the callback function based on the
     * discovered chain. If the configuration specifies that the weights argument
     * should be included, this method creates a NumericVector containing the
     * weights (membership degrees) for each row in the condition chain and adds it
     * to the arguments vector.
     *
     * @param args A reference to the vector of arguments for the callback function.
     * @param argNames A reference to the vector of argument names for the callback function.
     * @param chain The condition chain representing the antecedent of the rule.
     */
    inline void processWeightsArgument(vector<RObject>& args,
                                       vector<string>& argNames,
                                       const Clause& prefix,
                                       const CHAIN& chain)
    {
        if (config.hasWeightsArgument()) {
            if (prefix.empty() && !chain.hasPredicate()) {
                NumericVector vals(config.getNrow(), 1.0);
                args.push_back(vals);
                argNames.push_back("weights");
            }
            else {
                NumericVector vals(config.getNrow());
                for (size_t i = 0; i < chain.size(); ++i) {
                    vals[i] = static_cast<double>(chain[i]);
                }
                args.push_back(vals);
                argNames.push_back("weights");
            }
        }
    }

    /**
     * Processes the foci supports argument for the callback function based on the
     * discovered chain and the collection of focus chains. If the configuration
     * specifies that the foci supports argument should be included, this method
     * creates a NumericVector containing the support values (sum divided by total
     * number of rows) for each selected focus chain and adds it to the arguments
     * vector.
     *
     * @param args A reference to the vector of arguments for the callback function.
     * @param argNames A reference to the vector of argument names for the callback function.
     * @param chain The condition chain representing the antecedent of the rule.
     * @param collection The collection of focus chains representing the consequents
     *     of the rules.
     * @param selector The Selector object used to filter the focus chains based on
     *     user-defined criteria.
     */
    inline void processFociSupportsArgument(vector<RObject>& args,
                                            vector<string>& argNames,
                                            const CHAIN& chain,
                                            const ChainCollection<CHAIN>& collection,
                                            const Selector& selector)
    {
        if (config.hasFociSupportsArgument()) {
            NumericVector vals(selector.getSelectedCount());
            CharacterVector valNames(selector.getSelectedCount());

            size_t j = 0;
            for (size_t i = 0; i < collection.focusCount(); ++i) {
                if (!selector.isSelected(i))
                    continue;

                const CHAIN& focus = collection[i + collection.firstFocusIndex()];
                size_t predicate = focus.getPredicate();
                vals[j] = focus.getSum() / config.getNrow();
                valNames[j] = config.getChainName(predicate);
                j++;
            }
            if (vals.size() > 0) {
                vals.names() = valNames;
            }
            args.push_back(vals);
            argNames.push_back("foci_supports");
        }
    }

    /**
     * Processes the contingency table arguments (pp, np, pn, nn) for the callback
     * function based on the discovered chain and the collection of focus chains.
     * If the configuration specifies that any of the contingency table arguments
     * should be included, this method creates NumericVectors for each selected
     * focus chain and adds them to the arguments vector.
     *
     * @param args A reference to the vector of arguments for the callback function.
     * @param argNames A reference to the vector of argument names for the callback function.
     * @param chain The condition chain representing the antecedent of the rule.
     * @param collection The collection of focus chains representing the consequents
     *     of the rules.
     * @param selector The Selector object used to filter the focus chains based on
     *     user-defined criteria.
     * @param predicateSums A vector containing the sums of TRUEs or membership
     *     degrees for each predicate in the data. The index of the vector corresponds
     *     to the predicate ID, and the value at that index represents the sum of
     *     TRUEs or membership degrees for that predicate.
     */
    inline void processContiArguments(vector<RObject>& args,
                                      vector<string>& argNames,
                                      const CHAIN& chain,
                                      const ChainCollection<CHAIN>& collection,
                                      const Selector& selector,
                                      const vector<double>& predicateSums)
    {
        if (config.hasAnyContiArgument()) {
            NumericVector* pp = nullptr;
            NumericVector* np = nullptr;
            NumericVector* pn = nullptr;
            NumericVector* nn = nullptr;
            CharacterVector valNames(selector.getSelectedCount());

            if (config.hasContiPpArgument()) {
                pp = new NumericVector(selector.getSelectedCount());
            }
            if (config.hasContiNpArgument()) {
                np = new NumericVector(selector.getSelectedCount());
            }
            if (config.hasContiPnArgument()) {
                pn = new NumericVector(selector.getSelectedCount());
            }
            if (config.hasContiNnArgument()) {
                nn = new NumericVector(selector.getSelectedCount());
            }

            size_t j = 0;
            for (size_t i = 0; i < collection.focusCount(); ++i) {
                if (!selector.isSelected(i))
                    continue;

                const CHAIN& focus = collection[i + collection.firstFocusIndex()];
                size_t predicate = focus.getPredicate();
                valNames[j] = config.getChainName(predicate);

                if (pp) {
                    (*pp)[j] = focus.getSum();
                }
                if (pn) {
                    (*pn)[j] = chain.getSum() - focus.getSum();
                }
                if (np) {
                    (*np)[j] = predicateSums[predicate] - focus.getSum();
                }
                if (nn) {
                    (*nn)[j] = config.getNrow() - chain.getSum() - predicateSums[predicate] + focus.getSum();
                }

                j++;
            }

            if (pp) {
                if (pp->size() > 0) {
                    pp->names() = valNames;
                }
                args.push_back(*pp);
                argNames.push_back("pp");
                delete pp;
            }
            if (np) {
                if (np->size() > 0) {
                    np->names() = valNames;
                }
                args.push_back(*np);
                argNames.push_back("np");
                delete np;
            }
            if (pn) {
                if (pn->size() > 0) {
                    pn->names() = valNames;
                }
                args.push_back(*pn);
                argNames.push_back("pn");
                delete pn;
            }
            if (nn) {
                if (nn->size() > 0) {
                    nn->names() = valNames;
                }
                args.push_back(*nn);
                argNames.push_back("nn");
                delete nn;
            }
        }
    }
};
