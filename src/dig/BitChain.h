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
#include <vector>
#include <cstdint>
#include <stdexcept>


/**
 * Custom bitset implementation using vector of uint64_t.
 */
class CustomBitset {
private:
    std::vector<uint64_t> blocks;
    size_t num_bits;
    size_t count_true;

    static constexpr size_t BITS_PER_BLOCK = 64;

    // Get block index and bit position within block
    static inline size_t blockIndex(size_t pos) { return pos / BITS_PER_BLOCK; }
    static inline size_t bitIndex(size_t pos) { return pos % BITS_PER_BLOCK; }
    static inline uint64_t bitMask(size_t pos) { return uint64_t(1) << bitIndex(pos); }

    static inline size_t internalCount(int64_t value) {
        #if defined(__GNUC__) || defined(__clang__)
            return __builtin_popcountll(value);
        #elif defined(_MSC_VER)
            return __popcnt64(value);
        #else
            // Fallback: Efficient software implementation
            uint64_t v = value;
            v = v - ((v >> 1) & 0x5555555555555555ULL);
            v = (v & 0x3333333333333333ULL) + ((v >> 2) & 0x3333333333333333ULL);
            return (((v + (v >> 4)) & 0xF0F0F0F0F0F0F0FULL) * 0x101010101010101ULL) >> 56;
        #endif
    }

public:
    CustomBitset()
        : num_bits(0),
          count_true(0)
    {}

    explicit CustomBitset(size_t n)
        : num_bits(n),
          count_true(0)
    {
        size_t num_blocks = (n + BITS_PER_BLOCK - 1) / BITS_PER_BLOCK;
        blocks.resize(num_blocks, 0);
    }

    // Disable copy
    CustomBitset(const CustomBitset& other) = delete;
    CustomBitset& operator=(const CustomBitset& other) = delete;

    // Allow move
    CustomBitset(CustomBitset&& other) = default;
    CustomBitset& operator=(CustomBitset&& other) = default;

    // Set bit at position pos to 1
    inline void set(size_t pos)
    {
        if (!this->operator[](pos)) {
            ++count_true;
        }
        blocks[blockIndex(pos)] |= bitMask(pos);
    }

    // Count number of set bits (popcount)
    // Uses compiler intrinsics for optimal performance
    inline size_t count() const
    { return count_true; }

    // Access bit at position (no bounds check)
    inline bool operator[](size_t pos) const
    { return (blocks[blockIndex(pos)] & bitMask(pos)) != 0; }

    // Access bit with bounds checking
    inline bool at(size_t pos) const
    {
        if (pos >= num_bits) {
            throw std::out_of_range("CustomBitset::at: position out of range");
        }

        return (*this)[pos];
    }

    // Bitwise AND operation
    inline CustomBitset operator&(const CustomBitset& other) const
    {
        if (blocks.size() != other.blocks.size()) {
            throw std::invalid_argument("CustomBitset::operator&: incompatible sizes");
        }

        CustomBitset result;
        result.num_bits = num_bits;
        result.blocks.reserve(blocks.size());

        for (size_t i = 0; i < blocks.size(); ++i) {
            int64_t value = blocks[i] & other.blocks[i];
            result.blocks.push_back(value);
            result.count_true += internalCount(value);
        }

        return result;
    }

    // Equality comparison
    inline bool operator==(const CustomBitset& other) const
    {
        if (num_bits != other.num_bits)
            return false;

        if (count_true != other.count_true) {
            return false;
        }

        return blocks == other.blocks;
    }

    inline size_t size() const
    { return num_bits; }

    inline bool empty() const
    { return num_bits == 0; }
};


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

    inline bool operator==(const BitChain& other) const
    { return BaseChain::operator==(other) && (data == other.data); }

    inline bool operator!=(const BitChain& other) const
    { return !(*this == other); }

    inline bool operator[](const size_t index) const
    { return data[index]; }

    inline bool at(const size_t index) const
    { return data.at(index); }

    inline size_t size() const
    { return data.size(); }

    inline bool empty() const
    { return data.empty(); }

    inline string toString() const
    {
        stringstream res;
        res << "[n=" << data.size() << "]";
        for (size_t i = 0; i < data.size(); ++i) {
            res << data[i];
        }

        return res.str();
    }

private:
    CustomBitset data;
};
