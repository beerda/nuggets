#pragma once

#include "../common.h"
#include "Bitset.h"


/**
 * Implementation of chain of bits based on the Bitset class, which realizes
 * a growable array of bits.
 */
class BitChain {
public:
    BitChain()
        : cachedSum(0)
    { }

    BitChain(const LogicalVector& vals)
        : cachedSum(0)
    {
        reserve(vals.size());
        for (R_xlen_t i = 0; i < vals.size(); i++)
            push_back(vals.at(i));
    }

    void clear()
    {
        values.clear();
        cachedSum = 0;
    }

    void reserve(size_t size)
    { values.reserve(size); }

    void push_back(bool value)
    {
        values.push_back(value);
        if (value)
            cachedSum++;
    }

    void negate()
    {
        values.negate();
        cachedSum = values.size() - cachedSum;
    }

    void conjunctWith(const BitChain& other)
    {
        values &= other.values;
        cachedSum = values.getSum();
    }

    size_t size() const
    { return values.size(); }

    bool empty() const
    { return values.empty(); }

    float getSum() const
    { return 1.0 * cachedSum; }

    bool at(size_t i) const
    { return values.at(i); }

    bool operator == (const BitChain& other) const
    { return values == other.values; }

    bool operator != (const BitChain& other) const
    { return !(*this == other); }

private:
    Bitset values;
    size_t cachedSum;
};
