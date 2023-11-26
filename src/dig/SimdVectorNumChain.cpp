#include <cmath>
#include "dig/SimdVectorNumChain.h"


template <>
void SimdVectorNumChain<TNorm::GOEDEL>::conjunctWith(const SimdVectorNumChain<TNorm::GOEDEL>& other)
{
    if (values.size() != other.values.size()) {
        throw std::invalid_argument("SimdVectorNumChain::conjunctWith: incompatible sizes");
    }

    cachedSum = 0;
    size_t simdSize = values.size() - values.size() % batchSize;

    for (size_t i = 0; i < simdSize; i += batchSize) {
        batchType a = batchType::load_unaligned(&values[i]);
        batchType b = batchType::load_unaligned(&other.values[i]);
        batchType res = fmin(a, b);
        res.store_unaligned(&values[i]);
        cachedSum += xsimd::reduce_add(res);
    }

    for (size_t i = simdSize; i < values.size(); ++i) {
        values[i] = fmin(values[i], other.values[i]);
        cachedSum += values[i];
    }
}

template <>
void SimdVectorNumChain<TNorm::GOGUEN>::conjunctWith(const SimdVectorNumChain<TNorm::GOGUEN>& other)
{
    if (values.size() != other.values.size()) {
        throw std::invalid_argument("SimdVectorNumChain::conjunctWith: incompatible sizes");
    }

    cachedSum = 0;
    size_t simdSize = values.size() - values.size() % batchSize;

    for (size_t i = 0; i < simdSize; i += batchSize) {
        batchType a = batchType::load_unaligned(&values[i]);
        batchType b = batchType::load_unaligned(&other.values[i]);
        batchType res  = a * b;
        res.store_unaligned(&values[i]);
        cachedSum += xsimd::reduce_add(res);
    }

    for (size_t i = simdSize; i < values.size(); ++i) {
        values[i] = values[i] * other.values[i];
        cachedSum += values[i];
    }
}

template <>
void SimdVectorNumChain<TNorm::LUKASIEWICZ>::conjunctWith(const SimdVectorNumChain<TNorm::LUKASIEWICZ>& other)
{
    if (values.size() != other.values.size()) {
        throw std::invalid_argument("SimdVectorNumChain::conjunctWith: incompatible sizes");
    }

    const batchType zero(0.0f);
    const batchType one(1.0f);
    cachedSum = 0;
    size_t simdSize = values.size() - values.size() % batchSize;

    for (size_t i = 0; i < simdSize; i += batchSize) {
        batchType a = batchType::load_unaligned(&values[i]);
        batchType b = batchType::load_unaligned(&other.values[i]);
        batchType res = fmax(zero, a + b - one);
        res.store_unaligned(&values[i]);
        cachedSum += xsimd::reduce_add(res);
    }

    for (size_t i = simdSize; i < values.size(); ++i) {
        values[i] = fmax(0.0f, values[i] + other.values[i] - 1);
        cachedSum += values[i];
    }
}
