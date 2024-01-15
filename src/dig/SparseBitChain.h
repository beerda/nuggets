#pragma once

#include <utility>
#include <algorithm>

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

    void push_back(bool value, const size_t count)
    {
        for (size_t i = 0; i < count; ++i) {
            push_back(value);
        }
    }

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

    size_t getTrailing() const
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

    void conjunctWith(const SparseBitChain& other)
    {
        Iter iter1(this);
        Iter iter2(&other);

        vector<size_t> newGaps;
        vector<Bitset> newBitsets;

        size_t newGap = 0;
        size_t newSum = 0;

        while (iter1.hasGapsOrBits() && iter2.hasGapsOrBits()) {
            // iter1 would be always the one with greater gap
            if (iter1.remainingGap() < iter2.remainingGap()) {
                swap(iter1, iter2);
            }

            // process the gap
            size_t inc = iter1.remainingGap();
            if (inc > 0) {
                iter1.increment(inc);
                iter2.increment(inc);
                newGap += inc;
                continue;
            }

            if (iter1.remainingGap() != 0 || iter2.remainingGap() != 0)
                throw new runtime_error("assertion failed: gaps must be 0");

            size_t newChunks = min(iter1.remainingChunks(), iter2.remainingChunks());
            Bitset newBitset(min(iter1.remainingBits(), iter2.remainingBits()));
            for (size_t i = 0; i < newChunks; ++i) {
                newBitset.getMutableData()[i] = iter1.chunk(i) & iter2.chunk(i);
            }

            // For the very last bitset, it may happen that newChunks * CHUNK_SIZE
            // would be greater than newBitset.size(), but that is ok, since we are in the end.
            // This discrepancy gets fixed in Iter::remainingTrailing().
            newGaps.push_back(newGap);
            newBitsets.push_back(newBitset);
            newSum += newBitset.getSum();

            iter1.increment(newChunks);
            iter2.increment(newChunks);
            newGap = 0;
        }

        gaps = newGaps;
        bitsets = newBitsets;
        cachedSum = 1.0 * newSum;
        nTrailing = iter1.hasGapsOrBits() ? iter2.remainingTrailing() : iter1.remainingTrailing();
    }

private:
    class Iter {
    public:
        const SparseBitChain* chain;
        size_t index;
        size_t offset;

        Iter(const SparseBitChain* theChain)
            : chain(theChain), index(0), offset(0)
        { }

        bool hasGapsOrBits() const
        { return index < chain->gaps.size(); }

        size_t remainingGap() const
        { return max((size_t) 0, chain->gaps[index] - offset); }

        size_t remainingChunks() const
        { return max((size_t) 0, chain->bitsets[index].nChunks() - offset); }

        size_t remainingBits() const
        { return max((size_t) 0, chain->bitsets.size() - offset * Bitset::CHUNK_SIZE); }

        size_t remainingTrailing() const
        {
            size_t res = chain->getTrailing() - offset * Bitset::CHUNK_SIZE;
            if (!chain->bitsets.empty()) {
                // last bitset's number of bits may not be divisible by CHUNK_SIZE, hence
                // the offset may be smaller. We must return to the offset what was taken.
                res += chain->bitsets.back().nChunks() * Bitset::CHUNK_SIZE -
                    chain->bitsets.back().size();
            }
            return res;
        }

        size_t chunk(size_t i) const
        { return chain->bitsets[index].getData()[i + offset]; }

        void increment(size_t i)
        {
            offset += i;
            while (hasGapsOrBits()) {
                size_t newOffset = offset - chain->gaps[index] - chain->bitsets[index].nChunks();
                if (newOffset >= 0) {
                    offset = newOffset;
                    index++;
                } else {
                    break;
                }
            }
        }
    };

    vector<size_t> gaps;
    vector<Bitset> bitsets;
    float cachedSum;
    size_t n;         // the total number of bits stored in the chain
    size_t nTrailing; // the number of trailing FALSE bits that were silently ignored
};
