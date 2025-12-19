#include <testthat.h>
#include "dig/Bitset.h"

context("dig/Bitset.h") {
    test_that("default constructor") {
        Bitset b;
        expect_true(b.empty());
        expect_true(b.size() == 0);
        expect_true(b.count() == 0);
    }

    test_that("sized constructor") {
        Bitset b(10);
        expect_true(!b.empty());
        expect_true(b.size() == 10);
        expect_true(b.count() == 0);
        
        for (size_t i = 0; i < 10; ++i) {
            expect_true(!b[i]);
        }
    }

    test_that("set and count") {
        Bitset b(10);
        expect_true(b.count() == 0);
        
        b.set(0);
        expect_true(b[0]);
        expect_true(b.count() == 1);
        
        b.set(5);
        expect_true(b[5]);
        expect_true(b.count() == 2);
        
        b.set(9);
        expect_true(b[9]);
        expect_true(b.count() == 3);
        
        // Setting same bit again shouldn't increase count
        b.set(5);
        expect_true(b.count() == 3);
    }

    test_that("operator[] access") {
        Bitset b(5);
        b.set(0);
        b.set(2);
        b.set(4);
        
        expect_true(b[0]);
        expect_true(!b[1]);
        expect_true(b[2]);
        expect_true(!b[3]);
        expect_true(b[4]);
    }

    test_that("at() with bounds checking") {
        Bitset b(5);
        b.set(2);
        
        expect_true(!b.at(0));
        expect_true(!b.at(1));
        expect_true(b.at(2));
        expect_true(!b.at(3));
        expect_true(!b.at(4));
        
        try {
            b.at(5);
            expect_true(false); // should not reach here
        } catch (const std::out_of_range& e) {
            expect_true(true); // expected exception
        }
        
        try {
            b.at(100);
            expect_true(false); // should not reach here
        } catch (const std::out_of_range& e) {
            expect_true(true); // expected exception
        }
    }

    test_that("bitwise AND operator") {
        Bitset a(8);
        a.set(0);
        a.set(2);
        a.set(4);
        a.set(6);
        
        Bitset b(8);
        b.set(1);
        b.set(2);
        b.set(5);
        b.set(6);
        
        Bitset c = a & b;
        expect_true(c.size() == 8);
        expect_true(c.count() == 2);
        expect_true(!c[0]);
        expect_true(!c[1]);
        expect_true(c[2]);
        expect_true(!c[3]);
        expect_true(!c[4]);
        expect_true(!c[5]);
        expect_true(c[6]);
        expect_true(!c[7]);
    }

    test_that("bitwise AND with incompatible sizes") {
        Bitset a(5);
        Bitset b(10);
        
        try {
            Bitset c = a & b;
            expect_true(false); // should not reach here
        } catch (const std::invalid_argument& e) {
            expect_true(true); // expected exception
        }
    }

    test_that("equality operator") {
        Bitset a(5);
        a.set(1);
        a.set(3);
        
        Bitset b(5);
        b.set(1);
        b.set(3);
        
        Bitset c(5);
        c.set(1);
        c.set(2);
        
        Bitset d(10);
        d.set(1);
        d.set(3);
        
        expect_true(a == b);
        expect_true(!(a == c));
        expect_true(!(a == d));
    }

    test_that("large bitset") {
        Bitset b(1000);
        expect_true(b.size() == 1000);
        expect_true(b.count() == 0);
        
        for (size_t i = 0; i < 1000; i += 10) {
            b.set(i);
        }
        
        expect_true(b.count() == 100);
        
        for (size_t i = 0; i < 1000; ++i) {
            if (i % 10 == 0) {
                expect_true(b[i]);
            } else {
                expect_true(!b[i]);
            }
        }
    }

    test_that("move constructor and assignment") {
        Bitset a(10);
        a.set(2);
        a.set(5);
        a.set(8);
        
        Bitset b = std::move(a);
        expect_true(b.size() == 10);
        expect_true(b.count() == 3);
        expect_true(b[2]);
        expect_true(b[5]);
        expect_true(b[8]);
        
        Bitset c(5);
        c = std::move(b);
        expect_true(c.size() == 10);
        expect_true(c.count() == 3);
        expect_true(c[2]);
        expect_true(c[5]);
        expect_true(c[8]);
    }
}
