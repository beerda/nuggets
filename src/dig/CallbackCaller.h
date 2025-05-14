#pragma once

#include "../common.h"
#include "Config.h"
#include "ChainCollection.h"


template <typename CHAIN>
class CallbackCaller {
public:
    CallbackCaller(const Config& config, const Function& callback)
        : config(config),
          callback(callback),
          result()
    {
        result.reserve(1000);
    }

    // Disable copy
    CallbackCaller(const CallbackCaller&) = delete;
    CallbackCaller& operator=(const CallbackCaller&) = delete;

    // Allow move
    CallbackCaller(CallbackCaller&&) = default;
    CallbackCaller& operator=(CallbackCaller&&) = default;

    bool isFull() const
    { return result.size() >= config.getMaxResults(); }

    void store(const CHAIN& chain,
               const ChainCollection<CHAIN>& collection,
               const vector<float>& predicateSums)
    {
        if (isFull())
            return;

        List args;

        processConditionArgument(args, chain);
        processSumArgument(args, chain);
        processSupportArgument(args, chain);
        processIndicesArgument(args, chain);
        processWeightsArgument(args, chain);
        processFociSupportsArgument(args, chain, collection);
        processContiArguments(args, chain, collection, predicateSums);

        try {
            RObject callbackResult = callback(args);
            result.push_back(callbackResult);
        }
        catch (...) {
            throw runtime_error("Error in callback function");
        }
    }

    List getResult() const
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

    void processFociSupportsArgument(List& args, const CHAIN& chain, const ChainCollection<CHAIN>& collection)
    {
        if (config.hasFociSupportsArgument()) {
            NumericVector vals(collection.focusCount());
            CharacterVector valNames(collection.focusCount());
            for (size_t i = 0; i < collection.focusCount(); ++i) {
                const CHAIN& focus = collection[i + collection.firstFocusIndex()];
                size_t predicate = focus.getClause().back();
                vals[i] = focus.getSum() / config.getNrow();
                valNames[i] = config.getChainName(predicate);
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
                               const vector<float>& predicateSums)
    {
        if (config.hasAnyContiArgument()) {
            NumericVector* pp = nullptr;
            NumericVector* np = nullptr;
            NumericVector* pn = nullptr;
            NumericVector* nn = nullptr;

            if (config.hasContiPpArgument()) {
                pp = new NumericVector(collection.focusCount());
            }
            if (config.hasContiNpArgument()) {
                np = new NumericVector(collection.focusCount());
            }
            if (config.hasContiPnArgument()) {
                pn = new NumericVector(collection.focusCount());
            }
            if (config.hasContiNnArgument()) {
                nn = new NumericVector(collection.focusCount());
            }

            CharacterVector valNames(collection.focusCount());
            for (size_t i = 0; i < collection.focusCount(); ++i) {
                const CHAIN& focus = collection[i + collection.firstFocusIndex()];
                size_t predicate = focus.getClause().back();
                valNames[i] = config.getChainName(predicate);

                if (pp) {
                    (*pp)[i] = focus.getSum();
                }
                if (pn) {
                    (*pn)[i] = chain.getSum() - focus.getSum();
                }
                if (np) {
                    (*np)[i] = predicateSums[predicate] - focus.getSum();
                }
                if (nn) {
                    (*nn)[i] = config.getNrow() - chain.getSum() - predicateSums[predicate] + focus.getSum();
                }
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
