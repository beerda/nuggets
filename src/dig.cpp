#include <iostream>
#include "Config.hpp"
#include "Digger.hpp"
#include "ConditionArgumentator.hpp"


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
    ConditionArgumentator conditionArgumentator;

    if (config.hasConditionArgument()) {
        digger.addArgumentator(conditionArgumentator);
    }

    try {
        digger.run();
    } catch (exception& e) {
        cout << e.what() << endl;
    }

    writable::list result;

    return result;
}
