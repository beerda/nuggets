#######################################################################
# nuggets: An R framework for exploration of patterns in data
# Copyright (C) 2025 Michal Burda
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program. If not, see <https://www.gnu.org/licenses/>.
#######################################################################


# Test .must_be_flag
test_that(".must_be_flag", {
    # Valid cases
    expect_no_error(.must_be_flag(TRUE))
    expect_no_error(.must_be_flag(FALSE))
    
    # null = TRUE cases
    expect_no_error(.must_be_flag(NULL, null = TRUE))
    expect_error(.must_be_flag(NULL, null = FALSE), "must be a flag")
    
    # Error cases - wrong types
    expect_error(.must_be_flag(1), "must be a flag")
    expect_error(.must_be_flag("TRUE"), "must be a flag")
    expect_error(.must_be_flag(NA), "must be a flag")
    expect_error(.must_be_flag(c(TRUE, FALSE)), "must be a flag")
    
    # Check error message format
    expect_error(.must_be_flag(1), "You've supplied a")
})


# Test .must_be_atomic_scalar
test_that(".must_be_atomic_scalar", {
    # Valid cases
    expect_no_error(.must_be_atomic_scalar(1))
    expect_no_error(.must_be_atomic_scalar(1L))
    expect_no_error(.must_be_atomic_scalar("a"))
    expect_no_error(.must_be_atomic_scalar(TRUE))
    
    # null = TRUE cases
    expect_no_error(.must_be_atomic_scalar(NULL, null = TRUE))
    expect_error(.must_be_atomic_scalar(NULL), "must be an atomic scalar")
    
    # Error cases
    expect_error(.must_be_atomic_scalar(c(1, 2)), "must be an atomic scalar")
    expect_error(.must_be_atomic_scalar(list(a = 1)), "must be an atomic scalar")
    expect_error(.must_be_atomic_scalar(matrix(1)), "must be an atomic scalar")
    
    # Check error message format
    expect_error(.must_be_atomic_scalar(list(a = 1)), "You've supplied a")
})


# Test .must_be_integerish_scalar
test_that(".must_be_integerish_scalar", {
    # Valid cases
    expect_no_error(.must_be_integerish_scalar(1L))
    expect_no_error(.must_be_integerish_scalar(5))
    
    # null = TRUE cases
    expect_no_error(.must_be_integerish_scalar(NULL, null = TRUE))
    expect_error(.must_be_integerish_scalar(NULL), "must be an integerish scalar")
    
    # Error cases
    expect_error(.must_be_integerish_scalar(1.5), "must be an integerish scalar")
    expect_error(.must_be_integerish_scalar(c(1, 2)), "must be an integerish scalar")
    expect_error(.must_be_integerish_scalar("1"), "must be an integerish scalar")
})


# Test .must_be_double_scalar
test_that(".must_be_double_scalar", {
    # Valid cases
    expect_no_error(.must_be_double_scalar(1.5))
    expect_no_error(.must_be_double_scalar(5.0))
    
    # null = TRUE cases
    expect_no_error(.must_be_double_scalar(NULL, null = TRUE))
    expect_error(.must_be_double_scalar(NULL), "must be a double scalar")
    
    # Error cases
    expect_error(.must_be_double_scalar(1L), "must be a double scalar")
    expect_error(.must_be_double_scalar(c(1.5, 2.5)), "must be a double scalar")
    expect_error(.must_be_double_scalar("1.5"), "must be a double scalar")
})


# Test .must_be_character_scalar
test_that(".must_be_character_scalar", {
    # Valid cases
    expect_no_error(.must_be_character_scalar("hello"))
    expect_no_error(.must_be_character_scalar(""))
    
    # null = TRUE cases
    expect_no_error(.must_be_character_scalar(NULL, null = TRUE))
    expect_error(.must_be_character_scalar(NULL), "must be a character scalar")
    
    # Error cases
    expect_error(.must_be_character_scalar(1), "must be a character scalar")
    expect_error(.must_be_character_scalar(c("a", "b")), "must be a character scalar")
    expect_error(.must_be_character_scalar(TRUE), "must be a character scalar")
})


