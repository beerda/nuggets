/**********************************************************************
 * nuggets: An R framework for exploration of patterns in data
 * Copyright (C) 2025 Michal Burda
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program. If not, see <https://www.gnu.org/licenses/>.
 **********************************************************************/


#pragma once


/**
 * A class for computing binomial coefficients C(n, k) = n! / (k! * (n - k)!).
 * This table is used to efficiently compute the number of combinations
 * for a given number of elements and levels in the combinatorial tree.
 */
class BinomialCoefficients {
public:
    /**
     * Constructor that initializes the table with a given maximum size.
     * The table can compute binomial coefficients for n and k
     * where 0 <= k <= n <= maxN.
     *
     * @param maxN Maximum size of the table (dimension).
     */
    BinomialCoefficients(size_t maxN)
        : dimension(maxN > 0 ? maxN : 1),
          table(new size_t[dimension * dimension])
    { std::fill_n(table, dimension * dimension, 0); }

    /**
     * Destructor that cleans up the allocated memory for the table.
     */
    ~BinomialCoefficients()
    { delete[] table; }

    /**
     * Returns the binomial coefficient C(n, k) for given n and k.
     * If n < k, it returns 0.
     * If n > dimension, it throws an out_of_range exception.
     *
     * @param n The number of elements.
     * @param k The number of selected elements.
     * @return The binomial coefficient C(n, k).
     */
    size_t get(size_t n, size_t k) const
    {
        if (n > dimension) {
            throw std::out_of_range("BinomialCoefficients::get: index out of range");
        }

        if (n < k) return 0;

        return compute(n, k);
    }

private:
    size_t dimension;
    size_t* table;

    size_t& lookup(size_t n, size_t k) const
    { return table[n * dimension + k]; }

    size_t compute(size_t n, size_t k) const
    {
        if (k == 0 || k == n)
            return 1;

        size_t& v1 = lookup(n - 1, k - 1);
        if (v1 == 0) {
            v1 = compute(n - 1, k - 1);
        }
        size_t& v2 = lookup(n - 1, k);
        if (v2 == 0) {
            v2 = compute(n - 1, k);
        }

        return v1 + v2;
    }
};
