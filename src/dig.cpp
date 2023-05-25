#include <iostream>
#include "Config.hpp"
#include "Digger.hpp"
#include "ConditionArgumentator.hpp"
#include "IndicesArgumentator.hpp"
#include "SupportArgumentator.hpp"
#include "WeightsArgumentator.hpp"
#include "MinLengthFilter.hpp"
#include "MaxLengthFilter.hpp"
#include "MinSupportFilter.hpp"


[[cpp11::register]]
list dig_(list logicals_data,
          list doubles_data,
          list configuration_list,
          cpp11::function fun)
{
    Data data;
    data.addChains<logicals>(logicals_data);
    data.addChains<doubles>(doubles_data);

    Config config(configuration_list);
    Digger digger(data, fun);

    if (config.hasConditionArgument()) {
        digger.addArgumentator(new ConditionArgumentator(config.getPredicates()));
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

    try {
        digger.run();
    } catch (exception& e) {
        cout << e.what() << endl;
    }

    return digger.getResult();
}
