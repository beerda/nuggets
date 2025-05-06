#pragma once

#include "../common.h"
#include "Config.h"
#include "ChainCollection.h"


template <typename CHAIN>
class CallbackCaller {
public:
    CallbackCaller(const Config& config, const Function& callback)
        : config(config),
          callback(callback)
    { }

    // Disable copy
    CallbackCaller(const CallbackCaller&) = delete;
    CallbackCaller& operator=(const CallbackCaller&) = delete;

    // Allow move
    CallbackCaller(CallbackCaller&&) = default;
    CallbackCaller& operator=(CallbackCaller&&) = default;

    void store(const CHAIN& chain, const ChainCollection<CHAIN>& collection)
    {
        if (result.size() < config.getMaxResults()) {
            List args;

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

            try {
                RObject callbackResult = callback(args);
                result.push_back(callbackResult);
            }
            catch (...) {
                throw runtime_error("Error in callback function");
            }
        }
    }

    List getResult() const
    { return result; }

private:
    const Config& config;
    const Function& callback;
    List result;
};