# Test .must_be_logical_scalar
test_that(".must_be_logical_scalar", {
    # Valid cases
    expect_no_error(.must_be_logical_scalar(TRUE))
    expect_no_error(.must_be_logical_scalar(FALSE))
    expect_no_error(.must_be_logical_scalar(NA))  # NA is allowed for logical_scalar
    
    # null = TRUE cases
    expect_no_error(.must_be_logical_scalar(NULL, null = TRUE))
    expect_error(.must_be_logical_scalar(NULL), "must be a logical scalar")
    
    # Error cases
    expect_error(.must_be_logical_scalar(1), "must be a logical scalar")
    expect_error(.must_be_logical_scalar(c(TRUE, FALSE)), "must be a logical scalar")
    expect_error(.must_be_logical_scalar("TRUE"), "must be a logical scalar")
})


# Test .must_be_vector
test_that(".must_be_vector", {
    # Valid cases
    x <- 1:5
    names(x) <- letters[1:5]
    expect_no_error(.must_be_vector(x))
    expect_no_error(.must_be_vector(1L:5L))
    expect_no_error(.must_be_vector(1:5 / 3))
    expect_no_error(.must_be_vector(letters[1:5]))
    expect_no_error(.must_be_vector(c(TRUE, FALSE)))
    
    # null = TRUE cases
    expect_no_error(.must_be_vector(NULL, null = TRUE))
    expect_error(.must_be_vector(NULL), "must be a plain vector")
    
    # Error cases
    expect_error(.must_be_vector(list(a = 1)), "must be a plain vector")
    expect_error(.must_be_vector(matrix(0, nrow = 2, ncol = 2)), "must be a plain vector")
    expect_error(.must_be_vector(array(0, dim = c(1:3))), "must be a plain vector")
    expect_error(.must_be_vector(factor(letters[1:5])), "must be a plain vector")
    expect_error(.must_be_vector(structure(list(), class = "myclass")), "must be a plain vector")
    
    # Check error message format
    expect_error(.must_be_vector(list(a = 1)), "You've supplied a")
})


# Test .must_be_vector_or_factor
test_that(".must_be_vector_or_factor", {
    # Valid cases
    expect_no_error(.must_be_vector_or_factor(1:5))
    expect_no_error(.must_be_vector_or_factor(letters[1:5]))
    expect_no_error(.must_be_vector_or_factor(factor(letters[1:5])))
    
    # null = TRUE cases
    expect_no_error(.must_be_vector_or_factor(NULL, null = TRUE))
    expect_error(.must_be_vector_or_factor(NULL), "must be a plain vector or a factor")
    
    # Error cases
    expect_error(.must_be_vector_or_factor(list(a = 1)), "must be a plain vector or a factor")
    expect_error(.must_be_vector_or_factor(matrix(0, nrow = 2, ncol = 2)), "must be a plain vector or a factor")
})


# Test .must_be_integer_vector
test_that(".must_be_integer_vector", {
    # Valid cases
    expect_no_error(.must_be_integer_vector(1L:5L))
    expect_no_error(.must_be_integer_vector(integer(0)))
    
    # null = TRUE cases
    expect_no_error(.must_be_integer_vector(NULL, null = TRUE))
    expect_error(.must_be_integer_vector(NULL), "must be an integer vector")
    
    # Error cases
    expect_error(.must_be_integer_vector(1:5 / 3), "must be an integer vector")
    expect_error(.must_be_integer_vector(letters[1:5]), "must be an integer vector")
    expect_error(.must_be_integer_vector(c(1, 2)), "must be an integer vector")
})


# Test .must_be_integerish_vector
test_that(".must_be_integerish_vector", {
    # Valid cases
    expect_no_error(.must_be_integerish_vector(1L:5L))
    expect_no_error(.must_be_integerish_vector(c(1, 2, 3)))
    
    # null = TRUE cases
    expect_no_error(.must_be_integerish_vector(NULL, null = TRUE))
    expect_error(.must_be_integerish_vector(NULL), "must be an integerish vector")
    
    # Error cases
    expect_error(.must_be_integerish_vector(c(1.5, 2.5)), "must be an integerish vector")
    expect_error(.must_be_integerish_vector(letters[1:5]), "must be an integerish vector")
})


# Test .must_be_numeric_vector
test_that(".must_be_numeric_vector", {
    # Valid cases
    expect_no_error(.must_be_numeric_vector(1:5 / 3))
    expect_no_error(.must_be_numeric_vector(c(1.5, 2.5)))
    expect_no_error(.must_be_numeric_vector(1L:5L))
    
    # null = TRUE cases
    expect_no_error(.must_be_numeric_vector(NULL, null = TRUE))
    expect_error(.must_be_numeric_vector(NULL), "must be a numeric vector")
    
    # Error cases
    expect_error(.must_be_numeric_vector(letters[1:5]), "must be a numeric vector")
    expect_error(.must_be_numeric_vector(c(TRUE, FALSE)), "must be a numeric vector")
})


