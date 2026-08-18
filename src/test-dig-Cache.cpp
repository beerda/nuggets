#include <testthat.h>
#include "common.h"
#include "dig/Cache.h"


context("dig/Cache.h") {
    test_that("empty Cache") {
        Cache cache(3, 3);

        Clause c1({ 1 });
        Clause c2({ 1, 2 });

        expect_true(cache.size() == 0);
        expect_true(cache.get(c1) == -1); // -1 = NOT_IN_CACHE
        expect_true(cache.get(c2) == -1); // -1 = NOT_IN_CACHE
    }

    test_that("add and get") {
        Cache cache(3, 3);

        Clause c1({ 1 });
        Clause c12({ 1, 2 });
        Clause c123({ 1, 2, 3 });
        Clause c2({ 2 });
        Clause c23({ 2, 3 });

        expect_true(cache.size() == 0);
        expect_true(cache.get(c1) == -1);
        expect_true(cache.get(c12) == -1);
        expect_true(cache.get(c123) == -1);
        expect_true(cache.get(c2) == -1);
        expect_true(cache.get(c23) == -1);

        cache.add(c1, 0.5f);
        expect_true(cache.size() == 1);
        expect_true(cache.get(c1) == 0.5f);
        expect_true(cache.get(c12) == -1);
        expect_true(cache.get(c123) == -1);
        expect_true(cache.get(c2) == -1);
        expect_true(cache.get(c23) == -1);

        cache.add(c2, 1.5f);
        expect_true(cache.size() == 2);
        expect_true(cache.get(c1) == 0.5f);
        expect_true(cache.get(c12) == -1);
        expect_true(cache.get(c123) == -1);
        expect_true(cache.get(c2) == 1.5f);
        expect_true(cache.get(c23) == -1);

        cache.add(c12, 2.5f);
        expect_true(cache.size() == 3);
        expect_true(cache.get(c1) == 0.5f);
        expect_true(cache.get(c12) == 2.5f);
        expect_true(cache.get(c123) == -1);
        expect_true(cache.get(c2) == 1.5f);
        expect_true(cache.get(c23) == -1);

        cache.add(c123, 3.5f);
        expect_true(cache.size() == 4);
        expect_true(cache.get(c1) == 0.5f);
        expect_true(cache.get(c12) == 2.5f);
        expect_true(cache.get(c123) == 3.5f);
        expect_true(cache.get(c2) == 1.5f);
        expect_true(cache.get(c23) == -1);

        cache.add(c23, 4.5f);
        expect_true(cache.size() == 5);
        expect_true(cache.get(c1) == 0.5f);
        expect_true(cache.get(c12) == 2.5f);
        expect_true(cache.get(c123) == 3.5f);
        expect_true(cache.get(c2) == 1.5f);
        expect_true(cache.get(c23) == 4.5f);
    }
}
