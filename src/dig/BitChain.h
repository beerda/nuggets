#pragma once

#include "../common.h"
#include <boost/dynamic_bitset.hpp>


/**
 * Implementation of chain of bits.
 */
class BitChain {
public:
    constexpr static size_t CHUNK_SIZE = 8 * sizeof(uintmax_t);

    BitChain(size_t n)
        : data(n), sum(0)
    { }

    BitChain(const LogicalVector& vals)
        : data(vals.size()), sum(0)
    {
        for (R_xlen_t i = 0; i < vals.size(); ++i) {
            if (vals[i]) {
                data.set(i);
                sum++;
            }
        }
    }

    // Allow copy
    BitChain(const BitChain& other) = default;
    BitChain& operator=(const BitChain& other) = default;

    // Allow move
    BitChain(BitChain&& other) = default;
    BitChain& operator=(BitChain&& other) = default;

    bool operator==(const BitChain& other) const
    { return (sum == other.sum) && (data == other.data); }

    bool operator!=(const BitChain& other) const
    { return !(*this == other); }

    void operator&=(const BitChain& other)
    {
        if (data.size() != other.data.size()) {
            throw std::invalid_argument("BitChain::operator&=: incompatible sizes");
        }
        data &= other.data;
        sum = data.count();
    }

    bool operator[](size_t index) const
    { return data[index]; }

    bool at(size_t index) const
    { return data.at(index); }

    size_t size() const
    { return data.size(); }

    bool empty() const
    { return data.empty(); }

    size_t getSum() const
    { return sum; }

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
    size_t sum;
};
