#pragma once

#include "AbstractVectorNumChain.h"


/**
 * Implementation of chain of numbers based on a vector.
 */
template <TNorm TNORM>
class SimdNumChain : public AbstractVectorNumChain {
public:
    SimdNumChain()
        : AbstractVectorNumChain()
    { }

    SimdNumChain(const NumericVector& vals)
        : AbstractVectorNumChain(vals)
    { }

    void conjunctWith(const SimdNumChain<TNORM>& other);

    bool operator == (const SimdNumChain& other) const
    { return values == other.values; }

    bool operator != (const SimdNumChain& other) const
    { return !(*this == other); }
};
