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
#include "xsimd/xsimd.hpp"


/**
 * Custom bitset implementation using vector of uint64_t.
 */
class Bitset {
private:
    uint64_t* blocks;
    size_t num_bits;
    size_t num_blocks;
    size_t count_true;

    static constexpr size_t BITS_PER_BLOCK = 64;

    // Get block index and bit position within block
    static inline size_t blockIndex(size_t pos) { return pos / BITS_PER_BLOCK; }
    static inline size_t bitIndex(size_t pos) { return pos % BITS_PER_BLOCK; }
    static inline uint64_t bitMask(size_t pos) { return uint64_t(1) << bitIndex(pos); }

    static inline size_t internalCount(int64_t value) {
        #if defined(__GNUC__) || defined(__clang__)
            return __builtin_popcountll(value);
        #elif defined(_MSC_VER) && defined(_M_X64)
            return __popcnt64(value);
        #else
            // Fallback: Efficient software implementation
            uint64_t v = static_cast<uint64_t>(value);
            v = v - ((v >> 1) & 0x5555555555555555ULL);
            v = (v & 0x3333333333333333ULL) + ((v >> 2) & 0x3333333333333333ULL);
            v = (v + (v >> 4)) & 0x0F0F0F0F0F0F0F0FULL;  // Slightly cleaner
            return (v * 0x0101010101010101ULL) >> 56;
        #endif
    }

public:
    Bitset()
        : blocks(nullptr),
          num_bits(0),
          num_blocks(0),
          count_true(0)
    {}

    explicit Bitset(size_t n)
        : blocks(nullptr),
          num_bits(n),
          num_blocks((n + BITS_PER_BLOCK - 1) / BITS_PER_BLOCK),
          count_true(0)
    {
        if (num_blocks > 0) {
            blocks = new uint64_t[num_blocks];
            for (size_t i = 0; i < num_blocks; ++i) {
                blocks[i] = 0;
            }
        }
    }

    // Disable copy
    Bitset(const Bitset& other) = delete;
    Bitset& operator=(const Bitset& other) = delete;

    // Move constructor
    Bitset(Bitset&& other) noexcept
        : blocks(other.blocks),
          num_bits(other.num_bits),
          num_blocks(other.num_blocks),
          count_true(other.count_true)
    {
        other.blocks = nullptr;
        other.num_blocks = 0;
        other.num_bits = 0;
        other.count_true = 0;
    }

    // Move assignment operator
    Bitset& operator=(Bitset&& other) noexcept
    {
        if (this != &other) {
            delete[] blocks;
            blocks = other.blocks;
            num_blocks = other.num_blocks;
            num_bits = other.num_bits;
            count_true = other.count_true;
            other.blocks = nullptr;
            other.num_blocks = 0;
            other.num_bits = 0;
            other.count_true = 0;
        }
        return *this;
    }

    ~Bitset()
    { if (blocks) delete[] blocks; }

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

    // Bitwise AND operation with SIMD optimization
    inline Bitset operator&(const Bitset& other) const
    {
        if (num_bits != other.num_bits) {
            throw std::invalid_argument("Bitset::operator&: incompatible sizes");
        }

        Bitset result;
        result.num_bits = num_bits;
        result.num_blocks = num_blocks;
        if (num_blocks > 0)
            result.blocks = new uint64_t[num_blocks];

#if !defined(XSIMD_NO_SUPPORTED_ARCHITECTURE)
        // Use SIMD acceleration when available
        using batch_type = xsimd::batch<uint64_t>;
        constexpr size_t simd_size = batch_type::size;
        
        // Process blocks in SIMD batches
        size_t i = 0;
        for (; i + simd_size <= num_blocks; i += simd_size) {
            batch_type a = batch_type::load_unaligned(&blocks[i]);
            batch_type b = batch_type::load_unaligned(&other.blocks[i]);
            batch_type c = a & b;
            c.store_unaligned(&result.blocks[i]);
            
            // Count set bits in the result batch
            for (size_t j = 0; j < simd_size; ++j) {
                result.count_true += internalCount(result.blocks[i + j]);
            }
        }
        
        // Process remaining blocks that don't fit in a SIMD batch
        for (; i < num_blocks; ++i) {
            int64_t value = blocks[i] & other.blocks[i];
            result.blocks[i] = value;
            result.count_true += internalCount(value);
        }
#else
        // Fallback for architectures without SIMD support
        for (size_t i = 0; i < num_blocks; ++i) {
            int64_t value = blocks[i] & other.blocks[i];
            result.blocks[i] = value;
            result.count_true += internalCount(value);
        }
#endif

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

        for (size_t i = 0; i < num_blocks; ++i) {
            if (blocks[i] != other.blocks[i]) {
                return false;
            }
        }

        return true;
    }

    inline size_t size() const
    { return num_bits; }

    inline bool empty() const
    { return num_bits == 0; }
};
