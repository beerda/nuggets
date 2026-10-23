#include <testthat.h>
#include "common.h"
#include "dig/Trie.h"

context("dig/Trie.h") {
    test_that("empty Trie") {
        Trie<int> trie(10);
        trie.initializeForQueries();

        expect_true(trie.size() == 0);
        expect_true(!trie.contains({}));
        expect_true(trie.isPrefix({}));
        expect_true(!trie.isProperPrefix({}));
        expect_true(!trie.contains({ 1 }));
        expect_true(!trie.contains({}, 1));
        expect_true(!trie.isPrefix({ 1 }));
        expect_true(!trie.isPrefix({}, 1));
        expect_true(!trie.isProperPrefix({ 1 }));
        expect_true(!trie.isProperPrefix({}, 1));
    }

    test_that("stores an empty sequence") {
        Trie<int> trie(10);
        trie.insert({});
        trie.insert({});
        trie.insert({1,2});
        trie.initializeForQueries();

        expect_true(trie.size() == 2);
        expect_true(trie.contains({}));
        expect_true(trie.contains({ 1, 2 }));
        expect_true(trie.contains({ 1 }, 2));
        expect_true(!trie.contains({ 1 }));
        expect_true(!trie.contains({}, 1));
        expect_true(!trie.contains({ 2 }));
        expect_true(!trie.contains({ 1, 2, 3 }));
        expect_true(!trie.contains({ 1, 2 }, 3));
        expect_true(trie.isPrefix({}));
        expect_true(trie.isPrefix({ 1 }));
        expect_true(trie.isPrefix({}, 1));
        expect_true(trie.isPrefix({ 1, 2 }));
        expect_true(trie.isPrefix({ 1 }, 2));
        expect_true(!trie.isPrefix({ 1, 2, 3 }));
        expect_true(!trie.isPrefix({ 1, 2 }, 3));
        expect_true(!trie.isPrefix({ 2 }));
        expect_true(!trie.isPrefix({}, 2));
        expect_true(trie.isProperPrefix({}));
        expect_true(trie.isProperPrefix({ 1 }));
        expect_true(trie.isProperPrefix({}, 1));
        expect_true(!trie.isProperPrefix({ 1, 2 }));
        expect_true(!trie.isProperPrefix({ 1 }, 2));
        expect_true(!trie.isProperPrefix({ 1, 2, 3 }));
        expect_true(!trie.isProperPrefix({ 1, 2 }, 3));
        expect_true(!trie.isProperPrefix({ 2 }));
        expect_true(!trie.isProperPrefix({}, 2));
    }

    test_that("contains sequences and prefixes") {
        Trie<int> trie(10);
        trie.insert({ 1, 2, 3 });
        trie.insert({ 1, 2 });
        trie.insert({ 1, 3 });
        trie.insert({ 2, 3 });
        trie.initializeForQueries();

        expect_true(trie.size() == 4);
        expect_true(trie.contains({ 1, 2, 3 }));
        expect_true(trie.contains({ 1, 2 }));
        expect_true(trie.contains({ 1, 3 }));
        expect_true(trie.contains({ 2, 3 }));
        expect_true(!trie.contains({}));
        expect_true(!trie.contains({ 1 }));
        expect_true(!trie.contains({ 2 }));
        expect_true(!trie.contains({ 1, 2, 3, 4 }));
        expect_true(trie.contains({ 1, 2 }, 3));
        expect_true(trie.contains({ 1 }, 2));
        expect_true(!trie.contains({ 2 }, 1));
        expect_true(!trie.contains({ 1, 2, 3 }, 4));

        expect_true(trie.isPrefix({}));
        expect_true(trie.isPrefix({ 1 }));
        expect_true(trie.isPrefix({ 1, 2 }));
        expect_true(trie.isPrefix({ 1, 2, 3 }));
        expect_true(trie.isPrefix({ 2 }));
        expect_true(!trie.isPrefix({ 2, 1 }));
        expect_true(!trie.isPrefix({ 3 }));
        expect_true(trie.isPrefix({}, 1));
        expect_true(trie.isPrefix({ 1 }, 2));
        expect_true(trie.isPrefix({ 1, 2 }, 3));
        expect_true(trie.isPrefix({ 2 }, 3));
        expect_true(!trie.isPrefix({ 2 }, 1));
        expect_true(!trie.isPrefix({ 1, 2, 3 }, 4));

        expect_true(trie.isProperPrefix({}));
        expect_true(trie.isProperPrefix({ 1 }));
        expect_true(trie.isProperPrefix({ 1, 2 }));
        expect_true(!trie.isProperPrefix({ 1, 2, 3 }));
        expect_true(trie.isProperPrefix({ 2 }));
        expect_true(!trie.isProperPrefix({ 2, 3 }));
        expect_true(!trie.isProperPrefix({ 2, 1 }));
        expect_true(!trie.isProperPrefix({ 3 }));
        expect_true(trie.isProperPrefix({}, 1));
        expect_true(trie.isProperPrefix({ 1 }, 2));
        expect_true(!trie.isProperPrefix({ 1, 2 }, 3));
        expect_true(trie.isProperPrefix({}, 2));
        expect_true(!trie.isProperPrefix({ 2 }, 3));
        expect_true(!trie.isProperPrefix({ 2 }, 1));
        expect_true(!trie.isProperPrefix({ 1, 2, 3 }, 4));
    }

    test_that("preserves non-ascending sequence order") {
        Trie<int> trie(10);
        trie.insert({ 4, 2, 5 });
        trie.insert({ 4, 2, 3 });
        trie.insert({ 3, 1 });
        trie.insert({ 3, 1, 2 });
        trie.initializeForQueries();

        expect_true(trie.size() == 4);
        expect_true(trie.contains({ 4, 2, 5 }));
        expect_true(trie.contains({ 4, 2, 3 }));
        expect_true(trie.contains({ 3, 1 }));
        expect_true(trie.contains({ 3, 1, 2 }));
        expect_true(!trie.contains({ 2, 4, 5 }));
        expect_true(!trie.contains({ 4, 5, 2 }));
        expect_true(!trie.contains({ 1, 3 }));

        expect_true(trie.isPrefix({ 4, 2 }));
        expect_true(trie.isPrefix({ 3, 1 }));
        expect_true(!trie.isPrefix({ 2, 4 }));
        expect_true(!trie.isPrefix({ 4, 3 }));
    }

    test_that("deduplicates sequences") {
        Trie<int> trie(10);
        trie.insert({ 1, 2 });
        trie.insert({ 1, 2 });
        trie.insert({ 1, 2, 3 });
        trie.insert({ 1, 2, 3 });
        trie.initializeForQueries();

        expect_true(trie.size() == 2);
        expect_true(trie.contains({ 1, 2 }));
        expect_true(trie.contains({ 1, 2, 3 }));
    }
}
