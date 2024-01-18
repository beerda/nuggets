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
        DataType data;
        data.addLogicalChains(logData);
        data.addNumericChains(numData);
        data.addLogicalFoci(logFoci);
        data.addNumericFoci(numFoci);

        Digger<DataType> digger(data);

        if (config.hasConditionArgument()) {
            digger.addArgumentator(new ConditionArgumentator<TaskType>(config.getPredicates()));
        }
        if (config.hasFociSupportsArgument()) {
            digger.setChainsNeeded();
            digger.addArgumentator(new FociSupportsArgumentator<TaskType>(config.getPredicates(),
                                                                config.getFoci(),
                                                                config.getDisjointPredicates(),
                                                                config.getDisjointFoci(),
                                                                data));
        }
        if (config.hasSumArgument()) {
            digger.setChainsNeeded();
            digger.addArgumentator(new SumArgumentator<TaskType>(data.nrow()));
        }
        if (config.hasSupportArgument()) {
            digger.setChainsNeeded();
            digger.addArgumentator(new SupportArgumentator<TaskType>());
        }
        if (config.hasIndicesArgument()) {
            digger.setChainsNeeded();
            digger.addArgumentator(new IndicesArgumentator<TaskType>(data.nrow()));
        }
        if (config.hasWeightsArgument()) {
            digger.setChainsNeeded();
            digger.addArgumentator(new WeightsArgumentator<TaskType>(data.nrow()));
        }
        if (config.getMinLength() >= 0) {
            digger.addFilter(new MinLengthFilter<TaskType>(config.getMinLength()));
        }
        if (config.getMaxLength() >= 0) {
            digger.addFilter(new MaxLengthFilter<TaskType>(config.getMaxLength()));
        }
        if (config.getMinSupport() > 0) {
            digger.setChainsNeeded();
            digger.addFilter(new MinSupportFilter<TaskType>(config.getMinSupport()));
        }
        if (config.hasDisjointPredicates()) {
            digger.addFilter(new DisjointFilter<TaskType>(config.getDisjointPredicates()));
        }

        digger.run();

        return digger.getResult();
    }

private:
    Config config;
};
