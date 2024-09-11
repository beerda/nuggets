#pragma once

#include "../common.h"
#include "dig/Digger.h"
#include "dig/Config.h"
#include "dig/ConditionArgumentator.h"
#include "dig/FociSupportsArgumentator.h"
#include "dig/IndicesArgumentator.h"
#include "dig/SumArgumentator.h"
#include "dig/SupportArgumentator.h"
#include "dig/WeightsArgumentator.h"
#include "dig/MinLengthFilter.h"
#include "dig/MaxLengthFilter.h"
#include "dig/MinSupportFilter.h"
#include "dig/DisjointFilter.h"


template <typename BITCHAIN, typename NUMCHAIN>
class Executor {
public:
    using DataType = Data<BITCHAIN, NUMCHAIN>;
    using TaskType = Task<DataType>;

    Executor(const Config& config)
        : config(config)
    { }

    List execute(List logData, List numData, List logFoci, List numFoci)
    {
        List result;
        DataType data;
        data.addLogicalChains(logData);
        data.addNumericChains(numData);
        data.addLogicalFoci(logFoci);
        data.addNumericFoci(numFoci);

        Digger<DataType> digger(data, config);

        if (config.hasConditionArgument()) {
            digger.addArgumentator(new ConditionArgumentator<TaskType>(config.getPredicateIndices(),
                                                                       config.getPredicateNames()));
        }
        if (config.hasFociSupportsArgument()) {
            digger.setConditionChainsNeeded();
            digger.addArgumentator(new FociSupportsArgumentator<TaskType>(config.getPredicateIndices(),
                                                                          config.getFociIndices(),
                                                                          config.getFociNames(),
                                                                          config.getDisjointPredicates(),
                                                                          config.getDisjointFoci(),
                                                                          data));
        }
        if (config.hasSumArgument()) {
            digger.setConditionChainsNeeded();
            digger.addArgumentator(new SumArgumentator<TaskType>(data.nrow()));
        }
        if (config.hasSupportArgument()) {
            digger.setConditionChainsNeeded();
            digger.addArgumentator(new SupportArgumentator<TaskType>());
        }
        if (config.hasIndicesArgument()) {
            digger.setConditionChainsNeeded();
            digger.addArgumentator(new IndicesArgumentator<TaskType>(data.nrow()));
        }
        if (config.hasWeightsArgument()) {
            digger.setConditionChainsNeeded();
            digger.addArgumentator(new WeightsArgumentator<TaskType>(data.nrow()));
        }
        if (config.getMinLength() >= 0) {
            digger.addFilter(new MinLengthFilter<TaskType>(config.getMinLength()));
        }
        if (config.getMaxLength() >= 0) {
            digger.addFilter(new MaxLengthFilter<TaskType>(config.getMaxLength()));
        }
        if (config.getMinSupport() > 0) {
            digger.setConditionChainsNeeded();
            digger.addFilter(new MinSupportFilter<TaskType>(config.getMinSupport()));
        }
        if (config.hasDisjointPredicates()) {
            digger.addFilter(new DisjointFilter<TaskType>(config.getDisjointPredicates()));
        }

        digger.run();

        vector<ArgumentValues> diggerResult = digger.getResult();
        for (size_t i = 0; i < diggerResult.size(); ++i) {
            List item;
            for (size_t j = 0; j < diggerResult[i].size(); ++j) {
                ArgumentValue a = diggerResult[i][j];

                if (a.getType() == ArgumentType::ARG_LOGICAL) {
                    item.push_back(a.asLogicalVector(), a.getArgumentName());
                }
                else if (a.getType() == ArgumentType::ARG_INTEGER) {
                    item.push_back(a.asIntegerVector(), a.getArgumentName());
                }
                else if (a.getType() == ArgumentType::ARG_NUMERIC) {
                    item.push_back(a.asNumericVector(), a.getArgumentName());
                } else {
                    throw new runtime_error("Unhandled ArgumentType");
                }
            }
            result.push_back(item);
        }

        return result;
    }

private:
    Config config;
};
