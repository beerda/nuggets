#include "common.h"


[[cpp11::register]]
integers prune_non_maxima_(list data,
                           function compare)
{
    writable::integers result;

    if (data.size() > 0) {
        result.push_back(0);
    }

    for (size_t i = 1; i < data.size(); ++i) {
        bool add = true;

        for (size_t jj = 0; jj < result.size(); ++jj) {
            int j = result[jj];
            double comp = compare(data[i], data[j]);

            if (comp > 0.5 || comp < -0.5) {
                add = false;
                if (comp > 0.5) {
                    result[jj] = i;
                }
                break;
            }
        }

        if (add) {
            result.push_back(i);
        }
    }

    return result;
}
