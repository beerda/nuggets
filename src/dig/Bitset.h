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

#include <vector>
#include <cstdint>
#include <stdexcept>


/**
 * Custom bitset implementation using vector of uint64_t.
 */
class Bitset {
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
    Bitset()
        : num_bits(0),
          count_true(0)
    {}

    explicit Bitset(size_t n)
        : num_bits(n),
          count_true(0)
    {
        size_t num_blocks = (n + BITS_PER_BLOCK - 1) / BITS_PER_BLOCK;
        blocks.resize(num_blocks, 0);
    }

    // Disable copy
    Bitset(const Bitset& other) = delete;
    Bitset& operator=(const Bitset& other) = delete;

    // Allow move
    Bitset(Bitset&& other) = default;
    Bitset& operator=(Bitset&& other) = default;

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
            throw std::out_of_range("Bitset::at: position out of range");
        }

        return (*this)[pos];
    }

    // Bitwise AND operation
    inline Bitset operator&(const Bitset& other) const
    {
        if (blocks.size() != other.blocks.size()) {
            throw std::invalid_argument("Bitset::operator&: incompatible sizes");
        }

        Bitset result;
        result.num_bits = num_bits;
        result.blocks.resize(blocks.size());

        for (size_t i = 0; i < blocks.size(); ++i) {
            int64_t value = blocks[i] & other.blocks[i];
            result.blocks[i] = value;
            result.count_true += internalCount(value);
        }

        return result;
    }

    // Equality comparison
    inline bool operator==(const Bitset& other) const
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
