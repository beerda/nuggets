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

    static constexpr size_t BITS_PER_BLOCK = 64;

    // Get block index and bit position within block
    static inline size_t block_index(size_t pos) { return pos / BITS_PER_BLOCK; }
    static inline size_t bit_index(size_t pos) { return pos % BITS_PER_BLOCK; }
    static inline uint64_t bit_mask(size_t pos) { return uint64_t(1) << bit_index(pos); }

    // Mask off unused bits in the last block
    inline void sanitize()
    {
        if (num_bits > 0 && blocks.size() > 0) {
            size_t extra_bits = num_bits % BITS_PER_BLOCK;
            if (extra_bits > 0) {
                blocks.back() &= (uint64_t(1) << extra_bits) - 1;
            }
        }
    }

public:
    CustomBitset()
        : num_bits(0)
    {}

    explicit CustomBitset(size_t n)
        : num_bits(n)
    {
        size_t num_blocks = (n + BITS_PER_BLOCK - 1) / BITS_PER_BLOCK;
        blocks.resize(num_blocks, 0);
        sanitize();
    }

    // Set bit at position pos to 1
    inline void set(size_t pos)
    { blocks[block_index(pos)] |= bit_mask(pos); }

    // Count number of set bits (popcount)
    // Uses compiler intrinsics for optimal performance
    inline size_t count() const
    {
        size_t result = 0;
        for (uint64_t block : blocks) {
            #if defined(__GNUC__) || defined(__clang__)
                result += __builtin_popcountll(block);
            #elif defined(_MSC_VER)
                result += __popcnt64(block);
            #else
                // Fallback: Efficient software implementation
                uint64_t v = block;
                v = v - ((v >> 1) & 0x5555555555555555ULL);
                v = (v & 0x3333333333333333ULL) + ((v >> 2) & 0x3333333333333333ULL);
                result += (((v + (v >> 4)) & 0xF0F0F0F0F0F0F0FULL) * 0x101010101010101ULL) >> 56;
            #endif
        }
        return result;
    }

    // Access bit at position (no bounds check)
    inline bool operator[](size_t pos) const
    { return (blocks[block_index(pos)] & bit_mask(pos)) != 0; }

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
            result.blocks.push_back(blocks[i] & other.blocks[i]);
        }

        return result;
    }

    // Equality comparison
    inline bool operator==(const CustomBitset& other) const
    {
        if (num_bits != other.num_bits)
            return false;

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
