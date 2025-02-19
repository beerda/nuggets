#include <testthat.h>
#include "common.h"
#include "dig/Data.h"
#include "dig/BitChain.h"
#include "dig/VectorNumChain.h"


using DataType = Data<BitChain, VectorNumChain<GOGUEN>>;
using DualChainType = DataType::DualChainType;

context("dig/Data.h") {
    test_that("creation") {
        DataType data(10);
        expect_true(data.nrow() == 10);
        expect_true(data.size() == 0);
        expect_true(data.getCondition().size() == 0);
        expect_true(data.getFoci().size() == 0);

        data.addUnusedChain(); // 0
        expect_true(data.nrow() == 10);
        expect_true(data.size() == 1);
        expect_true(data.getCondition().size() == 0);
        expect_true(data.getFoci().size() == 0);

        data.addUnusedChain(); // 1
        expect_true(data.nrow() == 10);
        expect_true(data.size() == 2);
        expect_true(data.getCondition().size() == 0);
        expect_true(data.getFoci().size() == 0);

        LogicalVector data1(10);
        LogicalVector data2(10);
        NumericVector data3(10);
        for (int i = 0; i < data1.size(); i++) {
            data1[i] = (i == 2 || i == 5);
            data2[i] = (i == 2 || i == 6);
            data3[i] = i / 10.0;
        }

        data.addChain(data1, "d1", true, false); // 2
        expect_true(data.nrow() == 10);
        expect_true(data.size() == 3);
        expect_true(data.getCondition().size() == 1);
        expect_true(data.getCondition()[0] == 2);
        expect_true(data.getFoci().size() == 0);
        expect_true(data.getName(2) == "d1");

        data.addChain(data2, "d2", false, true); // 3
        expect_true(data.nrow() == 10);
        expect_true(data.size() == 4);
        expect_true(data.getCondition().size() == 1);
        expect_true(data.getCondition()[0] == 2);
        expect_true(data.getFoci().size() == 1);
        expect_true(data.getFoci()[0] == 3);
        expect_true(data.getName(2) == "d1");
        expect_true(data.getName(3) == "d2");

        data.addUnusedChain(); // 4
        expect_true(data.nrow() == 10);
        expect_true(data.size() == 5);
        expect_true(data.getCondition().size() == 1);
        expect_true(data.getFoci().size() == 1);

        data.addChain(data3, "d3", true, true); // 5
        expect_true(data.nrow() == 10);
        expect_true(data.size() == 6);
        expect_true(data.getCondition().size() == 2);
        expect_true(data.getCondition()[0] == 2);
        expect_true(data.getCondition()[1] == 5);
        expect_true(data.getFoci().size() == 2);
        expect_true(data.getFoci()[0] == 3);
        expect_true(data.getFoci()[1] == 5);
        expect_true(data.getName(2) == "d1");
        expect_true(data.getName(3) == "d2");
        expect_true(data.getName(5) == "d3");

        expect_error(data.getPositiveChain(0));
        expect_error(data.getPositiveChain(1));
        expect_true(!data.getPositiveChain(2).empty());
        expect_true(!data.getPositiveChain(3).empty());
        expect_error(data.getPositiveChain(4));
        expect_true(!data.getPositiveChain(5).empty());

        expect_error(data.getNegativeChain(0));
        expect_error(data.getNegativeChain(1));
        expect_error(data.getNegativeChain(2));
        expect_error(data.getNegativeChain(3));
        expect_error(data.getNegativeChain(4));
        expect_error(data.getNegativeChain(5));

        data.initializeNegativeFoci();

        expect_error(data.getPositiveChain(0));
        expect_error(data.getPositiveChain(1));
        expect_true(!data.getPositiveChain(2).empty());
        expect_true(!data.getPositiveChain(3).empty());
        expect_error(data.getPositiveChain(4));
        expect_true(!data.getPositiveChain(5).empty());

        expect_error(data.getNegativeChain(0));
        expect_error(data.getNegativeChain(1));
        expect_error(data.getNegativeChain(2));
        expect_true(!data.getNegativeChain(3).empty());
        expect_error(data.getNegativeChain(4));
        expect_true(!data.getNegativeChain(5).empty());
    }

    test_that("condition order optimization") {
        LogicalVector data0({false, false, false, false, true});
        LogicalVector data1({true, true, true, true, true});
        LogicalVector data2({true, true, true, false, false});
        NumericVector data3({1, 1, 0, 0, 1});
        NumericVector data4({1, 0, 0, 0, 1});

        {
            DataType data(5);
            data.addChain(data0, "d0", true, false);
            data.addChain(data1, "d1", true, false);
            data.addChain(data2, "d2", true, false);
            data.addChain(data3, "d3", true, false);
            data.addChain(data4, "d4", true, false);

            data.optimizeConditionOrder();
            vector<int> res = data.getCondition();
            expect_true(res.size() == 5);
            expect_true(data.getName(res[0]) == "d0");
            expect_true(data.getName(res[1]) == "d2");
            expect_true(data.getName(res[2]) == "d1");
            expect_true(data.getName(res[3]) == "d4");
            expect_true(data.getName(res[4]) == "d3");
        }

        {
            DataType data(5);
            data.addChain(data4, "d4", true, false);
            data.addChain(data3, "d3", true, false);
            data.addChain(data2, "d2", true, false);
            data.addChain(data1, "d1", true, false);
            data.addChain(data0, "d0", true, false);

            data.optimizeConditionOrder();
            vector<int> res = data.getCondition();
            expect_true(res.size() == 5);
            expect_true(data.getName(res[0]) == "d0");
            expect_true(data.getName(res[1]) == "d2");
            expect_true(data.getName(res[2]) == "d1");
            expect_true(data.getName(res[3]) == "d4");
            expect_true(data.getName(res[4]) == "d3");
        }

    }
}
