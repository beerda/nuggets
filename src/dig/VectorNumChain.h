#pragma once

#include "AbstractVectorNumChain.h"


/**
 * Implementation of chain of numbers based on a vector.
 */
template <TNorm TNORM>
class VectorNumChain : public AbstractVectorNumChain {
public:
    VectorNumChain()
        : AbstractVectorNumChain()
    { }

    VectorNumChain(const NumericVector& vals)
        : AbstractVectorNumChain(vals)
    { }

    void negate()
    {
        for (size_t i = 0; i < values.size(); ++i)
            values[i] = 1 - values[i];
    }

    void conjunctWith(const VectorNumChain<TNORM>& other);

    bool operator == (const VectorNumChain& other) const
    { return values == other.values; }

    bool operator != (const VectorNumChain& other) const
    { return !(*this == other); }
};
