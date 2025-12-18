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
            this->sum += vec[i];
        }
    }

    FloatChain(const FloatChain& a, const FloatChain& b, const bool toFocus)
        : BaseChain(a, b, toFocus),
          data(a.data.size())
    {
        IF_DEBUG(
            if (a.data.size() != b.data.size()) {
                throw std::invalid_argument("FloatChain: incompatible sizes");
            }
        )

        const size_t n = a.data.size();
        const float* aptr = a.data.data();
        const float* bptr = b.data.data();
        float* dptr = data.data();
        
        if constexpr (TNORM == TNorm::GOEDEL) {
            for (size_t i = 0; i < n; ++i) {
                float val = std::min(aptr[i], bptr[i]);
                dptr[i] = val;
                sum += val;
            }
        } else if constexpr (TNORM == TNorm::LUKASIEWICZ) {
            for (size_t i = 0; i < n; ++i) {
                float val = std::max(0.0f, aptr[i] + bptr[i] - 1.0f);
                dptr[i] = val;
                sum += val;
            }
        } else if constexpr (TNORM == TNorm::GOGUEN) {
            for (size_t i = 0; i < n; ++i) {
                float val = aptr[i] * bptr[i];
                dptr[i] = val;
                sum += val;
            }
        } else {
            static_assert(TNORM != TNorm::GOEDEL && TNORM != TNorm::GOGUEN && TNORM != TNorm::LUKASIEWICZ,
                          "Unsupported TNorm type");
        }
    }

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

    string toString() const
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
};
