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
#include "../AlignedVector.h"
#include "BaseChain.h"


/**
 * Implementation of fast fixed-bit chain of fuzzy membership degrees. The class
 * stores membership degrees in a compact representation using fixed-bit integers,
 * allowing for efficient batch computation of conjunctions of fuzzy values.
 * This class can be used as the CHAIN template parameter of Digger.
 *
 * See https://doi.org/10.1016/j.asoc.2026.114661 for details.
 */
template <TNorm TNORM, unsigned int BLSIZE>
class FubitChain : public BaseChain {
public:
    /**
     * Integer type used to pack fixed-bit membership degrees.
     */
    using BASE_TYPE = uintmax_t;

    /**
     * Number of bits in a single block.
     */
    constexpr static size_t BLOCK_SIZE = BLSIZE;

    /**
     * Number of bits in the underlying integer.
     */
    constexpr static size_t INTEGER_SIZE = 8 * sizeof(BASE_TYPE);

    /**
     * Number of blocks in a single underlying integer.
     */
    constexpr static size_t N_BLOCK = INTEGER_SIZE / BLOCK_SIZE;

    /**
     * Maximum value stored in a block, leaving its highest bit for overflow.
     */
    constexpr static BASE_TYPE MAX_VALUE = (((BASE_TYPE) 1) << (BLOCK_SIZE - 1)) - 1;

    /**
     * Bit mask of the first block within an integer.
     */
    constexpr static BASE_TYPE BLOCK_MASK = (((BASE_TYPE) 1) << BLOCK_SIZE) - 1;

    /**
     * Bit mask of the first two blocks within an integer.
     */
    constexpr static BASE_TYPE DBL_BLOCK_MASK = (BLOCK_MASK << BLOCK_SIZE) | BLOCK_MASK;

    /**
     * Step size used to compute sum of bits
     */
    constexpr static BASE_TYPE STEP = DBL_BLOCK_MASK / MAX_VALUE / 2;

    /**
     * Base used to encode Goguen t-norm membership degrees logarithmically.
     */
    static inline const float LOG_BASE = pow(1.0 * MAX_VALUE, (-1.0) / (MAX_VALUE - 1));

    /**
     * Mask selecting the overflow bit of every block.
     */
    static inline const BASE_TYPE OVERFLOW_MASK = []() {
        BASE_TYPE mask = 1 << (BLOCK_SIZE - 1);
        for (size_t j = 1; j * BLOCK_SIZE < INTEGER_SIZE; j <<= 1) {
            mask = mask + (mask << (j * BLOCK_SIZE));
        }
        return mask;
    }();

    /**
     * Mask clearing the overflow bit of every block.
     */
    static inline const BASE_TYPE NEG_OVERFLOW_MASK = ~OVERFLOW_MASK;

    /**
     * Mask selecting alternating blocks within an integer.
     */
    static inline const BASE_TYPE ODD_BLOCK_MASK = []() {
        BASE_TYPE mask = BLOCK_MASK;
        for (size_t shift = 1; shift < INTEGER_SIZE / 2; shift += BLOCK_SIZE) {
            mask = (mask << (2 * BLOCK_SIZE)) + BLOCK_MASK;
        }
        return mask;
    }();

    /**
     * Default constructor that creates an empty chain of type CONDITION with
     * empty clause.
     *
     * @param sum The sum of membership degrees of the chain.
     */
    FubitChain(float sum)
        : BaseChain(sum)
    { }

    /**
     * Constructor that creates a chain with the specified id, type and values.
     *
     * @param id The id of the predicate.
     * @param type The type of the predicate (where it may appear - in
     *     condition, focus, or in both positions).
     * @param vec The logical values of the predicate.
     */
    FubitChain(size_t id, PredicateType type, const LogicalVector& vec)
        : BaseChain(id, type, 0),
          data(UNSIGNED_CEILING(vec.size() * BLOCK_SIZE, INTEGER_SIZE)),
          n(vec.size())
    {
        for (R_xlen_t i = 0; i < vec.size(); i++) {
            set(i, vec[i] ? 1.0 : 0.0);
        }

        internalSetSum();
    }

    /**
     * Constructor that creates a chain with the specified id, type and values.
     *
     * @param id The id of the predicate.
     * @param type The type of the predicate (where it may appear - in
     *     condition, focus, or in both positions).
     * @param vec The numeric membership degrees of the predicate.
     */
    FubitChain(size_t id, PredicateType type, const NumericVector& vec)
        : BaseChain(id, type, 0),
          data(UNSIGNED_CEILING(vec.size() * BLOCK_SIZE, INTEGER_SIZE)),
          n(vec.size())
    {
        for (R_xlen_t i = 0; i < vec.size(); i++) {
            set(i, vec[i]);
        }

        internalSetSum();
    }