# Test .must_be_character_vector
test_that(".must_be_character_vector", {
    # Valid cases
    expect_no_error(.must_be_character_vector(letters[1:5]))
    expect_no_error(.must_be_character_vector(c("a", "b")))
    expect_no_error(.must_be_character_vector(character(0)))
    
    # null = TRUE cases
    expect_no_error(.must_be_character_vector(NULL, null = TRUE))
    expect_error(.must_be_character_vector(NULL), "must be a character vector")
    
    # Error cases
    expect_error(.must_be_character_vector(1:5), "must be a character vector")
    expect_error(.must_be_character_vector(c(TRUE, FALSE)), "must be a character vector")
})


# Test .must_be_factor
test_that(".must_be_factor", {
    # Valid cases
    expect_no_error(.must_be_factor(factor(letters[1:5])))
    expect_no_error(.must_be_factor(factor(c(1, 2, 3))))
    
    # null = TRUE cases
    expect_no_error(.must_be_factor(NULL, null = TRUE))
    expect_error(.must_be_factor(NULL), "must be a factor")
    
    # Error cases
    expect_error(.must_be_factor(letters[1:5]), "must be a factor")
    expect_error(.must_be_factor(1:5), "must be a factor")
})


# Test .must_be_matrix
test_that(".must_be_matrix", {
    # Valid cases
    expect_no_error(.must_be_matrix(matrix(0, nrow = 2, ncol = 2)))
    expect_no_error(.must_be_matrix(matrix(1:6, nrow = 2, ncol = 3)))
    
    # null = TRUE cases
    expect_no_error(.must_be_matrix(NULL, null = TRUE))
    expect_error(.must_be_matrix(NULL), "must be a matrix")
    
    # Error cases
    expect_error(.must_be_matrix(1:5), "must be a matrix")
    expect_error(.must_be_matrix(data.frame(a = 1:5)), "must be a matrix")
})


# Test .must_be_list
test_that(".must_be_list", {
    # Valid cases
    expect_no_error(.must_be_list(list(a = 1, b = 2)))
    expect_no_error(.must_be_list(list()))
    
    # null = TRUE cases
    expect_no_error(.must_be_list(NULL, null = TRUE))
    expect_error(.must_be_list(NULL), "must be a list")
    
    # Error cases
    expect_error(.must_be_list(1:5), "must be a list")
    expect_error(.must_be_list(c(TRUE, FALSE)), "must be a list")
})


# Test .must_be_data_frame
test_that(".must_be_data_frame", {
    # Valid cases
    expect_no_error(.must_be_data_frame(data.frame(a = 1:5)))
    expect_no_error(.must_be_data_frame(data.frame()))
    
    # null = TRUE cases
    expect_no_error(.must_be_data_frame(NULL, null = TRUE))
    expect_error(.must_be_data_frame(NULL), "must be a data frame")
    
    # Error cases
    expect_error(.must_be_data_frame(matrix(1:6, nrow = 2)), "must be a data frame")
    expect_error(.must_be_data_frame(list(a = 1:5)), "must be a data frame")
})


# Test .must_be_matrix_or_data_frame
test_that(".must_be_matrix_or_data_frame", {
    # Valid cases
    expect_no_error(.must_be_matrix_or_data_frame(matrix(0, nrow = 2, ncol = 2)))
    expect_no_error(.must_be_matrix_or_data_frame(data.frame(a = 1:5)))
    
    # null = TRUE cases
    expect_no_error(.must_be_matrix_or_data_frame(NULL, null = TRUE))
    expect_error(.must_be_matrix_or_data_frame(NULL), "must be a matrix or a data frame")
    
    # Error cases
    expect_error(.must_be_matrix_or_data_frame(1:5), "must be a matrix or a data frame")
    expect_error(.must_be_matrix_or_data_frame(list(a = 1)), "must be a matrix or a data frame")
})


