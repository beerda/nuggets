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

#include <immintrin.h>
#include "../common.h"
#include "../AlignedVector.h"
#include "BaseChain.h"


/**
 * Implementation of a SIMD-accelerated chain of membership degrees.
 *
 * This class can be used as the CHAIN template parameter of Digger.
 */
template <TNorm TNORM>
class SimdChain : public BaseChain {
public:
    /**
     * Number of floats that fit into an AVX SIMD register.
     */
    constexpr static size_t N_PACKED = 8;

    /**
     * Default constructor that creates an empty chain of type CONDITION with
     * empty clause.
     *
     * @param sum The sum of membership degrees of the chain.
     */
    SimdChain(float sum)
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
    SimdChain(size_t id, PredicateType type, const LogicalVector& vec)
        : BaseChain(id, type, 0),
          data(vec.size(), 0.0)
    {
        for (R_xlen_t i = 0; i < vec.size(); i++) {
            if (vec[i]) {
                data[i] = 1.0;
            }
        }

        setSum();
    }

    /**
     * Constructor that creates a chain with the specified id, type and values.
     *
     * @param id The id of the predicate.
     * @param type The type of the predicate (where it may appear - in
     *     condition, focus, or in both positions).
     * @param vec The numeric membership degrees of the predicate.
     */
    SimdChain(size_t id, PredicateType type, const NumericVector& vec)
        : BaseChain(id, type, 0),
          data(vec.size())
    {
        for (R_xlen_t i = 0; i < vec.size(); i++) {
            data[i] = vec[i];
        }

        setSum();
    }

