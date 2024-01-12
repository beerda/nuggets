#pragma once

#include <vector>
#include <bitset>
#include "../common.h"


/**
 * A growable array of bits.
 */
class Bitset {
public:
    constexpr static size_t CHUNK_SIZE = 8 * sizeof(uintmax_t);

    Bitset()
        : data(), n(0)
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

    bool empty() const
    { return n == 0; }

    void push_back(bool value)
    {
        if (n % CHUNK_SIZE == 0) {
            data.push_back(0);
        }
        data.back() |= (uintmax_t(value) << (n % CHUNK_SIZE));
        n++;
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

    bool at(size_t index) const
    {
        if (index >= n) {
            throw std::out_of_range("Bitset::at");
        }

        return (data[index / CHUNK_SIZE] >> (index % CHUNK_SIZE)) & 1;
    }

    size_t getSum() const
    {
        size_t result = 0;
        for (size_t i = 0; i < data.size(); i++) {
            //result += popcount(data[i]);                               // C++20 version
            result += static_cast<uint8_t>(bitset<64>(data[i]).count()); // C++98 version
        }
        return result;
    }

    vector<uintmax_t>& getMutableData()
    { return data; }

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

private:
    vector<uintmax_t> data;
    size_t n;
};
