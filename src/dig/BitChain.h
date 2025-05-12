#pragma once

#include "../common.h"
#include "BaseChain.h"
#include <boost/dynamic_bitset.hpp>


/**
 * Implementation of chain of bits.
 */
class BitChain : public BaseChain {
public:
    BitChain(float sum)
        : BaseChain(sum)
    { }

    BitChain(size_t id, PredicateType type, const LogicalVector& vec)
        : BaseChain(id, type, 0),
          data(vec.size())
    {
        for (R_xlen_t i = 0; i < vec.size(); ++i) {
            if (vec[i]) {
                data.set(i);
                this->sum++;
            }
        }
    }

    BitChain(size_t id, PredicateType type, const NumericVector& vec)
        : BaseChain(id, type, 0),
          data(vec.size())
    { throw std::invalid_argument("BitChain: NumericVector constructor not implemented"); }

    BitChain(const BitChain& a, const BitChain& b)
        : BaseChain(a, b),
          data(a.data & b.data)
    { sum = data.count(); }

    // Disable copy
    BitChain(const BitChain& other) = delete;
    BitChain& operator=(const BitChain& other) = delete;

    // Allow move
    BitChain(BitChain&& other) = default;
    BitChain& operator=(BitChain&& other) = default;

    bool operator==(const BitChain& other) const
    { return BaseChain::operator==(other) && (data == other.data); }

    bool operator!=(const BitChain& other) const
    { return !(*this == other); }

    bool operator[](size_t index) const
    { return data[index]; }

    bool at(size_t index) const
    { return data.at(index); }

    size_t size() const
    { return data.size(); }

    bool empty() const
    { return data.empty(); }

    string toString() const
    {
        stringstream res;
        res << "[n=" << data.size() << "]";
        for (size_t i = 0; i < data.size(); ++i) {
            res << data[i];
        }

        return res.str();
    }

private:
    boost::dynamic_bitset<> data;
};
