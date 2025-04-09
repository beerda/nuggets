#pragma once

#include <vector>
#include "../common.h"


/**
 * Base class for a chain of numbers based on a vector.
 */
class AbstractVectorNumChain {
public:
    /**
     * Default constructor.
     */
    AbstractVectorNumChain()
        : values(),
          cachedSum(0.0)
    { }

    /**
     * Constructor with a specified size.
     */
    AbstractVectorNumChain(size_t n)
        : values(n),
          cachedSum(0.0)
    { }

    /**
     * Constructor with specified data from Rcpp.
     */
    AbstractVectorNumChain(const NumericVector& vals)
        : values(vals.size()),
          cachedSum(0.0)
    {
        for (R_xlen_t i = 0; i < vals.size(); i++) {
            values[i] = vals[i];
            cachedSum += vals[i];
        }
    }

    AbstractVectorNumChain(const AbstractVectorNumChain& other) = default;
    AbstractVectorNumChain& operator=(const AbstractVectorNumChain& other) = default;
    AbstractVectorNumChain(AbstractVectorNumChain&& other) = default;
    AbstractVectorNumChain& operator=(AbstractVectorNumChain&& other) = default;

    /**
     * Comparison (equality) operator.
     */
    bool operator==(const AbstractVectorNumChain& other) const
    { return (cachedSum == other.cachedSum) && (values == other.values); }

    /**
     * Comparison (inequality) operator.
     */
    bool operator!=(const AbstractVectorNumChain& other) const
    { return !(*this == other); }

    void clear()
    {
        values.clear();
        cachedSum = 0;
    }

    void reserve(size_t size)
    { values.reserve(size); }

    void pushBack(float value)
    {
        values.push_back(value);
        cachedSum += value;
    }

    size_t size() const
    { return values.size(); }

    bool empty() const
    { return values.empty(); }

    float getSum() const
    { return cachedSum; }

    float at(size_t i) const
    { return values[i]; }

protected:
    vector<float> values;
    float cachedSum;
};
