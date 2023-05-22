#include <iostream>
#include "Digger.hpp"


[[cpp11::register]]
list dig_(list logicals_data,
          list doubles_data,
          list config)
{
    Data data;
    data.addChains<logicals>(logicals_data);
    data.addChains<doubles>(doubles_data);

    Task task(data.size()); // create task of length 0
    Digger digger(data, task);

    try {
        digger.run();
    } catch (exception& e) {
        cout << e.what() << endl;
    }

    writable::list result;

    return result;
}
