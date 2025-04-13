#include <testthat.h>
#include "common.h"
#include "dig/BitChain.h"
#include "dig/ChainCollection.h"

context("dig/ChainCollection") {
    test_that("initialize from List of LogicalVectors") {
        LogicalVector c1 = LogicalVector::create(true, true, true, true, false);
        LogicalVector c2 = c1;
        LogicalVector c3 = c1;
        LogicalVector f1 = c1;
        LogicalVector f2 = c1;
        LogicalVector f3 = c1;

        {
            //                     1   2   3   4   5   6
            List l = List::create(c1, f1, c2, f2, c3, f3);
            LogicalVector con = LogicalVector::create(true, false, true, false, true, false);
            LogicalVector foc = LogicalVector::create(false, true, false, true, false, true);
            ChainCollection<BitChain> cc(l, con, foc);

            expect_true(cc.size() == 6);
            expect_true(cc.empty() == false);

            expect_true(cc.at(0).getClause().back() == 1);
            expect_true(cc.at(1).getClause().back() == 3);
            expect_true(cc.at(2).getClause().back() == 5);
            expect_true(cc.at(3).getClause().back() == 2);
            expect_true(cc.at(4).getClause().back() == 4);
            expect_true(cc.at(5).getClause().back() == 6);

            expect_true(cc.at(0).isCondition());
            expect_true(cc.at(1).isCondition());
            expect_true(cc.at(2).isCondition());
            expect_true(!cc.at(3).isCondition());
            expect_true(!cc.at(4).isCondition());
            expect_true(!cc.at(5).isCondition());

            expect_true(!cc.at(0).isFocus());
            expect_true(!cc.at(1).isFocus());
            expect_true(!cc.at(2).isFocus());
            expect_true(cc.at(3).isFocus());
            expect_true(cc.at(4).isFocus());
            expect_true(cc.at(5).isFocus());

            expect_true(cc.conditions().size() == 3);
            expect_true(cc.foci().size() == 3);

            vector<size_t> idsCond;
            for (const BitChain& b : cc.conditions()) {
                idsCond.push_back(b.getClause().back());
            }
            expect_true(idsCond == vector<size_t>({ 1, 3, 5 }));

            vector<size_t> idsFoc;
            for (const BitChain& b : cc.foci()) {
                idsFoc.push_back(b.getClause().back());
            }
            expect_true(idsFoc == vector<size_t>({ 2, 4, 6 }));
        }
        {
            //                     1   2   3   4   5   6
            // f3 is BOTH
            List l = List::create(f1, f2, c1, f3, c2, c3);
            LogicalVector con = LogicalVector::create(false, false, true, true, true, true);
            LogicalVector foc = LogicalVector::create(true, true, false, true, false, false);
            ChainCollection<BitChain> cc(l, con, foc);

            expect_true(cc.size() == 6);
            expect_true(cc.empty() == false);

            expect_true(cc.at(0).getClause().back() == 3);
            expect_true(cc.at(1).getClause().back() == 5);
            expect_true(cc.at(2).getClause().back() == 6);
            expect_true(cc.at(3).getClause().back() == 4);
            expect_true(cc.at(4).getClause().back() == 1);
            expect_true(cc.at(5).getClause().back() == 2);

            expect_true(cc.at(0).isCondition());
            expect_true(cc.at(1).isCondition());
            expect_true(cc.at(2).isCondition());
            expect_true(cc.at(3).isCondition());
            expect_true(!cc.at(4).isCondition());
            expect_true(!cc.at(5).isCondition());

            expect_true(!cc.at(0).isFocus());
            expect_true(!cc.at(1).isFocus());
            expect_true(!cc.at(2).isFocus());
            expect_true(cc.at(3).isFocus());
            expect_true(cc.at(4).isFocus());
            expect_true(cc.at(5).isFocus());

            expect_true(cc.conditions().size() == 4);
            expect_true(cc.foci().size() == 3);

            vector<size_t> idsCond;
            for (const BitChain& b : cc.conditions()) {
                idsCond.push_back(b.getClause().back());
            }
            expect_true(idsCond == vector<size_t>({ 3, 5, 6, 4 }));

            vector<size_t> idsFoc;
            for (const BitChain& b : cc.foci()) {
                idsFoc.push_back(b.getClause().back());
            }
            expect_true(idsFoc == vector<size_t>({ 4, 1, 2 }));
        }



    }
}
