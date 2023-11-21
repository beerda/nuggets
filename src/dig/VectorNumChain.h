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

    void conjunctWith(const VectorNumChain<TNORM>& other);

    bool operator == (const VectorNumChain& other) const
    { return values == other.values; }

    bool operator != (const VectorNumChain& other) const
    { return !(*this == other); }
};
