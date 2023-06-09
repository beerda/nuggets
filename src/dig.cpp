#include <iostream>
#include "Config.hpp"
#include "Digger.hpp"
#include "ConditionArgumentator.hpp"
#include "FociSupportsArgumentator.hpp"
#include "IndicesArgumentator.hpp"
#include "SupportArgumentator.hpp"
#include "WeightsArgumentator.hpp"
#include "MinLengthFilter.hpp"
#include "MaxLengthFilter.hpp"
#include "MinSupportFilter.hpp"
#include "DisjointFilter.hpp"


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
        digger.addArgumentator(new FociSupportsArgumentator(config.getFoci(), data));
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
    if (config.hasDisjoint()) {
        digger.addFilter(new DisjointFilter(config.getDisjoint()));
    }

    try {
        digger.run();
    } catch (exception& e) {
        cout << e.what() << endl;
    }

    return digger.getResult();
}
