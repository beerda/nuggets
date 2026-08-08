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
 * The class uses a dynamic programming approach to compute and cache the values
 * of binomial coefficients in a 2D table. The table is initialized with
 * a maximum size (dimension) specified during construction, allowing for
 * efficient retrieval of previously computed values. The get() method provides
 * access to the binomial coefficient for given n and k, while ensuring that the
 * values are computed only once and stored for future use.
 */
class BinomialCoefficients {
public:
    /**
     * Constructor that initializes the class for computing binomial coefficients
     * with a given maximum size. The class can compute binomial coefficients
     * for n and k where 0 <= k <= n <= maxN.
     *
     * @param maxN Maximum size of the table (dimension).
     */
    BinomialCoefficients(size_t maxN)
        : dimension(maxN > 0 ? maxN : 1),
          table(new size_t[dimension * dimension])
    { std::fill_n(table, dimension * dimension, 0); }

    /**
     * Destructor that cleans up the allocated memory.
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
    inline size_t get(const size_t n, const size_t k) const
    {
        if (n > dimension)
            throw std::out_of_range("BinomialCoefficients::get: index out of range");

        if (n < k)
            return 0;

        return compute(n, k);
    }

private:
    /**
     * The dimension of the table, which is the maximum value of n for which
     * binomial coefficients can be computed.
     */
    size_t dimension;

    /**
     * A pointer to the dynamically allocated table that stores the computed
     * values of binomial coefficients. The table is initialized with zeros and
     * is used to cache the results of previously computed values for efficient
     * retrieval. The size of the table is dimension * dimension, allowing for
     * storage of all combinations of n and k up to the specified maximum size.
     *
     * The table is a 1D array that stores the computed values of C(n, k) in a
     * flattened 2D format, where the value for C(n, k) is stored at index
     * n * dimension + k.
     */
    size_t* table;

    /**
     * Returns a reference to the cached value of C(n, k) in the table.
     *
     * @param n The number of elements.
     * @param k The number of selected elements.
     * @return A reference to the cached value of C(n, k) in the table
     */
    inline size_t& lookup(const size_t n, const size_t k) const
    { return table[n * dimension + k]; }

    /**
     * Computes the binomial coefficient C(n, k) using a recursive approach with
     * memoization. The method checks if the value has already been computed and
     * stored in the table. If not, it computes the value recursively.
     *
     * @param n The number of elements.
     * @param k The number of selected elements.
     * @return The computed value of C(n, k).
     */
    inline size_t compute(const size_t n, const size_t k) const
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
