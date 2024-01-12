#pragma once

#include "../common.h"
#include "Bitset.h"


/**
 * Implementation of sparse chain of bits based on the Bitset class.
 *
 * Bits are stored in chunks of 64 bits. Sparse bit chain is a sequence of pairs (gap, bitset) Gap is the number
 * of chunks, whose bits are all 0. Bitset is an array of chunks with bit values.
 */
class SparseBitChain {
public:
    SparseBitChain()
        : cachedSum(0), n(0), nTrailing(0)
    { }

    SparseBitChain(const LogicalVector& vals)
        : cachedSum(0), n(0), nTrailing(0)
    {
        for (R_xlen_t i = 0; i < vals.size(); i++)
            push_back(vals.at(i));
    }

    void clear()
    {
        gaps.clear();
        bitsets.clear();
        cachedSum = 0;
        n = 0;
        nTrailing = 0;
    }

    void push_back(bool value)
    {
        if (value) {
            if (nTrailing > 0 || gaps.size() == 0) {
                // process trailing by adding a new gap OR initialize empty vectors of gaps and bitsets
                gaps.push_back(nTrailing / Bitset::CHUNK_SIZE);
                bitsets.push_back(Bitset());
                bitsets.back().pushFalse(nTrailing % Bitset::CHUNK_SIZE);
                nTrailing = 0;
            }
            bitsets.back().push_back(value);
            cachedSum++;

        } else {
            if (nTrailing > 0 || n % Bitset::CHUNK_SIZE == 0) {
                // we have full bitset, so silently ignore all trailing FALSE bits
                nTrailing++;
            } else {
                bitsets.back().push_back(value);
            }
        }

        n++;
    }

    void conjunctWith(const SparseBitChain& other)
    { throw new runtime_error("Implement me"); }

    size_t size() const
    { return n; }

    bool empty() const
    { return n == 0; }

    float getSum() const
    { return cachedSum; }

    bool at(size_t index) const
    {
        if (index >= n) {
            throw std::out_of_range("SparseBitChain::at");
        }

        size_t i = 0;
        for (; i < gaps.size(); ++i) {
            size_t len = gaps[i] * Bitset::CHUNK_SIZE + bitsets[i].size();
            if (index < len)
                break;

            index -= len;
        }

        if (i >= gaps.size())
            return false; // trailing FALSE bit

        if (index < gaps[i] * Bitset::CHUNK_SIZE)
            return false; // gap FALSE bit

        index -= gaps[i] * Bitset::CHUNK_SIZE;

        return bitsets[i].at(index);
    }

    const vector<size_t>& getGaps() const
    { return gaps; }

    const vector<Bitset>& getBitsets() const
    { return bitsets; }

    size_t getTrailing()
    { return nTrailing; }

    bool operator == (const SparseBitChain& other) const
    {
        return (n == other.n) &&
            (nTrailing == other.nTrailing) &&
            (gaps == other.gaps) &&
            (bitsets == other.bitsets);
    }

    bool operator != (const SparseBitChain& other) const
    { return !(*this == other); }

private:
    vector<size_t> gaps;
    vector<Bitset> bitsets;
    float cachedSum;
    size_t n;         // the total number of bits stored in the chain
    size_t nTrailing; // the number of trailing FALSE bits that were silently ignored
};
