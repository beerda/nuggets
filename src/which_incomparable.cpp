#include "common.h"
#include <vector>


[[cpp11::register]]
integers which_incomparable_(int n,
                             function comparable)
{
    writable::integers result;

    if (n > 0) {
        result.push_back(0);
    }

    for (size_t i = 1; i < n; ++i) {
        bool save = true;

        for (size_t jj = 0; jj < result.size(); ++jj) {
            int j = result[jj];
            bool comp = comparable(i, j);

            if (comp) {
                save = false;
                break;
            }
        }

        if (save) {
            result.push_back(i);
        }
    }

    return result;
}
