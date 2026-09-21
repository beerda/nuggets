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

#include <bit>
#include <vector>
#include <cstdint>
#include <stdexcept>
#include <xsimd/xsimd.hpp>
#include "../timer.h"
#include "../libpopcnt.h"


/**
 * This class provides an efficient way to represent a set of bits, allowing for
 * operations such as setting bits, counting the number of set bits, and
 * performing bitwise AND operations with another Bitset.
 *
 * The implementation uses aligned memory allocation and SIMD instructions for
 * better performance.
 */
class Bitset {
private:
    static constexpr std::size_t bitsPerBlock = sizeof(uint64_t) * 8;

    /**
     * A pointer to the array of 64-bit blocks that store the bits.
     * The blocks are allocated using aligned memory allocation
     * to ensure optimal performance for SIMD operations.
     */
    uint64_t* blocks;

    /**
     * The total number of bits in the Bitset. This value is set during construction
     * and determines the size of the Bitset.
     *
     */
    size_t numBits;

    /**
     * The number of 64-bit blocks used to store the bits, i.e., the size of the
     * blocks array.
     */
    size_t numBlocks;

    /**
     * The number of bits stored in each block.
     */
    static constexpr size_t BITS_PER_BLOCK = 64;

    /**
     * Calculates the index of the block that contains the bit at the given position.
     *
     * @param pos The position of the bit for which to calculate the block index.
     * @return The index of the block that contains the requested bit.
     */
    static inline size_t blockIndex(size_t pos)
    { return pos / BITS_PER_BLOCK; }

    /**
     * Calculates the index of the bit within its block.
     *
     * @param pos The position of the bit for which to calculate the bit index.
     * @return The index of the bit within its block.
     */
    static inline size_t bitIndex(size_t pos)
    { return pos % BITS_PER_BLOCK; }

    /**
     * Calculates the bitmask for the bit at the given position.
     *
     * @param pos The position of the bit for which to calculate the bitmask.
     * @return The bitmask for the requested bit.
     */
    static inline uint64_t bitMask(size_t pos)
    { return uint64_t(1) << bitIndex(pos); }

public:
    /**
     * Constructs an empty Bitset with no bits set. The blocks pointer is initialized
     * to nullptr, and the number of bits, blocks, and count of true bits are all set to zero.
     */
    Bitset()
        : blocks(nullptr),
          numBits(0),
          numBlocks(0)
    { }

    /**
     * Constructs a Bitset with the specified number of bits, all initialized to
     * false (0). The blocks are allocated using aligned memory allocation, and
     * each block is initialized to zero.
     *
     * @param n The number of bits in the Bitset.
     */
    explicit Bitset(size_t n)
        : blocks(nullptr),
          numBits(n),
          numBlocks((n + BITS_PER_BLOCK - 1) / BITS_PER_BLOCK)
    {
        if (numBlocks > 0) {
            blocks = static_cast<uint64_t*>(
                xsimd::aligned_malloc(numBlocks * sizeof(uint64_t),
                                      xsimd::default_arch::alignment()));
            // Initialize all blocks to zero
            memset(blocks, 0, numBlocks * sizeof(uint64_t));
        }
    }

    // Copy constructor
    Bitset(const Bitset& other)
        : blocks(nullptr),
          numBits(other.numBits),
          numBlocks(other.numBlocks)
    {
        if (numBlocks > 0) {
            blocks = static_cast<uint64_t*>(
                xsimd::aligned_malloc(numBlocks * sizeof(uint64_t),
                                      xsimd::default_arch::alignment()));
            memcpy(blocks, other.blocks, numBlocks * sizeof(uint64_t));
        }
    }

    // Copy assignment operator
    Bitset& operator=(const Bitset& other)
    {
        if (this != &other) {
            if (blocks) {
                xsimd::aligned_free(blocks);
            }
            numBits = other.numBits;
            numBlocks = other.numBlocks;
            if (numBlocks > 0) {
                blocks = static_cast<uint64_t*>(
                    xsimd::aligned_malloc(numBlocks * sizeof(uint64_t),
                                          xsimd::default_arch::alignment()));
                memcpy(blocks, other.blocks, numBlocks * sizeof(uint64_t));
            } else {
                blocks = nullptr;
            }
        }

        return *this;
    }

    // Move constructor
    Bitset(Bitset&& other) noexcept
        : blocks(other.blocks),
          numBits(other.numBits),
          numBlocks(other.numBlocks)
    {
        other.blocks = nullptr;
        other.numBlocks = 0;
        other.numBits = 0;
    }

    // Move assignment operator
    Bitset& operator=(Bitset&& other) noexcept
    {
        if (this != &other) {
            if (blocks) {
                xsimd::aligned_free(blocks);
            }
            blocks = other.blocks;
            numBlocks = other.numBlocks;
            numBits = other.numBits;
            other.blocks = nullptr;
            other.numBlocks = 0;
            other.numBits = 0;
        }
        return *this;
    }

    /**
     * Destructor that frees the allocated memory for the blocks.
     */
    ~Bitset()
    {
        if (blocks) {
            xsimd::aligned_free(blocks);
        }
    }

    /**
     * Sets the bit at the specified position to true.
     *
     * @param pos The position of the bit to set. Must be less than numBits.
     */
    inline void set(size_t pos)
    {
        IF_DEBUG(
            if (pos >= numBits)
                throw std::out_of_range("Bitset::set: position out of range");
        )

        blocks[blockIndex(pos)] |= bitMask(pos);
    }

