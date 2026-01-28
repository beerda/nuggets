#include <testthat.h>
#include "common.h"
#include "dig/Cache.h"


context("dig/Cache.h") {
    test_that("empty Cache") {
        Cache cache(3);

        Clause c0;
        Clause c1({ 1 });
        Clause c2({ 1, 2 });

        expect_true(cache.size() == 0);
        expect_error(cache.get(c0));
        expect_error(cache.get(c1));
        expect_error(cache.get(c2));
    }

    test_that("add and get") {
        Cache cache(3);

        Clause c0;
        Clause c1({ 1 });
        Clause c2({ 1, 2 });
        Clause c3({ 2 });
        Clause c4({ 2, 3 });
        Clause c5({ 1, 2, 3 });

        expect_true(cache.size() == 0);
        expect_error(cache.get(c0));
        expect_error(cache.get(c1));
        expect_error(cache.get(c2));
        expect_error(cache.get(c3));
        expect_error(cache.get(c4));
        expect_error(cache.get(c5));

        cache.add(c1, 0.5f);
        expect_true(cache.size() == 1);
        expect_error(cache.get(c0));
        expect_true(cache.get(c1) == 0.5f);

        cache.add(c2, 1.5f);
        expect_true(cache.size() == 2);
        expect_error(cache.get(c0));
        expect_true(cache.get(c1) == 0.5f);
        expect_true(cache.get(c2) == 1.5f);

        cache.add(c3, 2.5f);
        expect_true(cache.size() == 3);
        expect_error(cache.get(c0));
        expect_true(cache.get(c1) == 0.5f);
        expect_true(cache.get(c2) == 1.5f);
        expect_true(cache.get(c3) == 2.5f);

        cache.add(c4, 3.5f);
        expect_true(cache.size() == 4);
        expect_error(cache.get(c0));
        expect_true(cache.get(c1) == 0.5f);
        expect_true(cache.get(c2) == 1.5f);
        expect_true(cache.get(c3) == 2.5f);
        expect_true(cache.get(c4) == 3.5f);

        cache.add(c5, 4.5f);
        expect_true(cache.size() == 5);
        expect_error(cache.get(c0));
        expect_true(cache.get(c1) == 0.5f);
        expect_true(cache.get(c2) == 1.5f);
        expect_true(cache.get(c3) == 2.5f);
        expect_true(cache.get(c4) == 3.5f);
        expect_true(cache.get(c5) == 4.5f);
    }
}
