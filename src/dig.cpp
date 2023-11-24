#include <iostream>
#include "dig/Config.h"
#include "dig/Digger.h"
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


// [[Rcpp::export]]
List dig_(List logicals_data,
          List doubles_data,
          List logicals_foci,
          List doubles_foci,
          List configuration_list,
          Function fun)
{
    using DataType = Data<BitsetBitChain, VectorNumChain<GOGUEN>>;
    using TaskType = Task<DataType>;

    DataType data;
    data.addChains<LogicalVector>(logicals_data);
    data.addChains<NumericVector>(doubles_data);
    data.addFoci<LogicalVector>(logicals_foci);
    data.addFoci<NumericVector>(doubles_foci);

    Config config(configuration_list);
    Digger<DataType> digger(data, fun);

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
