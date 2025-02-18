#pragma once

#include <vector>
#include <algorithm>
#include <numeric>

#include "../common.h"


class DataSorter {
public:
    DataSorter(size_t nrow)
        : nrow(nrow)
    { }

    void addColumn(const LogicalVector& column)
    { columns.push_back(column); }

    vector<size_t> getSortedRowIndices() const
    {
        vector<size_t> indices(nrow);
        iota(indices.begin(), indices.end(), 0); // fill with 0, 1, 2, ..., nrow - 1

        sort(indices.begin(), indices.end(), [&](size_t i, size_t j) {
            for (size_t k = 0; k < columns.size(); ++k) {
                if (columns[k][i] < columns[k][j]) {
                    return true;
                } else if (columns[k][i] > columns[k][j]) {
                    return false;
                }
            }
            return false;
        });

        return indices;
    }

private:
    size_t nrow;
    vector<LogicalVector> columns;
};
