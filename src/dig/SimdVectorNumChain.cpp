#include <cmath>
#include "dig/SimdVectorNumChain.h"


template <>
void SimdVectorNumChain<TNorm::GOEDEL>::conjunctWith(const SimdVectorNumChain<TNorm::GOEDEL>& other)
{
    const auto batchOp = [] (const batchType& a, const batchType& b, batchType& res) {
        res = fmin(a, b);
    };
    const auto seqOp = [] (float a, float b) {
        return fmin(a, b);
    };

    batchConjunct(other.values, batchOp, seqOp);
}

template <>
void SimdVectorNumChain<TNorm::GOGUEN>::conjunctWith(const SimdVectorNumChain<TNorm::GOGUEN>& other)
{
    const auto batchOp = [] (const batchType& a, const batchType& b, batchType& res) {
        res = a * b;
    };
    const auto seqOp = [] (float a, float b) {
        return a * b;
    };

    batchConjunct(other.values, batchOp, seqOp);
}

template <>
void SimdVectorNumChain<TNorm::LUKASIEWICZ>::conjunctWith(const SimdVectorNumChain<TNorm::LUKASIEWICZ>& other)
{
    const batchType zero(0.0f);
    const batchType one(1.0f);

    const auto batchOp = [&zero, &one] (const batchType& a, const batchType& b, batchType& res) {
        res = fmax(zero, a + b - one);
    };
    const auto seqOp = [] (float a, float b) {
        return fmax(0.0f, a + b - 1);
    };

    batchConjunct(other.values, batchOp, seqOp);
}