    /**
     * Constructor that creates a chain by combining two chains with
     * a conjunction.
     *
     * @param a The first chain.
     * @param b The second chain.
     */
    FubitChain(const FubitChain& a, const FubitChain& b)
        : BaseChain(a, b),
          data(a.data.size()),
          n(a.n)
    {
        IF_DEBUG(
            if (a.size() != b.size()) {
                throw std::invalid_argument("FubitChain: incompatible sizes");
            }
        )

        const BASE_TYPE* aa = a.data.data();
        const BASE_TYPE* bb = b.data.data();

        for (size_t i = 0; i < a.data.size(); ++i) {
            if constexpr (TNORM == TNorm::GOEDEL) {
                BASE_TYPE s = internalCloneBits(aa[i] - bb[i]);
                data[i] = (aa[i] & s) | (bb[i] & ~s);
            }
            else if constexpr (TNORM == TNorm::LUKASIEWICZ) {
                BASE_TYPE bitsum = aa[i] + bb[i];
                BASE_TYPE s = internalCloneBits(bitsum);
                data[i] = (bitsum | s) & NEG_OVERFLOW_MASK;
            }
            else if constexpr (TNORM == TNorm::GOGUEN) {
                BASE_TYPE bitsum = (aa[i] + bb[i]);
                BASE_TYPE s = internalCloneBits(bitsum);
                data[i] = (bitsum | s) & NEG_OVERFLOW_MASK;
            }
            else {
                static_assert(TNORM != TNorm::GOEDEL && TNORM != TNorm::GOGUEN && TNORM != TNorm::LUKASIEWICZ,
                              "Unsupported TNorm type");
            }
        }

        internalSetSum();
    }

    /**
     * Constructor that creates a chain by combining two chains with
     * a conjunction. This constructor is used when the sum is
     * already known and does not need to be computed from the conjunction of the
     * two chains. Therefore, the chain is marked as cached.
     *
     * @param a The first chain.
     * @param b The second chain.
     * @param sum The cached sum of membership degrees.
     */
    FubitChain(const FubitChain& a, const FubitChain& b, const double sum)
        : BaseChain(a, b, sum),
          data(),
          n(a.n)
    { }

    // Disable copy
    FubitChain(const FubitChain& other) = delete;
    FubitChain& operator=(const FubitChain& other) = delete;

    // Allow move
    FubitChain(FubitChain&& other) = default;
    FubitChain& operator=(FubitChain&& other) = default;

    /**
     * Compares this chain with another chain for equality.
     *
     * @return TRUE if both chains contain the same metadata and values.
     */
    inline bool operator==(const FubitChain& other) const
    { return BaseChain::operator==(other) && (data == other.data); }

    /**
     * Compares this chain with another chain for inequality.
     *
     * @return TRUE if the chains differ.
     */
    inline bool operator!=(const FubitChain& other) const
    { return !(*this == other); }

    /**
     * Stores a membership degree at the specified index.
     *
     * @param index The index to update.
     * @param value The membership degree to store.
     */
    inline void set(const size_t index, const float value)
    {
        if constexpr (TNORM == TNorm::GOEDEL) {
            internalSet(index, (BASE_TYPE) llroundf(value * MAX_VALUE));
        }
        else if constexpr (TNORM == TNorm::LUKASIEWICZ) {
            internalSet(index, (BASE_TYPE) llroundf((1.0 - value) * MAX_VALUE));
        }
        else if constexpr (TNORM == TNorm::GOGUEN) {
            static float reciprocal = 1.0 / MAX_VALUE;
            static float logLogBase = log(LOG_BASE);
            internalSet(index, (value <= reciprocal) ? this->MAX_VALUE : llroundf(log(value) / logLogBase));
        }
        else {
            static_assert(TNORM != TNorm::GOEDEL && TNORM != TNorm::GOGUEN && TNORM != TNorm::LUKASIEWICZ,
                          "Unsupported TNorm type");
        }
    }

    /**
     * Returns the membership degree at the specified index without bounds
     * checking.
     *
     * @return The membership degree at the specified index.
     */
    inline float operator[](const size_t index) const
    {
        float res = 0;
        if constexpr (TNORM == TNorm::GOEDEL) {
            res = 1.0 * internalAt(index) / ((float) MAX_VALUE);
        }
        else if constexpr (TNORM == TNorm::LUKASIEWICZ) {
            res = 1.0 - 1.0 * internalAt(index) / ((float) MAX_VALUE);
        }
        else if constexpr (TNORM == TNorm::GOGUEN) {
            BASE_TYPE val = internalAt(index);
            res = (val >= this->MAX_VALUE) ? 0.0 : pow(LOG_BASE, val);
        }
        else {
            static_assert(TNORM != TNorm::GOEDEL && TNORM != TNorm::GOGUEN && TNORM != TNorm::LUKASIEWICZ,
                          "Unsupported TNorm type");
        }

        return res;
    }

