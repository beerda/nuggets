#pragma once

#include "../common.h"


template <typename BITCHAIN, typename NUMCHAIN>
class DualChain {
public:
    /**
     * Default constructor.
     */
    DualChain()
        : null(true),
          bitData(),
          numData()
    { }

    /**
     * Constructor with a specified size.
     */
    DualChain(size_t n)
        : null(false),
          bitData(n),
          numData(n)
    { }

    /**
     * Constructor with specified numeric data from Rcpp.
     */
    DualChain(const NumericVector& values)
        : null(false),
          bitData(),
          numData(values)
    { }

    /**
     * Constructor with specified bitwise data from Rcpp.
     */
    DualChain(const LogicalVector& values)
        : null(false),
          bitData(values),
          numData()
    { }

    /**
     * Copy constructor.
     */
    DualChain(const DualChain& other)
        : null(other.null),
          bitData(other.bitData),
          numData(other.numData)
    { }

    /**
     * Move constructor.
     */
    DualChain(DualChain&& other) noexcept
        : null(other.null),
          bitData(std::move(other.bitData)),
          numData(std::move(other.numData))
    { }

    /**
     * Copy assignment operator.
     */
    DualChain& operator=(const DualChain& other)
    {
        if (this != &other) {
            null = other.null;
            bitData = other.bitData;
            numData = other.numData;
        }
        return *this;
    }

    /**
     * Move assignment operator.
     */
    DualChain& operator=(DualChain&& other) noexcept
    {
        if (this != &other) {
            null = other.null;
            bitData = std::move(other.bitData);
            numData = std::move(other.numData);
        }
        return *this;
    }

    /**
     * Comparison (equality) operator.
     */
    bool operator == (const DualChain& other) const
    { return (null == other.null) && (numData == other.numData) && (bitData == other.bitData); }

    /**
     * Comparison (inequality) operator.
     */
    bool operator != (const DualChain& other) const
    { return !(*this == other); }

    bool empty() const
    { return null || (numData.empty() && bitData.empty()); }

    bool isNull() const
    { return null; }

    size_t size() const
    { return isBitwise() ? bitData.size() : numData.size(); }

    bool isBitwise() const
    { return !bitData.empty(); }

    bool isNumeric() const
    { return !numData.empty(); }

    void toNumeric()
    {
        if (isNumeric())
            return;

        if (isBitwise()) {
            numData.clear();
            numData.reserve(size());
            for (size_t i = 0; i < size(); i++) {
                numData.pushBack(1.0 * bitData.at(i));
            }
        }
    }

    void toNumericIfOtherIsNumericOnly(const DualChain<BITCHAIN, NUMCHAIN>& other)
    {
        if (other.isNumeric() && !other.isBitwise())
            toNumeric();
    }

    void negate()
    {
        if (isBitwise()) {
            bitData.negate();
        }
        if (isNumeric()) {
            numData.negate();
        }
    }

    void conjunctWith(const DualChain<BITCHAIN, NUMCHAIN>& chain)
    {
        if (size() != chain.size()) {
            throw runtime_error("Incompatible chain lengths");

        } else if (isBitwise() && chain.isBitwise()) {
            bitData.conjunctWith(chain.bitData);
            numData.clear();

        } else if (isNumeric() && chain.isNumeric()) {
            numData.conjunctWith(chain.numData);
            bitData.clear();

        } else {
            throw runtime_error("Incompatible chain types");
        }
    }

    float getSum() const
    { return isBitwise() ? bitData.getSum() : numData.getSum(); }

    float getSupport() const
    {
        if (empty())
            return 1.0;
        else
            return getSum() / size();
    }

    float getValue(size_t index) const
    {
        if (isBitwise())
            return 1.0 * bitData.at(index);
        else if (isNumeric())
            return numData.at(index);
        else
            return NAN;
    }

    void print() const
    {
        printf("\n");
        printf("numData:");
        for (size_t i = 0; i < numData.size(); i++) {
            printf(" %f", numData.at(i));
        }
        printf("\n");
        printf("bitData:");
        for (size_t i = 0; i < bitData.size(); i++) {
            printf(" %d", bitData.at(i));
        }
        printf("\n");
    }

private:
    bool null;
    BITCHAIN bitData;
    NUMCHAIN numData;
};
