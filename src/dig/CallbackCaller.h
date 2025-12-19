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
public:
    CallbackCaller(const Config& config, const Function& callback)
        : config(config),
          callback(callback),
          result()
    { result.reserve(1000); }

    // Disable copy
    CallbackCaller(const CallbackCaller&) = delete;
    CallbackCaller& operator=(const CallbackCaller&) = delete;

    // Allow move
    CallbackCaller(CallbackCaller&&) = default;
    CallbackCaller& operator=(CallbackCaller&&) = default;

    void store(const CHAIN& chain,
               const ChainCollection<CHAIN>& collection,
               const Selector& selector,
               const vector<float>& predicateSums)
    {
        List args;

        processConditionArgument(args, chain);
        processSumArgument(args, chain);
        processSupportArgument(args, chain);
        processIndicesArgument(args, chain);
        processWeightsArgument(args, chain);
        processFociSupportsArgument(args, chain, collection, selector);
        processContiArguments(args, chain, collection, selector, predicateSums);

        try {
            RObject callbackResult = callback(args);
            result.push_back(callbackResult);
        }
        catch (...) {
            throw runtime_error("Error in callback function");
        }
    }

    inline size_t size() const
    { return result.size(); }

    inline List getResult() const
    {
        // Rcpp:List is tragically slow if the size is not known in advance
        List res(result.size());
        for (size_t i = 0; i < result.size(); ++i) {
            res[i] = result[i];
        }

        return res;
    }

private:
    const Config& config;
    const Function& callback;
    vector<RObject> result;

    void processConditionArgument(List& args, const CHAIN& chain)
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
            args.push_back(vals, "condition");
        }
    }

    void processSumArgument(List& args, const CHAIN& chain)
    {
        if (config.hasSumArgument()) {
            NumericVector vals({ chain.getSum() });
            args.push_back(vals, "sum");
        }
    }

    void processSupportArgument(List& args, const CHAIN& chain)
    {
        if (config.hasSupportArgument()) {
            NumericVector vals({ chain.getSum() / config.getNrow() });
            args.push_back(vals, "support");
        }
    }

    void processIndicesArgument(List& args, const CHAIN& chain)
    {
        if (config.hasIndicesArgument()) {
            if (chain.getClause().empty()) {
                LogicalVector vals(config.getNrow(), true);
                args.push_back(vals, "indices");
            }
            else {
                LogicalVector vals(config.getNrow());
                for (size_t i = 0; i < chain.size(); ++i) {
                    vals[i] = chain[i] > 0;
                }
                args.push_back(vals, "indices");
            }
        }
    }

    void processWeightsArgument(List& args, const CHAIN& chain)
    {
        if (config.hasWeightsArgument()) {
            if (chain.getClause().empty()) {
                NumericVector vals(config.getNrow(), 1.0);
                args.push_back(vals, "weights");
            }
            else {
                NumericVector vals(config.getNrow());
                for (size_t i = 0; i < chain.size(); ++i) {
                    vals[i] = static_cast<float>(chain[i]);
                }
                args.push_back(vals, "weights");
            }
        }
    }

    void processFociSupportsArgument(List& args,
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
            args.push_back(vals, "foci_supports");
        }
    }

    void processContiArguments(List& args,
                               const CHAIN& chain,
                               const ChainCollection<CHAIN>& collection,
                               const Selector& selector,
                               const vector<float>& predicateSums)
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
                size_t predicate = focus.getClause().back();
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
                args.push_back(*pp, "pp");
                delete pp;
            }
            if (np) {
                if (np->size() > 0) {
                    np->names() = valNames;
                }
                args.push_back(*np, "np");
                delete np;
            }
            if (pn) {
                if (pn->size() > 0) {
                    pn->names() = valNames;
                }
                args.push_back(*pn, "pn");
                delete pn;
            }
            if (nn) {
                if (nn->size() > 0) {
                    nn->names() = valNames;
                }
                args.push_back(*nn, "nn");
                delete nn;
            }
        }
    }
};