# Test .must_be_list_of_logicals
test_that(".must_be_list_of_logicals", {
    # Valid cases
    expect_no_error(.must_be_list_of_logicals(list(c(TRUE, FALSE), c(FALSE, TRUE))))
    expect_no_error(.must_be_list_of_logicals(list(TRUE)))
    
    # null = TRUE cases
    expect_no_error(.must_be_list_of_logicals(NULL, null = TRUE))
    expect_error(.must_be_list_of_logicals(NULL), "must be a list")
    
    # null_elements = TRUE cases
    expect_no_error(.must_be_list_of_logicals(list(c(TRUE, FALSE), NULL), null_elements = TRUE))
    expect_error(.must_be_list_of_logicals(list(c(TRUE, FALSE), NULL)), "must be a list of logical vectors")
    
    # Error cases
    expect_error(.must_be_list_of_logicals(list(1, 2)), "must be a list of logical vectors")
    expect_error(.must_be_list_of_logicals(list(c(TRUE, FALSE), "a")), "Element 2 is a")
})


# Test .must_be_list_of_integerishes
test_that(".must_be_list_of_integerishes", {
    # Valid cases
    expect_no_error(.must_be_list_of_integerishes(list(1L:5L, 6L:10L)))
    expect_no_error(.must_be_list_of_integerishes(list(c(1, 2, 3))))
    
    # null = TRUE cases
    expect_no_error(.must_be_list_of_integerishes(NULL, null = TRUE))
    
    # null_elements = TRUE cases
    expect_no_error(.must_be_list_of_integerishes(list(1L:5L, NULL), null_elements = TRUE))
    expect_error(.must_be_list_of_integerishes(list(1L:5L, NULL)), "must be a list of integerish vectors")
    
    # Error cases
    expect_error(.must_be_list_of_integerishes(list(c(1.5, 2.5))), "must be a list of integerish vectors")
    expect_error(.must_be_list_of_integerishes(list(1L:5L, "a")), "Element 2 is a")
})


# Test .must_be_list_of_doubles
test_that(".must_be_list_of_doubles", {
    # Valid cases
    expect_no_error(.must_be_list_of_doubles(list(c(1.5, 2.5), c(3.5, 4.5))))
    expect_no_error(.must_be_list_of_doubles(list(c(1.0, 2.0))))
    
    # null = TRUE cases
    expect_no_error(.must_be_list_of_doubles(NULL, null = TRUE))
    
    # null_elements = TRUE cases
    expect_no_error(.must_be_list_of_doubles(list(c(1.5, 2.5), NULL), null_elements = TRUE))
    expect_error(.must_be_list_of_doubles(list(c(1.5, 2.5), NULL)), "must be a list of double")
    
    # Error cases
    expect_error(.must_be_list_of_doubles(list(1L:5L)), "must be a list of double")
    expect_error(.must_be_list_of_doubles(list(c(1.5, 2.5), "a")), "Element 2 is a")
})


# Test .must_be_list_of_numeric
test_that(".must_be_list_of_numeric", {
    # Valid cases
    expect_no_error(.must_be_list_of_numeric(list(c(1.5, 2.5), c(3, 4))))
    expect_no_error(.must_be_list_of_numeric(list(1L:5L)))
    
    # null = TRUE cases
    expect_no_error(.must_be_list_of_numeric(NULL, null = TRUE))
    
    # null_elements = TRUE cases
    expect_no_error(.must_be_list_of_numeric(list(c(1, 2), NULL), null_elements = TRUE))
    expect_error(.must_be_list_of_numeric(list(c(1, 2), NULL)), "must be a list of numeric vectors")
    
    # Error cases
    expect_error(.must_be_list_of_numeric(list(letters[1:5])), "must be a list of numeric vectors")
    expect_error(.must_be_list_of_numeric(list(c(1, 2), "a")), "Element 2 is a")
})


# Test .must_be_list_of_characters
test_that(".must_be_list_of_characters", {
    # Valid cases
    expect_no_error(.must_be_list_of_characters(list(letters[1:5], letters[6:10])))
    expect_no_error(.must_be_list_of_characters(list(c("a", "b"))))
    
    # null = TRUE cases
    expect_no_error(.must_be_list_of_characters(NULL, null = TRUE))
    
    # null_elements = TRUE cases
    expect_no_error(.must_be_list_of_characters(list(letters[1:5], NULL), null_elements = TRUE))
    expect_error(.must_be_list_of_characters(list(letters[1:5], NULL)), "must be a list of character vectors")
    
    # Error cases
    expect_error(.must_be_list_of_characters(list(1:5)), "must be a list of character vectors")
    expect_error(.must_be_list_of_characters(list(letters[1:5], 123)), "Element 2 is a")
})


