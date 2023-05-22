#include <iostream>
#include "Digger.hpp"


[[cpp11::register]]
list dig_(list logicals_data,
          list doubles_data,
          list config,
          cpp11::function fun)
{
    Data data;
    data.addChains<logicals>(logicals_data);
    data.addChains<doubles>(doubles_data);

    Digger digger(data, fun);

    try {
        digger.run();
    } catch (exception& e) {
        cout << e.what() << endl;
    }

    writable::list result;

    return result;
}
