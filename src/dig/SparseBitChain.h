/**********************************************************************
 * nuggets: An R framework for exploration of patterns in data
 * Copyright (C) 2026 Michal Burda
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

#include <algorithm>

#include "../common.h"
#include "BaseChain.h"

#define BITCHAIN_SPARSENESS_LIMIT (6)


/**
 * Implementation of sparse chain of bits. This class can be used as the CHAIN
 * template parameter of Digger.
 *
 * SparseBitChain stores only the indices of TRUE values in a sorted vector,
 * allowing for efficient storage and operations on sparse data. It is particularly
 * useful when the number of TRUE values is significantly smaller than the total
 * number of values in the chain. SparseBitChain may be constructed from LogicalVector
 * only.
 */
class SparseBitChain : public BaseChain {
public:
    /**
     * Default constructor that creates an empty chain of type CONDITION with
     * empty clause.
     *
     * @param sum The sum of TRUE values of the chain.
     */
    SparseBitChain(double sum)
        : BaseChain(sum),
          data(),
          n(0)
    { }

    /**
     * Constructor that creates a chain with the specified id, type and values.
     *
     * @param id The id of the predicate.
     * @param type The type of the predicate (where it may appear - in
     *     condition, focus, or in both positions).
     * @param vec The logical values of the predicate.
     */
    SparseBitChain(size_t id, PredicateType type, const LogicalVector& vec)
        : BaseChain(id, type, 0),
          data(),
          n(vec.size())
    {
        data.reserve(initialSize(n));
        for (size_t i = 0; i < n; ++i) {
            if (vec[i]) {
                data.push_back(i);
            }
        }
        this->sum = data.size();
    }

    /**
     * Constructor that creates a chain with the specified id, type and values.
     * SparseBitChain does not support construction from NumericVector, and this
     * constructor will throw an invalid_argument exception if called.
     *
     * @param id The id of the predicate.
     * @param type The type of the predicate (where it may appear - in
     *     condition, focus, or in both positions).
     * @param vec The numeric values of the predicate.
     */
    SparseBitChain(size_t id, PredicateType type, const NumericVector& vec)
        : BaseChain(id, type, 0),
          data(),
          n(vec.size())
    { throw std::invalid_argument("SparseBitChain: NumericVector constructor not implemented"); }

    /**
     * Constructor that creates a chain by combining two chains with
     * a conjunction.
     *
     * @param a The first chain.
     * @param b The second chain.
     */
    SparseBitChain(const SparseBitChain& a, const SparseBitChain& b)
        : BaseChain(a, b),
          data(),
          n(a.n)
    {
        data.reserve(std::min(a.data.size(), b.data.size()));

        auto i = a.data.begin();
        auto j = b.data.begin();

        while (i != a.data.end() && j != b.data.end()) {
            if (*i < *j) {
                ++i;
            }
            else if (*i > *j) {
                ++j;
            }
            else {
                data.push_back(*i);
                ++i; ++j;
            }
        }

        this->sum = data.size();
    }

    /**
     * Constructor that creates a chain by combining two chains with
     * a conjunction. This constructor is used when the sum is
     * already known and does not need to be computed from the conjunction of the
     * two chains. Therefore, the chain is marked as cached.
     *
     * @param a The first chain.
     * @param b The second chain.
     * @param sum The cached sum of TRUE values.
     */
    SparseBitChain(const SparseBitChain& a, const SparseBitChain& b, const double sum)
        : BaseChain(a, b, sum),
          data(),
          n(a.n)
    { }

    // Disable copy
    SparseBitChain(const SparseBitChain& other) = delete;
    SparseBitChain& operator=(const SparseBitChain& other) = delete;

    // Allow move
    SparseBitChain(SparseBitChain&& other) = default;
    SparseBitChain& operator=(SparseBitChain&& other) = default;

    /**
     * Compares this chain with another chain for equality.
     *
     * @return TRUE if both chains contain the same metadata and values.
     */
    inline bool operator==(const SparseBitChain& other) const
    { return BaseChain::operator==(other) && (data == other.data); }

    /**
     * Compares this chain with another chain for inequality.
     *
     * @return TRUE if the chains differ.
     */
    inline bool operator!=(const SparseBitChain& other) const
    { return !(*this == other); }

    /**
     * Returns whether a value is TRUE at the specified index without bounds
     * checking.
     *
     * @return TRUE if the value at the specified index is set.
     */
    inline bool operator[](const size_t index) const
    { return std::binary_search(data.begin(), data.end(), index); }

    /**
     * Returns whether a value is TRUE at the specified index.
     *
     * @return TRUE if the value at the specified index is set.
     */
    inline bool at(const size_t index) const
    { return std::binary_search(data.begin(), data.end(), index); }

    /**
     * Returns the number of values in the chain.
     *
     * @return The number of values in the chain.
     */
    inline size_t size() const
    { return n; }

    /**
     * Checks whether the chain has no values.
     *
     * @return TRUE if the chain is empty.
     */
    inline bool empty() const
    { return n <= 0; }

    /**
     * Returns a string representation of the chain.
     *
     * @return The string representation of the chain.
     */
    inline string toString() const
    {
        stringstream res;

        if (this->isCached()) {
            res << "[cached:" << this->getSum() << "]";
        }
        else {
            res << "[n=" << n << "]";
            for (size_t i = 0; i < n; ++i) {
                res << at(i);
            }
        }

        return res.str();
    }

private:
    /**
     * Sorted indices of values set to TRUE.
     */
    vector<size_t> data;

    /**
     * Total number of values represented by the chain.
     */
    size_t n;

    /**
     * Returns the initial capacity for sparse indices.
     *
     * @return The initial capacity for the specified number of rows.
     */
    static inline size_t initialSize(size_t nrow)
    { return std::max(nrow / BITCHAIN_SPARSENESS_LIMIT, (size_t) 8); }
};