# Test .must_be_list_of_functions
test_that(".must_be_list_of_functions", {
    # Valid cases
    f1 <- function(x) x + 1
    f2 <- function(y) y * 2
    expect_no_error(.must_be_list_of_functions(list(f1, f2)))
    expect_no_error(.must_be_list_of_functions(list(sum, mean)))
    
    # null = TRUE cases
    expect_no_error(.must_be_list_of_functions(NULL, null = TRUE))
    
    # null_elements = TRUE cases
    expect_no_error(.must_be_list_of_functions(list(f1, NULL), null_elements = TRUE))
    expect_error(.must_be_list_of_functions(list(f1, NULL)), "must be a list of functions")
    
    # Error cases
    expect_error(.must_be_list_of_functions(list(1, 2)), "must be a list of functions")
    expect_error(.must_be_list_of_functions(list(f1, "not a function")), "Element 2 is a")
})


# Test .must_be_finite
test_that(".must_be_finite", {
    # Valid cases
    expect_no_error(.must_be_finite(1:5))
    expect_no_error(.must_be_finite(c(1.5, 2.5)))
    
    # Error cases
    expect_error(.must_be_finite(Inf), "must be finite")
    expect_error(.must_be_finite(-Inf), "must be finite")
    expect_error(.must_be_finite(NaN), "must be finite")
    expect_error(.must_be_finite(c(1, 2, Inf)), "must be finite")
    
    # Check error message format
    expect_error(.must_be_finite(c(1, 2, Inf)), "Element 3 equals")
})


# Test .must_be_greater
test_that(".must_be_greater", {
    # Valid cases
    expect_no_error(.must_be_greater(5, 3))
    expect_no_error(.must_be_greater(c(5, 6, 7), 3))
    
    # Error cases
    expect_error(.must_be_greater(3, 5), "must be > 5")
    expect_error(.must_be_greater(5, 5), "must be > 5")
    expect_error(.must_be_greater(c(5, 2, 7), 3), "must be > 3")
    
    # Check error message format for single value
    expect_error(.must_be_greater(3, 5), "Value.*was provided")
    
    # Check error message format for multiple values
    expect_error(.must_be_greater(c(5, 2, 7), 3), "Element 2 equals")
})


# Test .must_be_greater_eq
test_that(".must_be_greater_eq", {
    # Valid cases
    expect_no_error(.must_be_greater_eq(5, 3))
    expect_no_error(.must_be_greater_eq(5, 5))
    expect_no_error(.must_be_greater_eq(c(5, 6, 7), 3))
    
    # Error cases
    expect_error(.must_be_greater_eq(3, 5), "must be >= 5")
    expect_error(.must_be_greater_eq(c(5, 2, 7), 3), "must be >= 3")
})


# Test .must_be_lower
test_that(".must_be_lower", {
    # Valid cases
    expect_no_error(.must_be_lower(3, 5))
    expect_no_error(.must_be_lower(c(1, 2, 3), 5))
    
    # Error cases
    expect_error(.must_be_lower(5, 3), "must be < 3")
    expect_error(.must_be_lower(5, 5), "must be < 5")
    expect_error(.must_be_lower(c(1, 6, 3), 5), "must be < 5")
})


# Test .must_be_lower_eq
test_that(".must_be_lower_eq", {
    # Valid cases
    expect_no_error(.must_be_lower_eq(3, 5))
    expect_no_error(.must_be_lower_eq(5, 5))
    expect_no_error(.must_be_lower_eq(c(1, 2, 3), 5))
    
    # Error cases
    expect_error(.must_be_lower_eq(6, 5), "must be <= 5")
    expect_error(.must_be_lower_eq(c(1, 6, 3), 5), "must be <= 5")
})


# Test .must_be_in_range
test_that(".must_be_in_range", {
    # Valid cases
    expect_no_error(.must_be_in_range(5, c(1, 10)))
    expect_no_error(.must_be_in_range(c(3, 5, 7), c(1, 10)))
    expect_no_error(.must_be_in_range(1, c(1, 10)))
    expect_no_error(.must_be_in_range(10, c(1, 10)))
    
    # Error cases
    expect_error(.must_be_in_range(0, c(1, 10)), "must be between")
    expect_error(.must_be_in_range(11, c(1, 10)), "must be between")
    expect_error(.must_be_in_range(c(3, 15, 7), c(1, 10)), "must be between")
})


