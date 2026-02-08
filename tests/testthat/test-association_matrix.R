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


test_that("association_matrix basic functionality", {
    d <- data.frame(antecedent = c("{a,b}", "{a,c}", "{b,d}"),
                    consequent = c("{x}", "{x}", "{y}"),
                    support = c(0.5, 0.4, 0.3),
                    confidence = c(0.8, 0.7, 0.6),
                    lift = c(1.5, 1.4, 1.3))
    d <- nugget(d, "associations",
                call_function = "dig_associations",
                call_data = list(),
                call_args = list())

    mat <- association_matrix(d, confidence)
    expect_true(is.matrix(mat))
    expect_equal(rownames(mat), c("{a,b}", "{a,c}", "{b,d}"))
    expect_equal(colnames(mat), c("{x}", "{y}"))
})


test_that("association_matrix errors", {
    # Create a proper nugget for testing
    d <- data.frame(antecedent = c("{a,b}", "{a,c}"),
                    consequent = c("{x}", "{y}"),
                    support = c(0.5, 0.4),
                    confidence = c(0.8, 0.7),
                    lift = c(1.5, 1.4))
    d <- nugget(d, "associations",
                call_function = "dig_associations",
                call_data = list(),
                call_args = list())

    # Test non-nugget input
    expect_error(association_matrix(data.frame(a = 1:3), confidence),
                 "`x` must be a nugget")

    # Test missing antecedent column
    d_no_ante <- d
    d_no_ante$antecedent <- NULL
    expect_error(association_matrix(d_no_ante, confidence),
                 "Column `antecedent` must be present in `x`.")

    # Test missing consequent column
    d_no_cons <- d
    d_no_cons$consequent <- NULL
    expect_error(association_matrix(d_no_cons, confidence),
                 "Column `consequent` must be present in `x`.")

    # Test non-character antecedent column
    d_bad_ante <- d
    d_bad_ante$antecedent <- 1:nrow(d)
    expect_error(association_matrix(d_bad_ante, confidence),
                 "Column `antecedent` of `x` must be a character vector")

    # Test non-character consequent column
    d_bad_cons <- d
    d_bad_cons$consequent <- 1:nrow(d)
    expect_error(association_matrix(d_bad_cons, confidence),
                 "Column `consequent` of `x` must be a character vector")

    # Test empty value selection
    expect_error(association_matrix(d, starts_with("nonexistent")),
                 "`value` must select a single column")
    expect_error(association_matrix(d, starts_with("nonexistent")),
                 "`value` resulted in an empty list")

    # Test multiple value selection
    expect_error(association_matrix(d, c(confidence, lift)),
                 "`value` must select a single column")
    expect_error(association_matrix(d, c(confidence, lift)),
                 "`value` resulted in multiple columns")

    # Test non-numeric value column
    expect_error(association_matrix(d, antecedent),
                 "`value` must select a numeric column")

    # Test duplicate antecedent-consequent pairs
    d_dup <- rbind(d, d[1, ])
    expect_error(association_matrix(d_dup, confidence),
                 "Multiple values for the same cell in the association matrix")
    expect_error(association_matrix(d_dup, confidence),
                 "Pairs of `antecedent` and `consequent` must be unique")
})
