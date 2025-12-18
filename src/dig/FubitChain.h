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
#include "xsimd/xsimd.hpp"
#include "BaseChain.h"


template <TNorm TNORM, unsigned int BLSIZE>
class FubitChain : public BaseChain {
public:
    using BASE_TYPE = uintmax_t;

    // number of bits in a single block
    constexpr static size_t BLOCK_SIZE = BLSIZE;

    // number of bits in the whole integer
    constexpr static size_t INTEGER_SIZE = 8 * sizeof(BASE_TYPE);

    // number of blocks in a single integer
    constexpr static size_t N_BLOCK = INTEGER_SIZE / BLOCK_SIZE;

    // maximum unsigned number to be stored in a value bits of a block
    // (the overflow bit (i.e. the hightest bit) must remain empty
    constexpr static BASE_TYPE MAX_VALUE = (((BASE_TYPE) 1) << (BLOCK_SIZE - 1)) - 1;

    // bit mask of the first block of bits within the integer
    constexpr static BASE_TYPE BLOCK_MASK = (((BASE_TYPE) 1) << BLOCK_SIZE) - 1;

    // bit mask of first two blocks of bits within the integer
    constexpr static BASE_TYPE DBL_BLOCK_MASK = (BLOCK_MASK << BLOCK_SIZE) | BLOCK_MASK;

    // half of the maximum number of additions of MAX_VALUE before it overflows DBL_BLOCK_MASK
    constexpr static BASE_TYPE STEP = DBL_BLOCK_MASK / MAX_VALUE / 2;

    static inline const float LOG_BASE = pow(1.0 * MAX_VALUE, (-1.0) / (MAX_VALUE - 1));

    static inline const BASE_TYPE OVERFLOW_MASK = []() {
        BASE_TYPE mask = 1 << (BLOCK_SIZE - 1);
        for (size_t j = 1; j * BLOCK_SIZE < INTEGER_SIZE; j <<= 1) {
            mask = mask + (mask << (j * BLOCK_SIZE));
        }
        return mask;
    }();

    static inline const BASE_TYPE NEG_OVERFLOW_MASK = ~OVERFLOW_MASK;

    static inline const BASE_TYPE ODD_BLOCK_MASK = []() {
        BASE_TYPE mask = BLOCK_MASK;
        for (size_t shift = 1; shift < INTEGER_SIZE / 2; shift += BLOCK_SIZE) {
            mask = (mask << (2 * BLOCK_SIZE)) + BLOCK_MASK;
        }
        return mask;
    }();

    FubitChain(float sum)
        : BaseChain(sum)
    { }

    FubitChain(size_t id, PredicateType type, const LogicalVector& vec)
        : BaseChain(id, type, 0),
          data(UNSIGNED_CEILING(vec.size() * BLOCK_SIZE, INTEGER_SIZE)),
          n(vec.size())
    {
        for (R_xlen_t i = 0; i < vec.size(); i++) {
            set(i, vec[i] ? 1.0 : 0.0);
        }

        setSum();
    }

    FubitChain(size_t id, PredicateType type, const NumericVector& vec)
        : BaseChain(id, type, 0),
          data(UNSIGNED_CEILING(vec.size() * BLOCK_SIZE, INTEGER_SIZE)),
          n(vec.size())
    {
        for (R_xlen_t i = 0; i < vec.size(); i++) {
            set(i, vec[i]);
        }

        setSum();
    }

    FubitChain(const FubitChain& a, const FubitChain& b, const bool toFocus)
        : BaseChain(a, b, toFocus),
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

        setSum();
    }

    // Disable copy
    FubitChain(const FubitChain& other) = delete;
    FubitChain& operator=(const FubitChain& other) = delete;

    // Allow move
    FubitChain(FubitChain&& other) = default;
    FubitChain& operator=(FubitChain&& other) = default;

    inline bool operator==(const FubitChain& other) const
    { return BaseChain::operator==(other) && (data == other.data); }

    inline bool operator!=(const FubitChain& other) const
    { return !(*this == other); }

    inline void set(const size_t index, const float value)
    {
        if constexpr (TNORM == TNorm::GOEDEL) {
            internalSet(index, (BASE_TYPE) (value * MAX_VALUE));
        }
        else if constexpr (TNORM == TNorm::LUKASIEWICZ) {
            internalSet(index, (BASE_TYPE) ((1.0 - value) * MAX_VALUE));
        }
        else if constexpr (TNORM == TNorm::GOGUEN) {
            static float reciprocal = 1.0 / MAX_VALUE;
            static float logLogBase = log(LOG_BASE);
            internalSet(index, (value <= reciprocal) ? this->MAX_VALUE : round(log(value) / logLogBase));
        }
        else {
            static_assert(TNORM != TNorm::GOEDEL && TNORM != TNorm::GOGUEN && TNORM != TNorm::LUKASIEWICZ,
                          "Unsupported TNorm type");
        }
    }

    inline float operator[](const size_t index) const
    {
        float res = 0;
        if constexpr (TNORM == TNorm::GOEDEL) {
            res = 1.0f * internalAt(index) / static_cast<float>(MAX_VALUE);
        }
        else if constexpr (TNORM == TNorm::LUKASIEWICZ) {
            res = 1.0f - 1.0f * internalAt(index) / static_cast<float>(MAX_VALUE);
        }
        else if constexpr (TNORM == TNorm::GOGUEN) {
            const BASE_TYPE val = internalAt(index);
            res = (val >= this->MAX_VALUE) ? 0.0f : pow(LOG_BASE, val);
        }
        else {
            static_assert(TNORM != TNorm::GOEDEL && TNORM != TNorm::GOGUEN && TNORM != TNorm::LUKASIEWICZ,
                          "Unsupported TNorm type");
        }

        return res;
    }

    inline float at(const size_t index) const
    {
        if (UNLIKELY(index >= n)) {
            throw std::out_of_range("FubitChain::at");
        }

        return operator[](index);
    }

    inline size_t size() const
    { return n; }

    inline bool empty() const
    { return n <= 0; }

    string toString() const
    {
        stringstream res;
        res << "[n=" << data.size() << "]";
        for (size_t i = 0; i < data.size(); ++i) {
            res << data[i];
        }

        return res.str();
    }

    void printBits(BASE_TYPE value) const
    {
        for (size_t i = 0; i < INTEGER_SIZE; ++i) {
            std::cout << ((value >> (INTEGER_SIZE - 1 - i)) & 1);
        }
        std::cout << std::endl;
    }

private:
    AlignedVector<BASE_TYPE> data;
    size_t n;

    inline void internalSet(const size_t pos, const BASE_TYPE value)
    {
        const size_t index = pos * BLOCK_SIZE / INTEGER_SIZE;
        const size_t shift = pos * BLOCK_SIZE % INTEGER_SIZE;
        data[index] |= value << shift;
        //cout << "FubitChain::internalSet: value=" << value << " index=" << index << ", shift=" << shift << ", data[index]=" << data[index] << endl;
    }

    inline BASE_TYPE internalAt(const size_t pos) const
    {
        const size_t index = pos * BLOCK_SIZE / INTEGER_SIZE;
        const size_t shift = pos * BLOCK_SIZE % INTEGER_SIZE;

        //cout << endl << "index: " << index << ", shift: " << shift << ", data: " << data[index] << endl;
        //cout << "chunkmask: " << BLOCK_MASK << ", result: " << ((data[index] >> shift) & BLOCK_MASK) << endl;
        return (data[index] >> shift) & BLOCK_MASK;
    }

    BASE_TYPE internalSum() const
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

    void setSum()
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
