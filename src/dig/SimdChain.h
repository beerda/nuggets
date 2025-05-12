#pragma once

#include <immintrin.h>
#include "../common.h"
#include "../AlignedVector.h"
#include "xsimd/xsimd.hpp"
#include "BaseChain.h"


template <TNorm TNORM>
class SimdChain : public BaseChain {
public:
    using batchType = xsimd::batch<float>;

    SimdChain()
        : BaseChain()
    { }

    SimdChain(size_t id, PredicateType type, const LogicalVector& vec)
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

    SimdChain(size_t id, PredicateType type, const NumericVector& vec)
        : BaseChain(id, type, 0),
          data(vec.size())
    {
        for (R_xlen_t i = 0; i < vec.size(); i++) {
            data[i] = vec[i];
            this->sum += vec[i];
        }
    }

    SimdChain(const SimdChain& a, const SimdChain& b)
        : BaseChain(a, b),
          data(a.data.size())
    {
        IF_DEBUG(
            if (a.data.size() != b.data.size()) {
                throw std::invalid_argument("SimdChain: incompatible sizes");
            }
        )

        size_t simdSize = a.data.size() - a.data.size() % batchType::size;
        for (size_t i = 0; i < simdSize; i += batchType::size) {
            batchType aa1 = batchType::load_aligned(&a.data[i]);
            batchType bb1 = batchType::load_aligned(&b.data[i]);
            batchType res1;

            if constexpr (TNORM == TNorm::GOEDEL) {
                res1 = fmin(aa1, bb1);
            } else if constexpr (TNORM == TNorm::LUKASIEWICZ) {
                const batchType zero(0.0f);
                const batchType one(1.0f);
                res1 = fmax(zero, aa1 + bb1 - one);
            } else if constexpr (TNORM == TNorm::GOGUEN) {
                res1  = aa1 * bb1;
            } else {
                static_assert(TNORM != TNorm::GOEDEL && TNORM != TNorm::GOGUEN && TNORM != TNorm::LUKASIEWICZ,
                              "Unsupported TNorm type");
            }

            res1.store_aligned(&data[i]);
            sum += xsimd::reduce_add(res1);
        }

        for (size_t i = simdSize; i < a.data.size(); ++i) {
            if constexpr (TNORM == TNorm::GOEDEL) {
                data[i] = std::min(a.data[i], b.data[i]);
            } else if constexpr (TNORM == TNorm::LUKASIEWICZ) {
                data[i] = std::max(0.0, a.data[i] + b.data[i] - 1.0);
            } else if constexpr (TNORM == TNorm::GOGUEN) {
                data[i] = a.data[i] * b.data[i];
            } else {
                static_assert(TNORM != TNorm::GOEDEL && TNORM != TNorm::GOGUEN && TNORM != TNorm::LUKASIEWICZ,
                              "Unsupported TNorm type");
            }
            sum += data[i];
        }
    }

    // Disable copy
    SimdChain(const SimdChain& other) = delete;
    SimdChain& operator=(const SimdChain& other) = delete;

    // Allow move
    SimdChain(SimdChain&& other) = default;
    SimdChain& operator=(SimdChain&& other) = default;

    bool operator==(const SimdChain& other) const
    { return BaseChain::operator==(other) && (data == other.data); }

    bool operator!=(const SimdChain& other) const
    { return !(*this == other); }

    float operator[](size_t index) const
    { return data[index]; }

    float at(size_t index) const
    { return data.at(index); }

    size_t size() const
    { return data.size(); }

    bool empty() const
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
