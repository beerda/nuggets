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


template <TNorm TNORM>
class FloatChain : public BaseChain {
public:
    FloatChain(float sum)
        : BaseChain(sum)
    { }

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

    inline bool operator==(const FloatChain& other) const
    { return BaseChain::operator==(other) && (data == other.data); }

    inline bool operator!=(const FloatChain& other) const
    { return !(*this == other); }

    inline float operator[](const size_t index) const
    { return data[index]; }

    inline float at(const size_t index) const
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
    AlignedVector<float> data;
    
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
