#pragma once

#include <vector>
#include <iostream>
#include "../common.h"


template <TNorm TNORM>
class BitsetNumChain {
public:
    constexpr static size_t CHUNK_SIZE = 8 * sizeof(uintmax_t);
    constexpr static size_t ACCURACY = 8;
    constexpr static uintmax_t MAX_VALUE = (((uintmax_t) 1) << (ACCURACY - 1)) - 1;
    constexpr static uintmax_t CHUNK_MASK = (((uintmax_t) 1) << ACCURACY) - 1;
    constexpr static uintmax_t DBL_CHUNK_MASK = (CHUNK_MASK << ACCURACY) + CHUNK_MASK;
    constexpr static uintmax_t STEP = ((1UL << (2 * ACCURACY)) - 1) / ((1UL << (ACCURACY - 1)) - 1) - 1;

    BitsetNumChain()
        : data(),
          n(0),
          iMask(1)
    {
        iMask <<= (ACCURACY - 1);
        int j = 1;
        while (j * ACCURACY < CHUNK_SIZE) {
            iMask = iMask + (iMask << (j * ACCURACY));
            j <<= 1;
        }

        oneMask = iMask >> (ACCURACY - 1);
        data.push_back(0); // +1 to make room for shifts in sum()
    }

    BitsetNumChain(const NumericVector& vals)
        : BitsetNumChain()
    {
        reserve(vals.size());
        for (R_xlen_t i = 0; i < vals.size(); i++)
            push_back(vals.at(i));
    }

    void clear()
    {
        data.clear();
        data.push_back(0); // +1 to make room for shifts in sum()
        n = 0;
    }

    void reserve(size_t capacity)
    {
        data.reserve((capacity * ACCURACY + CHUNK_SIZE - 1) / CHUNK_SIZE + 1);
            // fast ceiling - see: http://stackoverflow.com/questions/2745074/fast-ceiling-of-an-integer-division-in-c-c
            // +1 to make room for shifts in sum()
    }

    size_t size() const
    { return n; }

    bool empty() const
    { return n == 0; }

    void push_back(float value)
    {
        size_t index = n * ACCURACY / CHUNK_SIZE;
        size_t shift = n * ACCURACY % CHUNK_SIZE;

        if (index == data.size() - 1) {
            // always need to have reserved +1 chunk for shifts in sum()
            data.push_back(0);
        }

        //value += 1.0 / (2.0 * MAX_VALUE);  // compensation of ceiling caused by typecasting to int (we want rounding instead)
        //if (value > 1) value = 1;
        //if (value < 0) value = 0;

        data[index] |= ((uintmax_t) (value * MAX_VALUE)) << shift;
        n++;
    }

    double at(size_t pos) const
    {
        if (pos >= n) {
            throw std::out_of_range("BitsetNumChain::at");
        }

        size_t index = pos * ACCURACY / CHUNK_SIZE;
        size_t shift = pos * ACCURACY % CHUNK_SIZE;

        //cout << endl << "index: " << index << ", shift: " << shift << ", data: " << data[index] << endl;
        //cout << "chunkmask: " << CHUNK_MASK << ", result: " << ((data[index] >> shift) & CHUNK_MASK) << endl;
        return 1.0 * ((data[index] >> shift) & CHUNK_MASK) / MAX_VALUE;
    }

    void conjunctWith(const BitsetNumChain& other);

    double getSum() const
    {
        // TODO: as constant
        uintmax_t mask = CHUNK_MASK;
        for (int shift = 1; shift < CHUNK_SIZE / 2; shift += ACCURACY) {
            mask = (mask << (2 * ACCURACY)) + CHUNK_MASK;
        }

        uintmax_t result = 0;
        uintmax_t tempOdd = 0;
        uintmax_t tempEven = 0;
        const uintmax_t* oddChain = data.data();
        const uintmax_t* evenChain = (uintmax_t*) (((uint8_t*) data.data()) + (ACCURACY / 8));

        int index = 0;
        while (index < data.size() - 1) {
            tempOdd = 0;
            tempEven = 0;

            int border;
            if (data.size() - 1 > index + STEP) {
                border = index + STEP;
            } else {
                border = data.size() - 1;
            }

            //TODO: mozna se to zrychli, kdyz ten for cyklus rozdelim na dva (intrinsics optimalilzace)
            for (; index < border; index++) {
                tempOdd += oddChain[index] & mask;
                tempEven += evenChain[index] & mask;
            }
            for (int shift = 0; shift < CHUNK_SIZE; shift += 2 * ACCURACY) {
                result += (tempOdd >> shift) & DBL_CHUNK_MASK;
                result += (tempEven >> shift) & DBL_CHUNK_MASK;
            }
        }

        return ((double) result) / ((double) MAX_VALUE);
    }

    vector<uintmax_t>& getMutableData()
    { return data; }

    bool operator == (const BitsetNumChain& other) const
    {
        if (n != other.n)
            return false;

        return data == other.data;
    }

    bool operator != (const BitsetNumChain& other) const
    { return !(*this == other); }

private:
    vector<uintmax_t> data;
    size_t n;
    uintmax_t iMask;
    uintmax_t oneMask;
};
