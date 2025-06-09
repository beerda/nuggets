#include <testthat.h>
#include "common.h"
#include "dig/Config.h"

context("dig/Config.h") {
    test_that("non-defaults") {
        List r = List::create(
            Named("nrow") = 600,
            Named("threads") = 2,
            Named("minLength") = 3,
            Named("maxLength") = 5,
            Named("maxResults") = 6,
            Named("minSupport") = 0.5,
            Named("minFocusSupport") = 0.6,
            Named("minConditionalFocusSupport") = 0.7,
            Named("maxSupport") = 0.8,
            Named("tautologyLimit") = 0.9,
            Named("filterEmptyFoci") = true,
            Named("verbose") = false,
            Named("tNorm") = "goedel",
            Named("excluded") = List::create(),
            Named("disjoint") = IntegerVector::create(1, 1, 2, 2, 2, 4, 5),
            Named("arguments") = CharacterVector::create("condition", "pp", "np", "indices")
        );

        CharacterVector n = CharacterVector::create("a", "b", "c");

        Config c(r, n);

        expect_true(c.getMaxLength() == 5);
        expect_true(c.getMaxResults() == 6);
    }

    test_that("complex test with defaults") {
        List r = List::create(
            Named("nrow") = 600,
            Named("threads") = 2,
            Named("minLength") = 3,
            Named("maxLength") = -1,
            Named("maxResults") = -1,
            Named("minSupport") = 0.5,
            Named("minFocusSupport") = 0.6,
            Named("minConditionalFocusSupport") = 0.7,
            Named("maxSupport") = 0.8,
            Named("tautologyLimit") = 0.9,
            Named("filterEmptyFoci") = true,
            Named("verbose") = false,
            Named("tNorm") = "goedel",
            Named("excluded") = List::create(),
            Named("disjoint") = IntegerVector::create(1, 1, 2, 2, 2, 4, 5),
            Named("arguments") = CharacterVector::create("condition", "pp", "np", "indices")
        );

        CharacterVector n = CharacterVector::create("a", "b", "c");

        Config c(r, n);

        expect_true(c.getNrow() == 600);
        expect_true(c.getThreads() == 2);
        expect_true(c.getMinLength() == 3);
        expect_true(c.getMaxLength() == INT_MAX);
        expect_true(c.getMaxResults() == INT_MAX);
        expect_true(c.getMinSupport() == 0.5);
        expect_true(c.getMinSum() == 300);
        expect_true(c.getMinFocusSupport() == 0.6f);
        expect_true(c.getMinFocusSum() == 360);
        expect_true(c.getMinConditionalFocusSupport() == 0.7f);
        expect_true(c.getMaxSupport() == 0.8f);
        expect_true(c.hasFilterEmptyFoci() == true);
        expect_true(c.isVerbose() == false);

        expect_true(c.getExcluded().size() == 0);

        expect_true(c.hasDisjoint() == true);
        expect_true(c.getDisjoint().size() == 8);
        expect_true(c.getDisjoint()[0] == 0);
        expect_true(c.getDisjoint()[1] == 1);
        expect_true(c.getDisjoint()[2] == 1);
        expect_true(c.getDisjoint()[3] == 2);
        expect_true(c.getDisjoint()[4] == 2);
        expect_true(c.getDisjoint()[5] == 2);
        expect_true(c.getDisjoint()[6] == 4);
        expect_true(c.getDisjoint()[7] == 5);

        expect_true(c.hasConditionArgument()== true);
        expect_true(c.hasFociSupportsArgument() == false);
        expect_true(c.hasContiPpArgument() == true);
        expect_true(c.hasContiNpArgument() == true);
        expect_true(c.hasContiPnArgument() == false);
        expect_true(c.hasContiNnArgument() == false);
        expect_true(c.hasIndicesArgument() == true);
        expect_true(c.hasSumArgument() == false);
        expect_true(c.hasSupportArgument() == false);
        expect_true(c.hasWeightsArgument() == false);

        expect_true(c.getChainName(0) == "");
        expect_true(c.getChainName(1) == "a");
        expect_true(c.getChainName(2) == "b");
        expect_true(c.getChainName(3) == "c");
    }
}
