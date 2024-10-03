#pragma once

#include "../common.h"
#include "dig/Digger.h"
#include "dig/Config.h"
#include "dig/ConditionArgumentator.h"
#include "dig/FociSupportsArgumentator.h"
#include "dig/ContiPpArgumentator.h"
#include "dig/ContiNpArgumentator.h"
#include "dig/ContiPnArgumentator.h"
#include "dig/ContiNnArgumentator.h"
#include "dig/IndicesArgumentator.h"
#include "dig/SumArgumentator.h"
#include "dig/SupportArgumentator.h"
#include "dig/WeightsArgumentator.h"
#include "dig/MinLengthFilter.h"
#include "dig/MaxLengthFilter.h"
#include "dig/MinSupportFilter.h"
#include "dig/MinFocusSupportFilter.h"
#include "dig/DisjointFilter.h"
#include "dig/EmptyFociFilter.h"


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

        {
            LogStartEnd l("data init");
            data.addLogicalChains(logData);
            data.addNumericChains(numData);
            data.addLogicalFoci(logFoci);
            data.addNumericFoci(numFoci);
        }

        {
            LogStartEnd l("data sort");
            data.sortChains();
            config.permuteConditions(data.getChainsPermutation());
        }

        Digger<DataType> digger(data, config);

        if (config.hasConditionArgument()) {
            digger.addArgumentator(new ConditionArgumentator<TaskType>(config.getPredicateIndices(),
                                                                       config.getPredicateNames()));
        }
        if (config.hasFociSupportsArgument()) {
            digger.setPpFocusChainsNeeded();
            digger.addArgumentator(new FociSupportsArgumentator<TaskType>(config.getFociNames()));
        }
        if (config.hasContiPpArgument()) {
            digger.setPpFocusChainsNeeded();
            digger.addArgumentator(new ContiPpArgumentator<TaskType>(config.getFociNames()));
        }
        if (config.hasContiNpArgument()) {
            digger.setNpFocusChainsNeeded();
            digger.addArgumentator(new ContiNpArgumentator<TaskType>(config.getFociNames()));
        }
        if (config.hasContiPnArgument()) {
            digger.setPnFocusChainsNeeded();
            digger.addArgumentator(new ContiPnArgumentator<TaskType>(config.getFociNames()));
        }
        if (config.hasContiNnArgument()) {
            digger.setNnFocusChainsNeeded();
            digger.addArgumentator(new ContiNnArgumentator<TaskType>(config.getFociNames()));
        }
        if (config.hasSumArgument()) {
            digger.setPositiveConditionChainsNeeded();
            digger.addArgumentator(new SumArgumentator<TaskType>(data.nrow()));
        }
        if (config.hasSupportArgument()) {
            digger.setPositiveConditionChainsNeeded();
            digger.addArgumentator(new SupportArgumentator<TaskType>());
        }
        if (config.hasIndicesArgument()) {
            digger.setPositiveConditionChainsNeeded();
            digger.addArgumentator(new IndicesArgumentator<TaskType>(data.nrow()));
        }
        if (config.hasWeightsArgument()) {
            digger.setPositiveConditionChainsNeeded();
            digger.addArgumentator(new WeightsArgumentator<TaskType>(data.nrow()));
        }
        if (config.getMinLength() >= 0) {
            digger.addFilter(new MinLengthFilter<TaskType>(config.getMinLength()));
        }
        if (config.getMaxLength() >= 0) {
            digger.addFilter(new MaxLengthFilter<TaskType>(config.getMaxLength()));
        }
        if (config.getMinSupport() > 0) {
            digger.setPositiveConditionChainsNeeded();
            digger.addFilter(new MinSupportFilter<TaskType>(config.getMinSupport()));
        }

        if (config.getMinFocusSupport() > 0) {
            digger.setPpFocusChainsNeeded();
            digger.addFilter(new MinFocusSupportFilter<TaskType>(config.getMinFocusSupport()));
        }

        if (config.hasFilterEmptyFoci()) {
            digger.addFilter(new EmptyFociFilter<TaskType>());
        }

        digger.addFilter(new DisjointFilter<TaskType>(config.getPredicateIndices(),
                                                      config.getFociIndices(),
                                                      config.getDisjointPredicates(),
                                                      config.getDisjointFoci()));

        if (digger.isNegativeFociChainsNeeded()) {
            data.initializeNegativeFoci();
        }

        {
            LogStartEnd l("digger.run");
            digger.run();
        }

        {
            LogStartEnd l("collecting arguments");
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
        }

        return result;
    }

private:
    Config config;
};
