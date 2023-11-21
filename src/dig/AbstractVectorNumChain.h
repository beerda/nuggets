#pragma once

#include <vector>
#include "../common.h"


/**
 * Base class for a chain of numbers based on a vector.
 */
class AbstractVectorNumChain {
public:
    AbstractVectorNumChain()
        : cachedSum(0)
    { }

    AbstractVectorNumChain(const NumericVector& vals)
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

    size_t size() const
    { return values.size(); }

    bool empty() const
    { return values.empty(); }

    double getSum() const
    { return cachedSum; }

    double at(size_t i) const
    { return values[i]; }

protected:
    vector<double> values;
    double cachedSum;
};
