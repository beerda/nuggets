#include <testthat.h>
#include "common.h"
#include "dig/Selector.h"

#include <iostream>
#include <vector>
#include <string>

context("dig/Selector") {
    test_that("initialize and use non-constant") {
        Selector s(10, false);
        expect_true(s.size() == 10);
        expect_true(s.getSelectedCount() == 10);

        for (size_t i = 0; i < 10; ++i) {
            expect_true(s.isSelected(i));
        }

        for (size_t j = 0; j < 10; ++j) {
            expect_true(s.size() == 10);
            expect_true(s.getSelectedCount() == 10 - j);
            expect_true(s.isSelected(j));

            s.unselect(j);

            expect_true(s.size() == 10);
            expect_true(s.getSelectedCount() == 9 - j);
            expect_true(!s.isSelected(j));
        }
    }

    test_that("initialize and use constant") {
        Selector s(10, true);
        expect_true(s.size() == 10);
        expect_true(s.getSelectedCount() == 10);

        for (size_t i = 0; i < 10; ++i) {
            expect_true(s.isSelected(i));
        }
    }
}
