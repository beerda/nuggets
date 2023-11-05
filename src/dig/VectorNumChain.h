#pragma once

#include <vector>
#include "../common.h"


/**
 * Implementation of chain of numbers based on a vector.
 */
class VectorNumChain {
public:
    VectorNumChain()
        : cachedSum(0)
    { }

    VectorNumChain(const doubles& vals)
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

    void push_back(double value)
    {
        values.push_back(value);
        cachedSum += value;
    }

    void conjunctWith(const VectorNumChain& other)
    {
        cachedSum = 0;
        for (size_t i = 0; i < values.size(); i++) {
            values[i] *= other.values[i];
            cachedSum += values[i];
        }
    }

    size_t size() const
    { return values.size(); }

    bool empty() const
    { return values.empty(); }

    double getSum() const
    { return cachedSum; }

    double at(size_t i) const
    { return values[i]; }

    bool operator == (const VectorNumChain& other) const
    { return values == other.values; }

    bool operator != (const VectorNumChain& other) const
    { return !(*this == other); }

private:
    vector<double> values;
    double cachedSum;
};
