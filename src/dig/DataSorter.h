#pragma once

#include <vector>
#include <algorithm>
#include <numeric>

#include "../common.h"


class DataSorter {
public:
    DataSorter()
    { }

    void addColumn(const LogicalVector& column)
    { columns.push_back(column); }

    vector<size_t> getSortedRowIndices() const
    {
        if (columns.empty()) {
            return vector<size_t>();
        }

        vector<size_t> indices(columns[0].size());
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
    vector<LogicalVector> columns;
};
