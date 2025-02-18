#include <testthat.h>
#include "common.h"
#include "dig/DataSorter.h"

context("dig/DataSorter.h") {
    test_that("complex test") {
        //                    0      1      2      3      4      5
        LogicalVector vec1 = {true,  false, true,  false, true,  false};
        LogicalVector vec2 = {true,  true,  true,  false, false, false};
        LogicalVector vec3 = {false, false, false, false, true,  true};

        DataSorter sorter(6);
        sorter.addColumn(vec1);
        sorter.addColumn(vec2);
        sorter.addColumn(vec3);

        vector<size_t> res = sorter.getSortedRowIndices();
        vector<size_t> expected = {3, 5, 1, 4, 0, 2};
        for (size_t i = 0; i < res.size(); ++i) {
            expect_true(res[i] == expected[i]);
        }
    }
}
