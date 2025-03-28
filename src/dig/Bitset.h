#pragma once

#include <bitset>
#include "../common.h"
#include "../AlignedVector.h"


/**
 * A growable array of bits.
 */
class Bitset {
public:
    constexpr static size_t CHUNK_SIZE = 8 * sizeof(uintmax_t);

    Bitset()
        : data(), n(0)
    { }

    Bitset(size_t n)
        : data((n + CHUNK_SIZE - 1) / CHUNK_SIZE), n(n)
    { }

    Bitset(const AlignedVector<uintmax_t>& data, size_t n)
        : data(data), n(n)
    { }

    void clear()
    {
        data.clear();
        n = 0;
    }

    void reserve(size_t capacity)
    {
        // see: http://stackoverflow.com/questions/2745074/fast-ceiling-of-an-integer-division-in-c-c
        capacity = (capacity + CHUNK_SIZE - 1) / CHUNK_SIZE; // ceiling
        data.reserve(capacity);
    }

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
        data.back() |= (uintmax_t(value) << (n % CHUNK_SIZE));
        n++;
    }

    void push_back(size_t chunk, size_t count)
    {
        if (!isAligned())
            throw runtime_error("push_back chunk not implemented if bits are not aligned");

        data.push_back(chunk);
        n += count;
    }

    void pushFalse(size_t count)
    {
        // see: http://stackoverflow.com/questions/2745074/fast-ceiling-of-an-integer-division-in-c-c
        size_t oldCapacity = (n + CHUNK_SIZE - 1) / CHUNK_SIZE;         // ceiling
        size_t newCapacity = (n + count + CHUNK_SIZE - 1) / CHUNK_SIZE; // ceiling

        for (size_t i = 0; i < newCapacity - oldCapacity; i++) {
            data.push_back(0);
        }

        n += count;
    }

    void popBackChunk()
    {
        if (!isAligned())
            throw runtime_error("popBackChunk chunk not implemented if bits are not aligned");

        if (n < CHUNK_SIZE)
            throw runtime_error("insufficient number of elements to perform popBackChunk");

        data.pop_back();
        n -= CHUNK_SIZE;
    }

    bool at(size_t index) const
    {
        if (index >= n) {
            throw std::out_of_range("Bitset::at");
        }

        return (data[index / CHUNK_SIZE] >> (index % CHUNK_SIZE)) & 1;
    }

    uintmax_t atChunk(size_t index) const
    {
        if (index >= data.size()) {
            throw std::out_of_range("Bitset::atChunk");
        }

        return data[index];
    }

    size_t getSum() const
    {
        size_t result = 0;
        for (size_t i = 0; i < data.size(); i++) {
            result += countBits(data[i]);
        }
        return result;
    }

    const AlignedVector<uintmax_t>& getData() const
    { return data; }

    AlignedVector<uintmax_t>& getMutableData()
    { return data; }

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
    }

    void operator &= (const Bitset& other)
    {
        if (n != other.n) {
            throw std::invalid_argument("Bitset::operator&=: incompatible sizes");
        }
        for (size_t i = 0; i < data.size(); i++) {
            data[i] &= other.data[i];
        }
    }

    bool operator == (const Bitset& other) const
    { return (n == other.n) && (data == other.data); }

    bool operator != (const Bitset& other) const
    { return !(*this == other); }

    string toString() const
    {
        stringstream res;
        res << "[n=" << n << "]";
        for (size_t i = 0; i < n; ++i) {
            res << (at(i) + 0);
        }

        return res.str();
    }

    static inline size_t countBits(uintmax_t chunk)
    {
        //return popcount(chunk);                               // C++20 version
        return static_cast<uint8_t>(bitset<64>(chunk).count()); // C++98 version
    }

private:
    AlignedVector<uintmax_t> data;
    size_t n;
};
