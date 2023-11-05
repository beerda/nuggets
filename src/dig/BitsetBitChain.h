#pragma once

#include <boost/dynamic_bitset.hpp>
#include "../common.h"


/**
 * Implementation of chain of bits based on a Boost dynamic_bitset.
 */
class BitsetBitChain {
public:
    BitsetBitChain()
        : cachedSum(0)
    { }

    BitsetBitChain(const logicals& vals)
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

    void conjunctWith(const BitsetBitChain& other)
    {
        values &= other.values;
        cachedSum = 1.0 * values.count();
    }

    size_t size() const
    { return values.size(); }

    bool empty() const
    { return values.empty(); }

    double getSum() const
    { return cachedSum; }

    bool at(size_t i) const
    { return values.at(i); }

    bool operator == (const BitsetBitChain& other) const
    { return values == other.values; }

    bool operator != (const BitsetBitChain& other) const
    { return !(*this == other); }

private:
    boost::dynamic_bitset<> values;
    double cachedSum;
};