    /**
     * Constructor that creates a chain by combining two chains with
     * a conjunction.
     *
     * @param a The first chain.
     * @param b The second chain.
     */
    SimdChain(const SimdChain& a, const SimdChain& b)
        : BaseChain(a, b),
          data(a.data.size())
    {
        IF_DEBUG(
            if (a.data.size() != b.data.size()) {
                throw std::invalid_argument("SimdChain: incompatible sizes");
            }
        )

        if constexpr (TNORM == TNorm::GOEDEL) {
            for (size_t i = 0; i < (a.data.size() / N_PACKED) * N_PACKED; i += N_PACKED) {
                __m256 aa = _mm256_load_ps(a.data.data() + i);
                __m256 bb = _mm256_load_ps(b.data.data() + i);
                __m256 res = _mm256_min_ps(aa, bb);
                _mm256_store_ps(this->data.data() + i, res);
            }

            for (size_t i = (a.data.size() / N_PACKED) * N_PACKED; i < a.data.size(); ++i) {
                this->data[i] = min(a.data[i], b.data[i]);
            }
        }
        else if constexpr (TNORM == TNorm::LUKASIEWICZ) {
            __m256 zero = _mm256_set1_ps(0.0);
            __m256 one = _mm256_set1_ps(1.0);

            for (size_t i = 0; i < (a.data.size() / N_PACKED) * N_PACKED; i += N_PACKED) {
                __m256 aa = _mm256_load_ps(a.data.data() + i);
                __m256 bb = _mm256_load_ps(b.data.data() + i);
                __m256 res = _mm256_add_ps(aa, bb);
                res = _mm256_sub_ps(res, one);
                res = _mm256_max_ps(res, zero);
                _mm256_store_ps(this->data.data() + i, res);
            }

            for (size_t i = (a.data.size() / N_PACKED) * N_PACKED; i < a.data.size(); ++i) {
                this->data[i] += a.data[i] + b.data[i] - 1.0;
                if (this->data[i] < 0.0)
                    this->data[i] = 0;
            }
        }
        else if constexpr (TNORM == TNorm::GOGUEN) {
            for (size_t i = 0; i < (a.data.size() / N_PACKED) * N_PACKED; i += N_PACKED) {
                __m256 aa = _mm256_load_ps(a.data.data() + i);
                __m256 bb = _mm256_load_ps(b.data.data() + i);
                __m256 res = _mm256_mul_ps(aa, bb);
                _mm256_store_ps(this->data.data() + i, res);
            }

            for (size_t i = (a.data.size() / N_PACKED) * N_PACKED; i < a.data.size(); ++i) {
                this->data[i] = a.data[i] * b.data[i];
            }
        }
        else {
            static_assert(TNORM != TNorm::GOEDEL && TNORM != TNorm::GOGUEN && TNORM != TNorm::LUKASIEWICZ,
                          "Unsupported TNorm type");
        }

        setSum();
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
    SimdChain(const SimdChain& a, const SimdChain& b, const double sum)
        : BaseChain(a, b, sum),
          data()
    { }

    // Disable copy
    SimdChain(const SimdChain& other) = delete;
    SimdChain& operator=(const SimdChain& other) = delete;

    // Allow move
    SimdChain(SimdChain&& other) = default;
    SimdChain& operator=(SimdChain&& other) = default;

    /**
     * Compares this chain with another chain for equality.
     *
     * @return TRUE if both chains contain the same metadata and values.
     */
    inline bool operator==(const SimdChain& other) const
    { return BaseChain::operator==(other) && (data == other.data); }

    /**
     * Compares this chain with another chain for inequality.
     *
     * @return TRUE if the chains differ.
     */
    inline bool operator!=(const SimdChain& other) const
    { return !(*this == other); }

    /**
     * Returns the membership degree at the specified index without bounds
     * checking.
     *
     * @return The membership degree at the specified index.
     */
    inline float operator[](const size_t index) const
    { return data[index]; }

    /**
     * Returns the membership degree at the specified index.
     *
     * @return The membership degree at the specified index.
     */
    inline float at(const size_t index) const
    { return data.at(index); }

    /**
     * Returns the number of values in the chain.
     *
     * @return The number of values in the chain.
     */
    inline size_t size() const
    { return data.size(); }

    /**
     * Checks whether the chain has no values.
     *
     * @return TRUE if the chain is empty.
     */
    inline bool empty() const
    { return data.empty(); }

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

private:
    /**
     * Aligned storage of membership degrees used by AVX operations.
     */
    AlignedVector<float> data;

    /**
     * Computes and stores the sum of membership degrees using AVX.
     */
    inline void setSum()
    {
        __m256 sumv = _mm256_set1_ps(0.0f);

        for (size_t i = 0; i < (data.size() / N_PACKED) * N_PACKED; i += N_PACKED) {
            __m256 d = _mm256_load_ps(data.data() + i);
            sumv = _mm256_add_ps(sumv, d);
        }

        const __m128 hiQuad = _mm256_extractf128_ps(sumv, 1);
        // loQuad = ( x3, x2, x1, x0 )
        const __m128 loQuad = _mm256_castps256_ps128(sumv);
        // sumQuad = ( x3 + x7, x2 + x6, x1 + x5, x0 + x4 )
        const __m128 sumQuad = _mm_add_ps(loQuad, hiQuad);
        // loDual = ( -, -, x1 + x5, x0 + x4 )
        const __m128 loDual = sumQuad;
        // hiDual = ( -, -, x3 + x7, x2 + x6 )
        const __m128 hiDual = _mm_movehl_ps(sumQuad, sumQuad);
        // sumDual = ( -, -, x1 + x3 + x5 + x7, x0 + x2 + x4 + x6 )
        const __m128 sumDual = _mm_add_ps(loDual, hiDual);
        // lo = ( -, -, -, x0 + x2 + x4 + x6 )
        const __m128 lo = sumDual;
        // hi = ( -, -, -, x1 + x3 + x5 + x7 )
        const __m128 hi = _mm_shuffle_ps(sumDual, sumDual, 0x1);
        // sum = ( -, -, -, x0 + x1 + x2 + x3 + x4 + x5 + x6 + x7 )
        const __m128 summ = _mm_add_ss(lo, hi);

        float res = _mm_cvtss_f32(summ);

        for (size_t i = (data.size() / N_PACKED) * N_PACKED; i < data.size(); ++i) {
            res += data.at(i);
        }

        this->sum = res;
    }
};
