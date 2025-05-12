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

        try {
            //*
            RObject callbackResult = callback(args);
            result.push_back(callbackResult);
            /*/
            result.push_back(NumericVector());
            // */
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
};
