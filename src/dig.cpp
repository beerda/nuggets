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


// [[Rcpp::export(name="dig_")]]
List dig_(List logicals_data,
          List doubles_data,
          List logicals_foci,
          List doubles_foci,
          List configuration_list,
          Function fun)
{
    Data data;
    data.addChains<LogicalVector>(logicals_data);
    data.addChains<NumericVector>(doubles_data);
    data.addFoci<LogicalVector>(logicals_foci);
    data.addFoci<NumericVector>(doubles_foci);

    Config config(configuration_list);
    Digger digger(data, fun);

    if (config.hasConditionArgument()) {
        digger.addArgumentator(new ConditionArgumentator(config.getPredicates()));
    }
    if (config.hasFociSupportsArgument()) {
        digger.setChainsNeeded();
        digger.addArgumentator(new FociSupportsArgumentator(config.getPredicates(),
                                                            config.getFoci(),
                                                            config.getDisjointPredicates(),
                                                            config.getDisjointFoci(),
                                                            data));
    }
    if (config.hasSumArgument()) {
        digger.setChainsNeeded();
        digger.addArgumentator(new SumArgumentator(data.nrow()));
    }
    if (config.hasSupportArgument()) {
        digger.setChainsNeeded();
        digger.addArgumentator(new SupportArgumentator());
    }
    if (config.hasIndicesArgument()) {
        digger.setChainsNeeded();
        digger.addArgumentator(new IndicesArgumentator(data.nrow()));
    }
    if (config.hasWeightsArgument()) {
        digger.setChainsNeeded();
        digger.addArgumentator(new WeightsArgumentator(data.nrow()));
    }
    if (config.getMinLength() >= 0) {
        digger.addFilter(new MinLengthFilter(config.getMinLength()));
    }
    if (config.getMaxLength() >= 0) {
        digger.addFilter(new MaxLengthFilter(config.getMaxLength()));
    }
    if (config.getMinSupport() > 0) {
        digger.setChainsNeeded();
        digger.addFilter(new MinSupportFilter(config.getMinSupport()));
    }
    if (config.hasDisjointPredicates()) {
        digger.addFilter(new DisjointFilter(config.getDisjointPredicates()));
    }

    digger.run();

    return digger.getResult();
}
