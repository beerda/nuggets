#include <iostream>
#include "Config.hpp"
#include "Digger.hpp"
#include "ConditionArgumentator.hpp"
#include "LengthFilter.hpp"
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
    Digger digger(config, data, fun);

    if (config.hasConditionArgument()) {
        digger.addArgumentator(new ConditionArgumentator(config.getPredicates()));
    }
    if (config.getMaxLength() >= 0) {
        digger.addFilter(new LengthFilter(config.getMaxLength()));
    }
    if (config.getMinSupport() > 0) {
        digger.addFilter(new MinSupportFilter(config.getMinSupport()));
    }

    try {
        digger.run();
    } catch (exception& e) {
        cout << e.what() << endl;
    }

    return digger.getResult();
}
