#pragma once

#include "AbstractVectorNumChain.h"


// Forward declaration
template <TNorm TNORM>
class VectorNumChain;

template <TNorm TNORM>
struct VNChHelper;

/**
 * Implementation of chain of numbers based on a vector.
 */
template <TNorm TNORM>
class VectorNumChain : public AbstractVectorNumChain {
public:
    friend struct VNChHelper<TNORM>;

    /**
     * Default constructor.
     */
    VectorNumChain()
        : AbstractVectorNumChain()
    { }

    /**
     * Constructor with a specified size.
     */
    VectorNumChain(size_t n)
        : AbstractVectorNumChain(n)
    { }

    /**
     * Constructor with specified data from Rcpp.
     */
    VectorNumChain(const NumericVector& vals)
        : AbstractVectorNumChain(vals)
    { }

    /**
     * Copy constructor.
     */
    VectorNumChain(const VectorNumChain& other) = default;
    VectorNumChain& operator=(const VectorNumChain& other) = default;
    VectorNumChain(VectorNumChain&& other) = default;
    VectorNumChain& operator=(VectorNumChain&& other) = default;

    /**
     * Comparison (equality) operator.
     */
    bool operator == (const VectorNumChain& other) const
    { return AbstractVectorNumChain::operator==(other); }

    /**
     * Comparison (inequality) operator.
     */
    bool operator != (const VectorNumChain& other) const
    { return !(*this == other); }

    void negate()
    {
        for (size_t i = 0; i < values.size(); ++i)
            values[i] = 1 - values[i];
    }

    void conjunctWith(const VectorNumChain<TNORM>& other)
    { VNChHelper<TNORM>::conjunctWith(*this, other); }
};


template <TNorm TNORM>
struct VNChHelper {
    static void conjunctWith(VectorNumChain<TNORM>& self,
                             const VectorNumChain<TNORM>& other)
    { }
};

template <>
struct VNChHelper<TNorm::GOEDEL> {
    static void conjunctWith(VectorNumChain<TNorm::GOEDEL>& self,
                             const VectorNumChain<TNorm::GOEDEL>& other)
    {
        if (self.values.size() != other.values.size()) {
            throw std::invalid_argument("VectorNumChain::conjunctWith: incompatible sizes");
        }

        self.cachedSum = 0;
        for (size_t i = 0; i < self.values.size(); i++) {
            self.values[i] = min(self.values[i], other.values[i]);
            self.cachedSum += self.values[i];
        }
    }
};

template <>
struct VNChHelper<TNorm::GOGUEN> {
    static void conjunctWith(VectorNumChain<TNorm::GOGUEN>& self,
                             const VectorNumChain<TNorm::GOGUEN>& other)
    {
        if (self.values.size() != other.values.size()) {
            throw std::invalid_argument("VectorNumChain::conjunctWith: incompatible sizes");
        }

        self.cachedSum = 0;
        for (size_t i = 0; i < self.values.size(); i++) {
            self.values[i] *= other.values[i];
            self.cachedSum += self.values[i];
        }
    }
};

template <>
struct VNChHelper<TNorm::LUKASIEWICZ> {
    static void conjunctWith(VectorNumChain<TNorm::LUKASIEWICZ>& self,
                             const VectorNumChain<TNorm::LUKASIEWICZ>& other)
    {
        if (self.values.size() != other.values.size()) {
            throw std::invalid_argument("VectorNumChain::conjunctWith: incompatible sizes");
        }

        self.cachedSum = 0;
        for (size_t i = 0; i < self.values.size(); i++) {
            self.values[i] = max(0.0f, self.values[i] + other.values[i] - 1);
            self.cachedSum += self.values[i];
        }
    }
};
