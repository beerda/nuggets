#pragma once

#include <bitset>
#include "../common.h"
#include "../AlignedVector.h"


/**
 * Implementation of chain of bits.
 */
class BitChain {
public:
    constexpr static size_t CHUNK_SIZE = 8 * sizeof(uintmax_t);

    /**
     * Default constructor.
     */
    BitChain()
        : data(),
          n(0),
          cachedSum(0)
    { }

    /**
     * Constructor with a specified size.
     */
    BitChain(size_t n)
        : data(calculateCapacity(n)),
          n(n),
          cachedSum(0)
    { }

    /**
     * Constructor with specified data from Rcpp.
     */
    BitChain(const LogicalVector& vals)
        : data(calculateCapacity(vals.size())),
          n(vals.size()),
          cachedSum(0)
    {
        for (R_xlen_t i = 0; i < vals.size(); ++i) {
            if (vals[i]) {
                data[i / CHUNK_SIZE] |= (uintmax_t(1) << (i % CHUNK_SIZE));
                ++cachedSum;
            }
        }
    }

    /**
     * Copy constructor.
     */
    BitChain(const BitChain& other)
        : data(other.data),
          n(other.n),
          cachedSum(other.cachedSum)
    { }

    /**
     * Move constructor.
     */
    BitChain(BitChain&& other) noexcept
        : data(std::move(other.data)),
          n(other.n),
          cachedSum(other.cachedSum)
    { }

    /**
     * Copy assignment operator.
     */
    BitChain& operator=(const BitChain& other)
    {
        if (this != &other) {
            data = other.data;
            n = other.n;
            cachedSum = other.cachedSum;
        }

        return *this;
    }

    /**
     * Move assignment operator.
     */
    BitChain& operator=(BitChain&& other) noexcept
    {
        if (this != &other) {
            data = std::move(other.data);
            n = other.n;
            cachedSum = other.cachedSum;
        }

        return *this;
    }

    /**
     * Comparison (equality) operator.
     */
    bool operator == (const BitChain& other) const
    { return (n == other.n) && (cachedSum == other.cachedSum) && (data == other.data); }

    /**
     * Comparison (inequality) operator.
     */
    bool operator != (const BitChain& other) const
    { return !(*this == other); }

    void clear()
    {
        data.clear();
        n = 0;
        cachedSum = 0;
    }

    void reserve(size_t size)
    { data.reserve(calculateCapacity(size)); }

    size_t size() const
    { return n; }

    size_t nChunks() const
    { return data.size(); }

    bool empty() const
    { return n == 0; }

    bool isAligned() const
    { return n % CHUNK_SIZE == 0; }

    void push_back(bool value)
    {
        if (isAligned()) {
            data.push_back(0);
        }
        if (value) {
            data.back() |= (uintmax_t(1) << (n % CHUNK_SIZE));
            ++cachedSum;
        }
        ++n;
    }

    bool at(size_t index) const
    {
        if (index >= n) {
            throw std::out_of_range("Bitset::at");
        }

        return (data[index / CHUNK_SIZE] >> (index % CHUNK_SIZE)) & 1;
    }

    float getSum() const
    { return 1.0 * cachedSum; }

    void negate()
    {
        if (n > 0) {
            for (size_t i = 0; i < n / CHUNK_SIZE; i++) {
                data[i] = ~data[i];
            }

            for (size_t i = 0; i < n % CHUNK_SIZE; i++) {
                data[data.size() - 1] ^= (((uintmax_t) 1) << i);
            }
        }
        cachedSum = n - cachedSum;
    }

    void conjunctWith(const BitChain& other)
    {
        if (n != other.n) {
            throw std::out_of_range("Bitset::operator&=: incompatible sizes");
        }
        cachedSum = 0;
        for (size_t i = 0; i < data.size(); i++) {
            data[i] &= other.data[i];
            cachedSum += countBits(data[i]);
        }
    }

    const AlignedVector<uintmax_t>& getData() const
    { return data; }

    AlignedVector<uintmax_t>& getMutableData()
    { return data; }

    string toString() const
    {
        stringstream res;
        res << "[n=" << n << "]";
        for (size_t i = 0; i < n; ++i) {
            res << (at(i) + 0);
        }

        return res.str();
    }


private:
    AlignedVector<uintmax_t> data;
    size_t n;
    size_t cachedSum;

    static size_t calculateCapacity(size_t size)
    {
        // bitwise ceiling, see: http://stackoverflow.com/questions/2745074/fast-ceiling-of-an-integer-division-in-c-c
        return (size + CHUNK_SIZE - 1) / CHUNK_SIZE;
    }

    static inline size_t countBits(uintmax_t chunk)
    {
        //return popcount(chunk);                               // C++20 version
        return static_cast<uint8_t>(bitset<64>(chunk).count()); // C++98 version
    }

};
