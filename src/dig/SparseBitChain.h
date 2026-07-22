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
 * Implementation of sparse chain of bits.
 */
class SparseBitChain : public BaseChain {
public:
    SparseBitChain(double sum)
        : BaseChain(sum),
          data(),
          n(0)
    { }

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

    SparseBitChain(size_t id, PredicateType type, const NumericVector& vec)
        : BaseChain(id, type, 0),
          data(),
          n(vec.size())
    { throw std::invalid_argument("SparseBitChain: NumericVector constructor not implemented"); }

    SparseBitChain(const SparseBitChain& a, const SparseBitChain& b)
        : BaseChain(a, b),
          data(),
          n(a.n)
    {
        data.reserve(std::min(a.data.size(), b.data.size()));
        std::set_intersection(a.data.begin(), a.data.end(),
                              b.data.begin(), b.data.end(),
                              std::back_inserter(data));
        this->sum = data.size();
    }

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

    inline bool operator==(const SparseBitChain& other) const
    { return BaseChain::operator==(other) && (data == other.data); }

    inline bool operator!=(const SparseBitChain& other) const
    { return !(*this == other); }

    inline bool operator[](const size_t index) const
    { return std::binary_search(data.begin(), data.end(), index); }

    inline bool at(const size_t index) const
    { return std::binary_search(data.begin(), data.end(), index); }

    inline size_t size() const
    { return n; }

    inline bool empty() const
    { return n <= 0; }

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
    vector<size_t> data;
    size_t n;

    static inline size_t initialSize(size_t nrow)
    { return std::max(nrow / BITCHAIN_SPARSENESS_LIMIT, (size_t) 8); }
};
