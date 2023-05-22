#include "Digger.hpp"


[[cpp11::register]]
list dig_(list logicals_data,
          list numeric_data,
          list config)
{
    Data data;

    for (long int i = 0; i < logicals_data.size(); i++) {
        logicals col = logicals_data[i];
        data.addChain(col);
    }

    for (long int i = 0; i < numeric_data.size(); i++) {
        doubles col = numeric_data[i];
        data.addChain(col);
    }

    Task task(data.size());

    Digger digger(data, task);


    writable::list result;

    return result;
}
