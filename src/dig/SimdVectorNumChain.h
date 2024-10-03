#pragma once

#include <functional>
#include "xsimd/xsimd.hpp"
#include "AbstractVectorNumChain.h"


/**
* Implementation of chain of numbers based on a vector with operations
* implemented using SIMD instructions.
*/
template <TNorm TNORM>
class SimdVectorNumChain : public AbstractVectorNumChain {
public:
    using batchType = xsimd::batch<float>;

    SimdVectorNumChain()
        : AbstractVectorNumChain()
    { }

    SimdVectorNumChain(const NumericVector& vals)
        : AbstractVectorNumChain(vals)
    { }

    void negate()
    {
        cachedSum = 0;
        size_t simdSize = values.size() - values.size() % batchSize;

        for (size_t i = 0; i < simdSize; i += batchSize) {
            batchType a = batchType::load_unaligned(&values[i]);
            batchType res = 1 - a;
            res.store_unaligned(&values[i]);
            cachedSum += xsimd::reduce_add(res);
        }

        for (size_t i = simdSize; i < values.size(); ++i) {
            values[i] = 1 - values[i];
            cachedSum += values[i];
        }
    }

    void conjunctWith(const SimdVectorNumChain<TNORM>& other);

    bool operator == (const SimdVectorNumChain& other) const
    { return values == other.values; }

    bool operator != (const SimdVectorNumChain& other) const
    { return !(*this == other); }

private:
    size_t batchSize = batchType::size;

    void batchConjunct(const vector<float> otherValues,
                       const std::function<void (const batchType&, const batchType&, batchType&)>& batchOp,
                       const std::function<float (float, float)>& seqOp)
    {
        if (values.size() != otherValues.size()) {
            throw std::invalid_argument("SimdVectorNumChain::conjunctWith: incompatible sizes");
        }

        cachedSum = 0;
        size_t simdSize = values.size() - values.size() % batchSize;

        for (size_t i = 0; i < simdSize; i += batchSize) {
            batchType a = batchType::load_unaligned(&values[i]);
            batchType b = batchType::load_unaligned(&otherValues[i]);
            batchType res;
            batchOp(a, b, res);
            res.store_unaligned(&values[i]);
            cachedSum += xsimd::reduce_add(res);
        }

        for (size_t i = simdSize; i < values.size(); ++i) {
            values[i] = seqOp(values[i], otherValues[i]);
            cachedSum += values[i];
        }
    }
};
