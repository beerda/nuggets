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

    void store(const CHAIN& chain, const ChainCollection<CHAIN>& collection)
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
};
