#pragma once

#include <functional>
#include "xsimd/xsimd.hpp"
#include "AbstractVectorNumChain.h"


// Forward declaration
template <TNorm TNORM>
class SimdVectorNumChain;

template <TNorm TNORM>
struct SVNChHelper;

/**
* Implementation of chain of numbers based on a vector with operations
* implemented using SIMD instructions.
*/
template <TNorm TNORM>
class SimdVectorNumChain : public AbstractVectorNumChain {
public:
    using batchType = xsimd::batch<float>;
    friend struct SVNChHelper<TNORM>;

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

    void conjunctWith(const SimdVectorNumChain<TNORM>& other)
    { SVNChHelper<TNORM>::conjunctWith(*this, other); }

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

template <TNorm TNORM>
struct SVNChHelper {
    static void conjunctWith(SimdVectorNumChain<TNORM>& self,
                             const SimdVectorNumChain<TNORM>& other)
    { }
};

template <>
struct SVNChHelper<TNorm::GOEDEL> {
    using batchType = SimdVectorNumChain<TNorm::GOEDEL>::batchType;

    static void conjunctWith(SimdVectorNumChain<TNorm::GOEDEL>& self,
                             const SimdVectorNumChain<TNorm::GOEDEL>& other)
    {
        if (self.values.size() != other.values.size()) {
            throw std::invalid_argument("SimdVectorNumChain::conjunctWith: incompatible sizes");
        }

        self.cachedSum = 0;
        size_t simdSize = self.values.size() - self.values.size() % self.batchSize;

        for (size_t i = 0; i < simdSize; i += self.batchSize) {
            batchType a = batchType::load_unaligned(&self.values[i]);
            batchType b = batchType::load_unaligned(&other.values[i]);
            batchType res = fmin(a, b);
            res.store_unaligned(&self.values[i]);
            self.cachedSum += xsimd::reduce_add(res);
        }

        for (size_t i = simdSize; i < self.values.size(); ++i) {
            self.values[i] = fmin(self.values[i], other.values[i]);
            self.cachedSum += self.values[i];
        }
    }
};

template <>
struct SVNChHelper<TNorm::GOGUEN> {
    using batchType = SimdVectorNumChain<TNorm::GOGUEN>::batchType;

    static void conjunctWith(SimdVectorNumChain<TNorm::GOGUEN>& self,
                             const SimdVectorNumChain<TNorm::GOGUEN>& other)
    {
        if (self.values.size() != other.values.size()) {
            throw std::invalid_argument("SimdVectorNumChain::conjunctWith: incompatible sizes");
        }

        self.cachedSum = 0;
        size_t simdSize = self.values.size() - self.values.size() % self.batchSize;

        for (size_t i = 0; i < simdSize; i += self.batchSize) {
            batchType a = batchType::load_unaligned(&self.values[i]);
            batchType b = batchType::load_unaligned(&other.values[i]);
            batchType res  = a * b;
            res.store_unaligned(&self.values[i]);
            self.cachedSum += xsimd::reduce_add(res);
        }

        for (size_t i = simdSize; i < self.values.size(); ++i) {
            self.values[i] = self.values[i] * other.values[i];
            self.cachedSum += self.values[i];
        }
    }
};

template <>
struct SVNChHelper<TNorm::LUKASIEWICZ> {
    using batchType = SimdVectorNumChain<TNorm::LUKASIEWICZ>::batchType;

    static void conjunctWith(SimdVectorNumChain<TNorm::LUKASIEWICZ>& self,
                             const SimdVectorNumChain<TNorm::LUKASIEWICZ>& other)
    {
        if (self.values.size() != other.values.size()) {
            throw std::invalid_argument("SimdVectorNumChain::conjunctWith: incompatible sizes");
        }

        const batchType zero(0.0f);
        const batchType one(1.0f);
        self.cachedSum = 0;
        size_t simdSize = self.values.size() - self.values.size() % self.batchSize;

        for (size_t i = 0; i < simdSize; i += self.batchSize) {
            batchType a = batchType::load_unaligned(&self.values[i]);
            batchType b = batchType::load_unaligned(&other.values[i]);
            batchType res = fmax(zero, a + b - one);
            res.store_unaligned(&self.values[i]);
            self.cachedSum += xsimd::reduce_add(res);
        }

        for (size_t i = simdSize; i < self.values.size(); ++i) {
            self.values[i] = fmax(0.0f, self.values[i] + other.values[i] - 1);
            self.cachedSum += self.values[i];
        }
    }
};