    /**
     * Returns the membership degree at the specified index.
     *
     * @return The membership degree at the specified index.
     */
    inline float at(const size_t index) const
    {
        if (index >= n) {
            throw std::out_of_range("FubitChain::at");
        }

        return operator[](index);
    }

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
        res << "[n=" << data.size() << "]";
        for (size_t i = 0; i < data.size(); ++i) {
            res << data[i];
        }

        return res.str();
    }

    /**
     * Writes the bits of a packed value to standard output.
     *
     * @param value The packed value to print.
     */
    inline void printBits(const BASE_TYPE value) const
    {
        for (size_t i = 0; i < INTEGER_SIZE; ++i) {
            std::cout << ((value >> (INTEGER_SIZE - 1 - i)) & 1);
        }
        std::cout << std::endl;
    }

private:
    /**
     * Packed fixed-bit membership degrees.
     */
    AlignedVector<BASE_TYPE> data;

    /**
     * Number of membership degrees stored in the chain.
     */
    size_t n;

    /**
     * Stores a packed value at an index.
     *
     * @param pos The value index.
     * @param value The packed value to store.
     */
    inline void internalSet(const size_t pos, const BASE_TYPE value)
    {
        size_t index = pos * BLOCK_SIZE / INTEGER_SIZE;
        size_t shift = pos * BLOCK_SIZE % INTEGER_SIZE;
        data[index] |= value << shift;
        //cout << "FubitChain::internalSet: value=" << value << " index=" << index << ", shift=" << shift << ", data[index]=" << data[index] << endl;
    }

    /**
     * Returns the packed value at an index.
     *
     * @return The packed value at the specified index.
     */
    inline BASE_TYPE internalAt(const size_t pos) const
    {
        size_t index = pos * BLOCK_SIZE / INTEGER_SIZE;
        size_t shift = pos * BLOCK_SIZE % INTEGER_SIZE;

        //cout << endl << "index: " << index << ", shift: " << shift << ", data: " << data[index] << endl;
        //cout << "chunkmask: " << BLOCK_MASK << ", result: " << ((data[index] >> shift) & BLOCK_MASK) << endl;
        return (data[index] >> shift) & BLOCK_MASK;
    }

    /**
     * Computes the sum of packed values.
     *
     * @return The sum of packed values.
     */
    inline BASE_TYPE internalSum() const
    {
        BASE_TYPE result = 0;
        size_t index = 0;

        while (index < data.size()) {
            BASE_TYPE tempsum = 0;
            size_t border = std::min(index + STEP, data.size());

            for (; index < border; ++index) {
                BASE_TYPE val = data.at(index);
                tempsum += (val & ODD_BLOCK_MASK) + ((val >> BLOCK_SIZE) & ODD_BLOCK_MASK);
            }
            for (size_t shift = 0; shift < INTEGER_SIZE; shift += 2 * BLOCK_SIZE) {
                result += (tempsum >> shift) & DBL_BLOCK_MASK;
            }
        }

        return result;
    }

    /**
     * Propagates overflow bits throughout their respective blocks.
     *
     * @return A mask with each overflow bit propagated through its block.
     */
    inline BASE_TYPE internalCloneBits(const BASE_TYPE value) const
    {
        BASE_TYPE res = value & OVERFLOW_MASK;

        if constexpr (BLSIZE == 4) {
            res = res | (res >> 1);
            res = res | (res >> 2);
        }
        else if constexpr (BLSIZE == 8) {
            res = res | (res >> 1);
            res = res | (res >> 2);
            res = res | (res >> 4);
        }
        else if constexpr (BLSIZE == 16) {
            res = res | (res >> 1);
            res = res | (res >> 2);
            res = res | (res >> 4);
            res = res | (res >> 8);
        }
        else {
            static_assert(BLSIZE != 4 && BLSIZE != 8 && BLSIZE != 16, "Unsupported BLSIZE");
        }

        return res;
    }

    /**
     * Computes and stores the sum of membership degrees.
     */
    inline void internalSetSum()
    {
        if constexpr (TNORM == TNorm::GOEDEL) {
            this->sum = ((float) internalSum()) / ((float) MAX_VALUE);
        }
        else if constexpr (TNORM == TNorm::LUKASIEWICZ) {
            this->sum = n - ((float) internalSum()) / ((float) MAX_VALUE);
        }
        else if constexpr (TNORM == TNorm::GOGUEN) {
            this->sum = 0;
            for (size_t i = 0; i < n; ++i)
                this->sum += operator[](i);
        }
        else {
            static_assert(TNORM != TNorm::GOEDEL && TNORM != TNorm::GOGUEN && TNORM != TNorm::LUKASIEWICZ,
                          "Unsupported TNorm type");
        }
    }
};
