#include <testthat.h>
#include "common.h"
#include "dig/Config.h"

context("dig/Config.h") {
    test_that("complex test") {
        List r = List::create(
            Named("nrow") = 600,
            Named("threads") = 2,
            Named("minLength") = 3,
            Named("maxLength") = 4,
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

        Config c(r);

        expect_true(c.getNrow() == 600);
        expect_true(c.getThreads() == 2);
        expect_true(c.getMinLength() == 3);
        expect_true(c.getMaxLength() == 4);
        expect_true(c.getMaxResults() == -1);
        expect_true(c.getMinSupport() == 0.5);
        expect_true(c.getMinFocusSupport() == 0.6);
        expect_true(c.getMinConditionalFocusSupport() == 0.7);
        expect_true(c.getMaxSupport() == 0.8);
        expect_true(c.getTautologyLimit() == 0.9);
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
    }
}
