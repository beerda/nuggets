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
#include "Config.h"
#include "ChainCollection.h"
#include "Selector.h"


template <typename CHAIN>
class CallbackCaller {
    static constexpr size_t INITIAL_RESULT_CAPACITY = 1024;
    static constexpr size_t INITIAL_ARGUMENTS_CAPACITY = 10;

public:
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

    void store(const CHAIN& chain,
               const ChainCollection<CHAIN>& collection,
               const Selector& selector,
               const vector<double>& predicateSums)
    {
        vector<RObject> args;
        args.reserve(INITIAL_ARGUMENTS_CAPACITY);

        vector<string> argNames;
        argNames.reserve(INITIAL_ARGUMENTS_CAPACITY);

        processConditionArgument(args, argNames, chain);
        processSumArgument(args, argNames, chain);
        processSupportArgument(args, argNames, chain);
        processIndicesArgument(args, argNames, chain);
        processWeightsArgument(args, argNames, chain);
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

    inline size_t size() const
    { return result.size(); }

    inline List getResult() const
    { return wrap(result); }

private:
    const Config& config;
    const Function& callback;
    vector<RObject> result;

    inline void processConditionArgument(vector<RObject>& args, vector<string>& argNames, const CHAIN& chain)
    {
        if (config.hasConditionArgument()) {
            IntegerVector vals(chain.getClause().size());
            CharacterVector valNames(chain.getClause().size());
            for (size_t i = 0; i < chain.getClause().size(); ++i) {
                size_t predicate = chain.getClause()[i];
                vals[i] = predicate;
                valNames[i] = config.getChainName(predicate);
            }
            if (vals.size() > 0) {
                vals.names() = valNames;
            }
            args.push_back(vals);
            argNames.push_back("condition");
        }
    }

    inline void processSumArgument(vector<RObject>& args, vector<string>& argNames, const CHAIN& chain)
    {
        if (config.hasSumArgument()) {
            NumericVector vals({ chain.getSum() });
            args.push_back(vals);
            argNames.push_back("sum");
        }
    }

    inline void processSupportArgument(vector<RObject>& args, vector<string>& argNames, const CHAIN& chain)
    {
        if (config.hasSupportArgument()) {
            NumericVector vals({ chain.getSum() / config.getNrow() });
            args.push_back(vals);
            argNames.push_back("support");
        }
    }

    inline void processIndicesArgument(vector<RObject>& args, vector<string>& argNames, const CHAIN& chain)
    {
        if (config.hasIndicesArgument()) {
            if (chain.getClause().empty()) {
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

    inline void processWeightsArgument(vector<RObject>& args, vector<string>& argNames, const CHAIN& chain)
    {
        if (config.hasWeightsArgument()) {
            if (chain.getClause().empty()) {
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
                size_t predicate = focus.getClause().back();
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

    inline void processContiArguments(vector<RObject>& args,
                                      vector<string>& argNames,
                                      const CHAIN& chain,
                                      const ChainCollection<CHAIN>& collection,
                                      const Selector& selector,
                                      const vector<double>& predicateSums)
    {
        if (config.hasAnyContiArgument()) {
            CharacterVector valNames(selector.getSelectedCount());
            const size_t selectedCount = selector.getSelectedCount();
            
            // Use stack allocation instead of heap allocation
            std::vector<NumericVector> vectors;
            std::vector<string> names;
            
            if (config.hasContiPpArgument()) {
                vectors.emplace_back(selectedCount);
                names.push_back("pp");
            }
            if (config.hasContiNpArgument()) {
                vectors.emplace_back(selectedCount);
                names.push_back("np");
            }
            if (config.hasContiPnArgument()) {
                vectors.emplace_back(selectedCount);
                names.push_back("pn");
            }
            if (config.hasContiNnArgument()) {
                vectors.emplace_back(selectedCount);
                names.push_back("nn");
            }

            size_t j = 0;
            for (size_t i = 0; i < collection.focusCount(); ++i) {
                if (!selector.isSelected(i))
                    continue;

                const CHAIN& focus = collection[i + collection.firstFocusIndex()];
                size_t predicate = focus.getClause().back();
                valNames[j] = config.getChainName(predicate);

                size_t vecIdx = 0;
                if (config.hasContiPpArgument()) {
                    vectors[vecIdx][j] = focus.getSum();
                    vecIdx++;
                }
                if (config.hasContiNpArgument()) {
                    vectors[vecIdx][j] = predicateSums[predicate] - focus.getSum();
                    vecIdx++;
                }
                if (config.hasContiPnArgument()) {
                    vectors[vecIdx][j] = chain.getSum() - focus.getSum();
                    vecIdx++;
                }
                if (config.hasContiNnArgument()) {
                    vectors[vecIdx][j] = config.getNrow() - chain.getSum() - predicateSums[predicate] + focus.getSum();
                    vecIdx++;
                }

                j++;
            }

            // Add vectors to args
            for (size_t k = 0; k < vectors.size(); ++k) {
                if (vectors[k].size() > 0) {
                    vectors[k].names() = valNames;
                }
                args.push_back(vectors[k]);
                argNames.push_back(names[k]);
            }
        }
    }
};
