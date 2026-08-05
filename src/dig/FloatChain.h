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
#include <xsimd/xsimd.hpp>


/**
 * Implementation of a chain of floating-point membership degrees.
 * This class can be used as the CHAIN template parameter of Digger.
 * It stores a vector of floating-point values representing membership degrees
 * for a predicate or clause in the data. FloatChain may be constructed from
 * both LogicalVector or NumericVector.
 */
template <TNorm TNORM>
class FloatChain : public BaseChain {
public:
    /**
     * Default constructor that creates an empty chain of type CONDITION with
     * empty clause.
     *
     * @param sum The sum of membership degrees of the chain.
     */
    FloatChain(float sum)
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
    FloatChain(size_t id, PredicateType type, const LogicalVector& vec)
        : BaseChain(id, type, 0),
          data(vec.size(), 0.0)
    {
        for (R_xlen_t i = 0; i < vec.size(); i++) {
            if (vec[i]) {
                data[i] = 1.0;
                this->sum++;
            }
        }
    }

    /**
     * Constructor that creates a chain with the specified id, type and values.
     *
     * @param id The id of the predicate.
     * @param type The type of the predicate (where it may appear - in
     *     condition, focus, or in both positions).
     * @param vec The numeric membership degrees of the predicate.
     */
    FloatChain(size_t id, PredicateType type, const NumericVector& vec)
        : BaseChain(id, type, 0),
          data(vec.size())
    {
        for (R_xlen_t i = 0; i < vec.size(); i++) {
            data[i] = vec[i];
        }

        // Compute sum using SIMD
        this->sum = computeSum();
    }

    /**
     * Constructor that creates a chain by combining two chains with
     * a conjunction.
     *
     * @param a The first chain.
     * @param b The second chain.
     */
    FloatChain(const FloatChain& a, const FloatChain& b)
        : BaseChain(a, b),
          data(a.data.size())
    {
        IF_DEBUG(
            if (a.data.size() != b.data.size()) {
                throw std::invalid_argument("FloatChain: incompatible sizes");
            }
        )

#if !defined(XSIMD_NO_SUPPORTED_ARCHITECTURE)
        using batch_type = xsimd::batch<float>;
        constexpr size_t simd_size = batch_type::size;

        size_t i = 0;
        // Process in SIMD batches
        for (; i + simd_size <= a.data.size(); i += simd_size) {
            batch_type aa = batch_type::load_aligned(&a.data[i]);
            batch_type bb = batch_type::load_aligned(&b.data[i]);
            batch_type result;

            if constexpr (TNORM == TNorm::GOEDEL) {
                result = xsimd::min(aa, bb);
            } else if constexpr (TNORM == TNorm::LUKASIEWICZ) {
                batch_type zero = batch_type(0.0f);
                batch_type one = batch_type(1.0f);
                result = xsimd::max(aa + bb - one, zero);
            } else if constexpr (TNORM == TNorm::GOGUEN) {
                result = aa * bb;
            } else {
                static_assert(TNORM != TNorm::GOEDEL && TNORM != TNorm::GOGUEN && TNORM != TNorm::LUKASIEWICZ,
                              "Unsupported TNorm type");
            }

            result.store_aligned(&data[i]);
        }

        // Process remaining elements
        for (; i < a.data.size(); ++i) {
            if constexpr (TNORM == TNorm::GOEDEL) {
                data[i] = std::min(a.data[i], b.data[i]);
            } else if constexpr (TNORM == TNorm::LUKASIEWICZ) {
                data[i] = std::max(0.0f, a.data[i] + b.data[i] - 1.0f);
            } else if constexpr (TNORM == TNorm::GOGUEN) {
                data[i] = a.data[i] * b.data[i];
            }
        }
#else
        // Fallback for architectures without SIMD support
        for (size_t i = 0; i < a.data.size(); ++i) {
            if constexpr (TNORM == TNorm::GOEDEL) {
                data[i] = std::min(a.data[i], b.data[i]);
            } else if constexpr (TNORM == TNorm::LUKASIEWICZ) {
                data[i] = std::max(0.0f, a.data[i] + b.data[i] - 1.0f);
            } else if constexpr (TNORM == TNorm::GOGUEN) {
                data[i] = a.data[i] * b.data[i];
            } else {
                static_assert(TNORM != TNorm::GOEDEL && TNORM != TNorm::GOGUEN && TNORM != TNorm::LUKASIEWICZ,
                              "Unsupported TNorm type");
            }
        }
#endif

        // Compute sum using SIMD
        sum = computeSum();
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
    FloatChain(const FloatChain& a, const FloatChain& b, const double sum)
        : BaseChain(a, b, sum),
          data()
    { }

    // Disable copy
    FloatChain(const FloatChain& other) = delete;
    FloatChain& operator=(const FloatChain& other) = delete;

    // Allow move
    FloatChain(FloatChain&& other) = default;
    FloatChain& operator=(FloatChain&& other) = default;

    /**
     * Compares this chain with another chain for equality.
     *
     * @return TRUE if both chains contain the same metadata and values.
     */
    inline bool operator==(const FloatChain& other) const
    { return BaseChain::operator==(other) && (data == other.data); }

    /**
     * Compares this chain with another chain for inequality.
     *
     * @return TRUE if the chains differ.
     */
    inline bool operator!=(const FloatChain& other) const
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
     * Aligned storage of membership degrees.
     */
    AlignedVector<float> data;

    /**
     * Computes the sum of membership degrees using SIMD where available.
     *
     * @return The sum of membership degrees.
     */
    inline float computeSum() const
    {
#if !defined(XSIMD_NO_SUPPORTED_ARCHITECTURE)
        using batch_type = xsimd::batch<float>;
        constexpr size_t simd_size = batch_type::size;

        batch_type sum_vec = batch_type(0.0f);
        size_t i = 0;

        // Process in SIMD batches
        for (; i + simd_size <= data.size(); i += simd_size) {
            batch_type values = batch_type::load_aligned(&data[i]);
            sum_vec += values;
        }

        // Horizontal sum
        float result = xsimd::reduce_add(sum_vec);

        // Add remaining elements
        for (; i < data.size(); ++i) {
            result += data[i];
        }

        return result;
#else
        // Fallback for architectures without SIMD support
        float result = 0.0f;
        for (size_t i = 0; i < data.size(); ++i) {
            result += data[i];
        }
        return result;
#endif
    }
};
