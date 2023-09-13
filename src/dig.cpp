#include <iostream>
#include "Config.h"
#include "Digger.h"
#include "ConditionArgumentator.h"
#include "FociSupportsArgumentator.h"
#include "IndicesArgumentator.h"
#include "SupportArgumentator.h"
#include "WeightsArgumentator.h"
#include "MinLengthFilter.h"
#include "MaxLengthFilter.h"
#include "MinSupportFilter.h"
#include "DisjointFilter.h"


[[cpp11::register]]
list dig_(list logicals_data,
          list doubles_data,
          list logicals_foci,
          list doubles_foci,
          list configuration_list,
          cpp11::function fun)
{
    Data data;
    data.addChains<logicals>(logicals_data);
    data.addChains<doubles>(doubles_data);
    data.addFoci<logicals>(logicals_foci);
    data.addFoci<doubles>(doubles_foci);

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
