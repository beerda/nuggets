#include <testthat.h>
#include "common.h"
#include "dig/ExcludedSubsets.h"

context("dig/ExcludedSubsets.h") {
    test_that("initialize") {
        ExcludedSubsets e;

        expect_true(e.empty());
        expect_true(e.size() == 0);

        List l;
        l.push_back(IntegerVector::create(9, 4));
        l.push_back(IntegerVector::create(2, 4, 0));
        l.push_back(IntegerVector::create(4));
        l.push_back(IntegerVector::create(5, 3, 9, 2));
        l.push_back(IntegerVector::create(0, 9));
        l.push_back(IntegerVector::create(8));

        e.initialize(l);
        expect_true(!e.empty());
        expect_true(e.size() == 7);

        // {9}, {2,4}
        const ExcludedSubsets::Subsets s0 = e.getExcludedSubsets(0);
        expect_true(s0.size() == 2);
        expect_true(s0[0].size() == 1);
        expect_true(s0[0][0] == 9);
        expect_true(s0[1].size() == 2);
        expect_true(s0[1][0] == 2);
        expect_true(s0[1][1] == 4);

        // {0,4}, {3,5,9}
        const ExcludedSubsets::Subsets s2 = e.getExcludedSubsets(2);
        expect_true(s2.size() == 2);
        expect_true(s2[0].size() == 2);
        expect_true(s2[0][0] == 0);
        expect_true(s2[0][1] == 4);
        expect_true(s2[1].size() == 3);
        expect_true(s2[1][0] == 3);
        expect_true(s2[1][1] == 5);
        expect_true(s2[1][2] == 9);

        // {2,5,9}
        const ExcludedSubsets::Subsets s3 = e.getExcludedSubsets(3);
        expect_true(s3.size() == 1);
        expect_true(s3[0].size() == 3);
        expect_true(s3[0][0] == 2);
        expect_true(s3[0][1] == 5);
        expect_true(s3[0][2] == 9);

        // {}, {9}, {0,2}
        const ExcludedSubsets::Subsets s4 = e.getExcludedSubsets(4);
        expect_true(s4.size() == 3);
        expect_true(s4[0].size() == 0);
        expect_true(s4[1].size() == 1);
        expect_true(s4[1][0] == 9);
        expect_true(s4[2].size() == 2);
        expect_true(s4[2][0] == 0);
        expect_true(s4[2][1] == 2);

        // {2,3,9}
        const ExcludedSubsets::Subsets s5 = e.getExcludedSubsets(5);
        expect_true(s5.size() == 1);
        expect_true(s5[0].size() == 3);
        expect_true(s5[0][0] == 2);
        expect_true(s5[0][1] == 3);
        expect_true(s5[0][2] == 9);

        // {}
        const ExcludedSubsets::Subsets s8 = e.getExcludedSubsets(8);
        expect_true(s8.size() == 1);
        expect_true(s8[0].size() == 0);

        // {4}, {0}, {2,3,5}
        const ExcludedSubsets::Subsets s9 = e.getExcludedSubsets(9);
        expect_true(s9.size() == 3);
        expect_true(s9[0].size() == 1);
        expect_true(s9[0][0] == 4);
        expect_true(s9[1].size() == 1);
        expect_true(s9[1][0] == 0);
        expect_true(s9[2].size() == 3);
        expect_true(s9[2][0] == 2);
        expect_true(s9[2][1] == 3);
        expect_true(s9[2][2] == 5);
    }

    test_that("initialize with empty list") {
        ExcludedSubsets e;

        List l;
        e.initialize(l);
        expect_true(e.empty());
        expect_true(e.size() == 0);
    }

    test_that("initialize with empty vectors") {
        ExcludedSubsets e;

        List l;
        l.push_back(IntegerVector::create());
        l.push_back(IntegerVector::create());
        l.push_back(IntegerVector::create());
        e.initialize(l);
        expect_true(e.empty());
        expect_true(e.size() == 0);
    }

    test_that("isExcluded") {
        ExcludedSubsets e;

        List l;
        l.push_back(IntegerVector::create(9, 4));
        l.push_back(IntegerVector::create(2, 4, 0));
        l.push_back(IntegerVector::create(4));
        l.push_back(IntegerVector::create(5, 3, 9, 2));
        l.push_back(IntegerVector::create(0, 9));
        l.push_back(IntegerVector::create(8));

        e.initialize(l);

        expect_true(!e.isExcluded({}, 0));
        expect_true(!e.isExcluded({4}, 0));
        expect_true(e.isExcluded({9}, 0));
        expect_true(e.isExcluded({1, 9}, 0));
        expect_true(e.isExcluded({2, 4}, 0));
        expect_true(e.isExcluded({4, 2}, 0));
        expect_true(e.isExcluded({4, 1, 2}, 0));

        expect_true(e.isExcluded({}, 4));
        expect_true(e.isExcluded({1}, 4));
        expect_true(e.isExcluded({1, 2}, 4));
        expect_true(e.isExcluded({0, 9}, 4));

        expect_true(e.isExcluded({}, 8));
        expect_true(e.isExcluded({1}, 8));
        expect_true(e.isExcluded({1, 2}, 8));
        expect_true(e.isExcluded({0, 9}, 8));

        expect_true(!e.isExcluded({}, 9));
        expect_true(!e.isExcluded({5}, 9));
        expect_true(!e.isExcluded({1}, 9));
        expect_true(e.isExcluded({0}, 9));
        expect_true(e.isExcluded({4}, 9));
        expect_true(e.isExcluded({5, 3, 2}, 9));
        expect_true(e.isExcluded({1, 2, 3, 5, 6}, 9));
        expect_true(!e.isExcluded({1, 2, 3, 6, 7}, 9));

        expect_true(!e.isExcluded({}, 3));
        expect_true(!e.isExcluded({4}, 3));
        expect_true(!e.isExcluded({9, 4}, 3));
        expect_true(!e.isExcluded({5}, 3));
        expect_true(!e.isExcluded({5, 9}, 3));
        expect_true(e.isExcluded({5, 9, 2}, 3));
        expect_true(e.isExcluded({2, 9, 5}, 3));
        expect_true(e.isExcluded({2, 5, 9}, 3));
        expect_true(e.isExcluded({2, 5, 9, 1}, 3));
        expect_true(e.isExcluded({1, 2, 5, 9}, 3));
    }
}
