#include <testthat.h>
#include "common.h"
#include "dig/BaseStorage.h"

context("dig/BaseStorage.h") {
    test_that("format condition") {
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
        CharacterVector n = CharacterVector::create("a", "b", "c", "d", "e");
        Config c(r, n);
        BaseStorage b(c);

        Clause cl{ };
        Clause cl3{ 3 };
        Clause cl13{ 1, 3 };
        Clause cl31{ 3, 1 };
        Clause cl415{ 4, 1, 5 };

        expect_true(b.formatCondition(cl, 0) == "{}");
        expect_true(b.formatCondition(cl, 2) == "{b}");
        expect_true(b.formatCondition(cl3, 2) == "{b,c}");
        expect_true(b.formatCondition(cl13, 2) == "{a,b,c}");
        expect_true(b.formatCondition(cl31, 2) == "{a,b,c}");
        expect_true(b.formatCondition(cl415, 3) == "{a,c,d,e}");
    }
}
