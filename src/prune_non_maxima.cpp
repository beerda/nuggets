#include "common.h"
#include <utility>
#include <vector>


[[cpp11::register]]
integers prune_non_maxima_(list data,
                           function compare)
{
    vector<long> result;
    vector<long> packed;
    //writable::integers result;
    //writable::integers packed;

    if (data.size() > 0) {
        result.push_back(0);
    }

    for (size_t i = 1; i < data.size(); ++i) {
        bool add = true;
        bool pack = false;

        for (size_t jj = 0; jj < result.size(); ++jj) {
            int j = result[jj];
            if (j >= 0) {
                double comp = compare(data[i], data[j]);

                if (comp > 0.5) {
                    result[jj] = -1;
                    pack = true;
                } else if (comp < -0.5) {
                    add = false;
                }
            }
        }

        if (pack) {
            packed.clear();
            for (size_t k = 0; k < result.size(); ++k) {
                if (result[k] >= 0) {
                    packed.push_back(result[k]);
                }
            }

            swap(result, packed);
        }

        if (add) {
            result.push_back(i);
        }
    }

    writable::integers res;
    for (size_t k = 0; k < result.size(); ++k) {
        res.push_back(result[k]);
    }
    return res;
}