# Test .must_be_null
test_that(".must_be_null", {
    # Valid cases
    expect_no_error(.must_be_null(NULL, when = "x is NULL"))
    
    # Error cases
    expect_error(.must_be_null(1, when = "x is NULL"), "can't be non-NULL when x is NULL")
    expect_error(.must_be_null("a", when = "x is NULL"), "can't be non-NULL when x is NULL")
    
    # Check error message format
    expect_error(.must_be_null(1, when = "x is NULL"), "You've supplied a")
})


# Test .must_not_be_null
test_that(".must_not_be_null", {
    # Valid cases
    expect_no_error(.must_not_be_null(1))
    expect_no_error(.must_not_be_null("a"))
    
    # Error cases
    expect_error(.must_not_be_null(NULL), "must not be NULL")
    expect_error(.must_not_be_null(NULL, when = "x > 0"), "can't be NULL when x > 0")
    
    # Check error message format
    expect_error(.must_not_be_null(NULL), "is NULL")
})


# Test .must_inherit
test_that(".must_inherit", {
    # Valid cases
    df <- data.frame(a = 1:5)
    expect_no_error(.must_inherit(df, "data.frame"))
    
    obj <- structure(list(x = 1), class = "myclass")
    expect_no_error(.must_inherit(obj, "myclass"))
    
    # null = TRUE cases
    expect_no_error(.must_inherit(NULL, "data.frame", null = TRUE))
    expect_error(.must_inherit(NULL, "data.frame"), "must be an S3 object")
    
    # Error cases
    expect_error(.must_inherit(1:5, "data.frame"), "must be an S3 object")
    expect_error(.must_inherit(df, "myclass"), "must be an S3 object")
    
    # Check error message format
    expect_error(.must_inherit(1:5, "data.frame"), "You've supplied a")
})


# Test .must_be_function
test_that(".must_be_function", {
    # Valid cases - basic function
    f1 <- function(x, y) x + y
    expect_no_error(.must_be_function(f1))
    
    # null = TRUE cases
    expect_no_error(.must_be_function(NULL, null = TRUE))
    expect_error(.must_be_function(NULL), "must be a function")
    
    # Test required arguments
    f2 <- function(a, b, c) a + b + c
    expect_no_error(.must_be_function(f2, required = c("a", "b")))
    expect_error(.must_be_function(f2, required = c("a", "d")), "The required argument.*d.*is missing")
    
    # Test optional arguments
    f3 <- function(x, y) x + y
    expect_no_error(.must_be_function(f3, required = c("x"), optional = c("y")))
    expect_error(.must_be_function(f3, required = c("x"), optional = c("z")), "Argument.*y.*isn't allowed")
    
    # Error cases
    expect_error(.must_be_function(1), "must be a function")
    expect_error(.must_be_function("not a function"), "must be a function")
})


# Test .must_be_enum
test_that(".must_be_enum", {
    # Valid cases
    expect_no_error(.must_be_enum("a", c("a", "b", "c")))
    expect_no_error(.must_be_enum("b", c("a", "b", "c")))
    
    # null = TRUE cases
    expect_no_error(.must_be_enum(NULL, c("a", "b", "c"), null = TRUE))
    expect_error(.must_be_enum(NULL, c("a", "b", "c")), "must be equal to one of")
    
    # multi = TRUE cases
    expect_no_error(.must_be_enum(c("a", "b"), c("a", "b", "c"), multi = TRUE))
    expect_error(.must_be_enum(c("a", "b"), c("a", "b", "c"), multi = FALSE), "must be equal to one of")
    expect_error(.must_be_enum(c("a", "d"), c("a", "b", "c"), multi = TRUE), "must be equal to any of")
    
    # Error cases
    expect_error(.must_be_enum("d", c("a", "b", "c")), "must be equal to one of")
    
    # Check error message format
    expect_error(.must_be_enum("d", c("a", "b", "c")), "You've supplied")
})


# Test .must_have_length
test_that(".must_have_length", {
    # Valid cases
    expect_no_error(.must_have_length(1:5, 5))
    expect_no_error(.must_have_length(c("a", "b", "c"), 3))
    
    # Error cases
    expect_error(.must_have_length(1:5, 3), "must have 3 elements")
    expect_error(.must_have_length(c("a", "b"), 5), "must have 5 elements")
    
    # Check error message format
    expect_error(.must_have_length(1:5, 3), "has 5 elements")
})


