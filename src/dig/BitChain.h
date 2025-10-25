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

#include "../common.h"
#include "BaseChain.h"
#include <boost/dynamic_bitset.hpp>


/**
 * Implementation of chain of bits.
 */
class BitChain : public BaseChain {
public:
    BitChain(float sum)
        : BaseChain(sum)
    { }

    BitChain(size_t id, PredicateType type, const LogicalVector& vec)
        : BaseChain(id, type, 0),
          data(vec.size())
    {
        for (R_xlen_t i = 0; i < vec.size(); ++i) {
            if (vec[i]) {
                data.set(i);
                this->sum++;
            }
        }
    }

    BitChain(size_t id, PredicateType type, const NumericVector& vec)
        : BaseChain(id, type, 0),
          data(vec.size())
    { throw std::invalid_argument("BitChain: NumericVector constructor not implemented"); }

    BitChain(const BitChain& a, const BitChain& b, const bool toFocus)
        : BaseChain(a, b, toFocus),
          data(a.data & b.data)
    { sum = data.count(); }

    // Disable copy
    BitChain(const BitChain& other) = delete;
    BitChain& operator=(const BitChain& other) = delete;

    // Allow move
    BitChain(BitChain&& other) = default;
    BitChain& operator=(BitChain&& other) = default;

    bool operator==(const BitChain& other) const
    { return BaseChain::operator==(other) && (data == other.data); }

    bool operator!=(const BitChain& other) const
    { return !(*this == other); }

    bool operator[](size_t index) const
    { return data[index]; }

    bool at(size_t index) const
    { return data.at(index); }

    size_t size() const
    { return data.size(); }

    bool empty() const
    { return data.empty(); }

    string toString() const
    {
        stringstream res;
        res << "[n=" << data.size() << "]";
        for (size_t i = 0; i < data.size(); ++i) {
            res << data[i];
        }

        return res.str();
    }

private:
    boost::dynamic_bitset<> data;
};