    /**
     * Returns the number of bits that are set to true in the Bitset.
     *
     * @return The count of bits set to true.
     */
    inline size_t count() const
    {
        BLOCK_INC_TIMER(st2, t2, "Bitset::count");

        return popcnt(blocks, numBlocks * sizeof(uint64_t));
    }

    /**
     * Returns the weighted count of bits that are set to true in the Bitset,
     * using the provided weights for each bit position.
     *
     * @param weights A vector of weights corresponding to each bit position.
     *                The size of the weights vector must match numBits.
     * @return The weighted count of bits set to true.
     * @throws std::invalid_argument if the size of weights does not match numBits.
     */
    inline double weightedCount(const std::vector<float>& weights) const
    {
        BLOCK_INC_TIMER(st2, t2, "Bitset::weightedCount");

        IF_DEBUG(
            if (weights.size() != numBits) {
                throw std::invalid_argument("Weights size must match Bitset size");
            }
        )

        double total = 0.0;
        for (size_t blockIndex = 0; blockIndex < numBlocks; ++blockIndex) {
            uint64_t word = blocks[blockIndex];
            while (word != 0) {
                // Count zero bits from the least significant bit
                size_t bitIndex = std::countr_zero(word);

                size_t weightIndex = blockIndex * bitsPerBlock + bitIndex;
                total += weights[weightIndex];

                // Clear the least significant set bit
                word &= word - 1;
            }
        }

        return total;
    }

    /**
     * Returns the value of the bit at the specified position.
     *
     * @param pos The position of the bit to check. Must be less than numBits.
     * @return True if the bit is set, false otherwise.
     */
    inline bool operator[](size_t pos) const
    {  return (blocks[blockIndex(pos)] & bitMask(pos)) != 0; }

    /**
     * Returns the value of the bit at the specified position, with bounds checking.
     *
     * @param pos The position of the bit to check. Must be less than numBits.
     * @return True if the bit is set, false otherwise.
     * @throws std::out_of_range if pos is greater than or equal to numBits.
     */
    inline bool at(size_t pos) const
    {
        if (pos >= numBits) {
            throw std::out_of_range("Bitset::at: position out of range");
        }

        return (*this)[pos];
    }

    /**
     * Performs a bitwise AND operation with another Bitset and returns the result
     * as a new Bitset. The two Bitsets must have the same number of bits.
     *
     * @param other The other Bitset to perform the AND operation with.
     * @return A new Bitset that is the result of the bitwise AND operation.
     * @throws std::invalid_argument if the two Bitsets have different sizes.
     */
    inline Bitset operator&(const Bitset& other) const
    {
        Bitset result;

        {
            BLOCK_INC_TIMER(st, t, "Bitset::operator&");

            if (numBits != other.numBits) {
                throw std::invalid_argument("Bitset::operator&: incompatible sizes");
            }

            result.numBits = numBits;
            result.numBlocks = numBlocks;
            if (numBlocks > 0) {
                result.blocks = static_cast<uint64_t*>(
                    xsimd::aligned_malloc(numBlocks * sizeof(uint64_t),
                                          xsimd::default_arch::alignment()));
            }

#if !defined(XSIMD_NO_SUPPORTED_ARCHITECTURE)
            // Use SIMD acceleration when available
            using batch_type = xsimd::batch<uint64_t>;
            constexpr size_t simd_size = batch_type::size;

            // Process blocks in SIMD batches using aligned operations
            size_t i = 0;
            for (; i + simd_size <= numBlocks; i += simd_size) {
                batch_type a = batch_type::load_aligned(&blocks[i]);
                batch_type b = batch_type::load_aligned(&other.blocks[i]);
                batch_type c = a & b;
                c.store_aligned(&result.blocks[i]);
            }

            // Process remaining blocks that don't fit in a SIMD batch
            for (; i < numBlocks; ++i) {
                uint64_t value = blocks[i] & other.blocks[i];
                result.blocks[i] = value;
            }
#else
            // Fallback for architectures without SIMD support
            for (size_t i = 0; i < numBlocks; ++i) {
                uint64_t value = blocks[i] & other.blocks[i];
                result.blocks[i] = value;
            }
#endif
        }

        return result;
    }

    /**
     * Compares this Bitset with another Bitset for equality. Two Bitsets are
     * considered equal if they have the same number of bits, the same number of
     * true bits, and the same values in all corresponding blocks.
     *
     * @param other The other Bitset to compare with.
     * @return True if the two Bitsets are equal, false otherwise.
     */
    inline bool operator==(const Bitset& other) const
    {
        if (numBits != other.numBits)
            return false;

        for (size_t i = 0; i < numBlocks; ++i) {
            if (blocks[i] != other.blocks[i]) {
                return false;
            }
        }

        return true;
    }

    /**
     * Returns the total number of bits in the Bitset.
     *
     * @return The total number of bits in the Bitset.
     */
    inline size_t size() const
    { return numBits; }

    /**
     * Checks if the Bitset is empty, i.e., has no bits set to true.
     *
     * @return True if the Bitset is empty, false otherwise.
     */
    inline bool empty() const
    { return numBits == 0; }
};