# Test .must_have_equal_lengths
test_that(".must_have_equal_lengths", {
    # Valid cases
    expect_no_error(.must_have_equal_lengths(1:5, 6:10))
    expect_no_error(.must_have_equal_lengths(c("a", "b"), c("c", "d")))
    
    # Error cases
    expect_error(.must_have_equal_lengths(1:5, 1:3), "must have the same number of elements")
    
    # Check error message format
    expect_error(.must_have_equal_lengths(1:5, 1:3), "has 5 elements")
    expect_error(.must_have_equal_lengths(1:5, 1:3), "has 3 elements")
})


# Test .must_be_list_of_equal_length_vectors
test_that(".must_be_list_of_equal_length_vectors", {
    # Valid cases
    expect_no_error(.must_be_list_of_equal_length_vectors(list(1:5, 6:10, 11:15)))
    expect_no_error(.must_be_list_of_equal_length_vectors(list(c("a", "b"), c("c", "d"))))
    expect_no_error(.must_be_list_of_equal_length_vectors(list()))  # empty list is ok
    
    # Error cases
    expect_error(.must_be_list_of_equal_length_vectors(list(1:5, 1:3)), "must be a list of vectors of equal length")
    
    # Check error message format
    expect_error(.must_be_list_of_equal_length_vectors(list(1:5, 1:3, 1:5)), "Element.*has length")
})


# Test .must_have_some_rows
test_that(".must_have_some_rows", {
    # Valid cases
    df <- data.frame(a = 1:5, b = 6:10)
    expect_no_error(.must_have_some_rows(df))
    
    m <- matrix(1:10, nrow = 5, ncol = 2)
    expect_no_error(.must_have_some_rows(m))
    
    # Error cases
    df_empty <- data.frame(a = integer(0), b = integer(0))
    expect_error(.must_have_some_rows(df_empty), "must have at least one row")
    
    m_empty <- matrix(numeric(0), nrow = 0, ncol = 2)
    expect_error(.must_have_some_rows(m_empty), "must have at least one row")
    
    # Check error message format
    expect_error(.must_have_some_rows(df_empty), "with 0 rows")
})


# Test .must_have_some_cols
test_that(".must_have_some_cols", {
    # Valid cases
    df <- data.frame(a = 1:5, b = 6:10)
    expect_no_error(.must_have_some_cols(df))
    
    m <- matrix(1:10, nrow = 5, ncol = 2)
    expect_no_error(.must_have_some_cols(m))
    
    # Error cases
    m_empty <- matrix(numeric(0), nrow = 5, ncol = 0)
    expect_error(.must_have_some_cols(m_empty), "must have at least one column")
    
    # Check error message format
    expect_error(.must_have_some_cols(m_empty), "with 0 columns")
})


# Test .must_have_column
test_that(".must_have_column", {
    # Valid cases
    df <- data.frame(a = 1:5, b = 6:10, c = letters[1:5])
    expect_no_error(.must_have_column(df, "a"))
    expect_no_error(.must_have_column(df, "b"))
    expect_no_error(.must_have_column(df, "c"))
    
    # Error cases
    expect_error(.must_have_column(df, "d"), "Column.*d.*must be present")
    
    # Check error message format
    expect_error(.must_have_column(df, "d"), "has the following columns")
})


# Test .must_have_character_column
test_that(".must_have_character_column", {
    # Valid cases
    df <- data.frame(a = 1:5, b = letters[1:5])
    expect_no_error(.must_have_character_column(df, "b"))
    
    # Error cases
    expect_error(.must_have_character_column(df, "a"), "must be a character vector")
    expect_error(.must_have_character_column(df, "c"), "must be present")
    
    # Check error message format
    expect_error(.must_have_character_column(df, "a"), "You've supplied a")
})


# Test .must_have_numeric_column
test_that(".must_have_numeric_column", {
    # Valid cases
    df <- data.frame(a = 1:5, b = letters[1:5])
    expect_no_error(.must_have_numeric_column(df, "a"))
    
    # Error cases
    expect_error(.must_have_numeric_column(df, "b"), "must be a numeric vector")
    expect_error(.must_have_numeric_column(df, "c"), "must be present")
    
    # Check error message format
    expect_error(.must_have_numeric_column(df, "b"), "You've supplied a")
})
