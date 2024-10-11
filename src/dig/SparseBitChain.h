#pragma once

#include <utility>
#include <algorithm>
#include<unistd.h>

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
            if (nTrailing > Bitset::CHUNK_SIZE || gaps.size() == 0) {
                // process trailing by adding a new gap OR initialize empty vectors of gaps and bitsets
                gaps.push_back(nTrailing / Bitset::CHUNK_SIZE);
                bitsets.push_back(Bitset());
                nTrailing = nTrailing % Bitset::CHUNK_SIZE;
            }
            if (nTrailing > 0) {
                // push remaining trailing FALSE bits
                bitsets.back().pushFalse(nTrailing);
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

    string toString() const
    {
        stringstream res;
        for (size_t i = 0; i < gaps.size(); ++i) {
            res << "[" << i << "]: gap=" << gaps[i] << " bitset=" << bitsets[i].toString() + "\n";
        }
        res << "[*]: trailing=" << nTrailing;

        return res.str();
    }

    void conjunctWith(const SparseBitChain& other)
    {
        Iter iter1(this);
        Iter iter2(&other);

        vector<size_t> newGaps;
        vector<Bitset> newBitsets;

        size_t newGap = 0;
        size_t hold = 0;
        size_t newSum = 0;

        while (iter1.hasGapsOrBits() && iter2.hasGapsOrBits()) {
            //cout << "jetu1\n";
            //cout << "iter1 index=" << iter1.index << " offset=" << iter1.offset << " remGap=" << iter1.remainingGap() << endl;
            //cout << "iter2 index=" << iter2.index << " offset=" << iter2.offset << " remGap=" << iter2.remainingGap() << endl;

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

            //cout << "jetu3\n";
            if (iter1.remainingGap() != 0 || iter2.remainingGap() != 0) {
                //cout << "assertion failed: gaps must be 0" << endl;
                throw runtime_error("assertion failed: gaps must be 0");
            }

            size_t newChunks = min(iter1.remainingChunks(), iter2.remainingChunks());
            Bitset newBitset;
            newBitset.reserve(newChunks * Bitset::CHUNK_SIZE);

            size_t remainingBits = min(iter1.remainingBits(), iter2.remainingBits()) % Bitset::CHUNK_SIZE;
            if (remainingBits == 0)
                remainingBits = Bitset::CHUNK_SIZE;

            size_t hold = 0;
            bool beginning = true;
            for (size_t i = 0; i < newChunks; ++i) {
                size_t conj = iter1.chunk(i) & iter2.chunk(i);
                if (conj == 0) {
                    if (beginning) {
                        newGap++;
                    } else {
                        hold += (i == newChunks - 1) ? remainingBits : Bitset::CHUNK_SIZE;
                    }
                } else {
                    beginning = false;
                    newBitset.pushFalse(hold);
                    newBitset.push_back(conj, (i == newChunks - 1) ? remainingBits : Bitset::CHUNK_SIZE);
                    hold = 0;
                }
            }

            // For the very last bitset, it may happen that newChunks * CHUNK_SIZE
            // would be greater than newBitset.size(), but that is ok, since we are in the end.
            // This discrepancy gets fixed in Iter::remainingTrailing().

            if (!newBitset.empty()) {
                newGaps.push_back(newGap);
                newBitsets.push_back(newBitset);
                newSum += newBitset.getSum();
                newGap = 0;
            }

            iter1.increment(newChunks);
            iter2.increment(newChunks);
            newGap += hold / Bitset::CHUNK_SIZE;
            hold = hold % Bitset::CHUNK_SIZE; // passed out of the loop. if loop continues, hold is always 0
        }

        hold += newGap * Bitset::CHUNK_SIZE;
        gaps = newGaps;
        bitsets = newBitsets;
        cachedSum = 1.0 * newSum;
        nTrailing = iter1.hasGapsOrBits() ? iter2.remainingTrailing(hold) : iter1.remainingTrailing(hold);
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
        { return chain->gaps[index] < offset ? 0 : chain->gaps[index] - offset; }

        size_t bitsetOffset() const
        {
            if (offset < chain->gaps[index]) {
                //cout << "assertion failed in bitsetOffset()" << endl;
                throw runtime_error("assertion failed in bitsetOffset()");
            }

            return offset - chain->gaps[index];
        }

        size_t remainingChunks() const
        {
            //return chain->bitsets[index].nChunks() < bitsetOffset() ? 0 :
                //chain->bitsets[index].nChunks() - bitsetOffset();
            if (chain->bitsets[index].nChunks() < bitsetOffset()) {
                //cout << "assertion failed in remainingChunks()" << endl;
                throw runtime_error("assertion failed in remainingChunks()");
            }


            return chain->bitsets[index].nChunks() - bitsetOffset();
        }

        size_t remainingBits() const
        {
            //return chain->bitsets[index].size() < bitsetOffset() * Bitset::CHUNK_SIZE ? 0 :
                //chain->bitsets[index].size() - bitsetOffset() * Bitset::CHUNK_SIZE;
            if (chain->bitsets[index].size() < bitsetOffset() * Bitset::CHUNK_SIZE) {
                //cout << "assertion failed in remainingBits()" << endl;
                throw runtime_error("assertion failed in remainingBits()");
            }

            return chain->bitsets[index].size() - bitsetOffset() * Bitset::CHUNK_SIZE;
        }

        size_t remainingTrailing(size_t hold) const
        {
            if (hold + chain->getTrailing() < offset * Bitset::CHUNK_SIZE) {
                //cout << "assertion failed in remainingTrailing()" << endl;
                throw runtime_error("assertion failed in remainingTrailing()");
            }

            size_t res = hold + chain->getTrailing() - offset * Bitset::CHUNK_SIZE;
            if (!chain->bitsets.empty()) {
                // last bitset's number of bits may not be divisible by CHUNK_SIZE, hence
                // the offset may be smaller. We must return to the offset what was taken.
                res += chain->bitsets.back().nChunks() * Bitset::CHUNK_SIZE;
                res -= chain->bitsets.back().size();
            }
            return res;
        }

        size_t chunk(size_t i) const
        { return chain->bitsets[index].getData()[i + bitsetOffset()]; }

        void increment(size_t i)
        {
            //cout << "incrementing " << offset << "+" << i << "(index=" << index << ")" << endl;
            offset += i;
            while (hasGapsOrBits()) {
                size_t skip = chain->gaps[index] + chain->bitsets[index].nChunks();
                if (offset >= skip) {
                    offset -= skip;
                    index++;
                    //cout << "offset=" << offset << "(index=" << index << ")" << endl;
                } else {
                    break;
                }
            }
            //cout << "exiting offset=" << offset << "(index=" << index << ")" << endl;
        }
    };

    vector<size_t> gaps;
    vector<Bitset> bitsets;
    float cachedSum;
    size_t n;         // the total number of bits stored in the chain
    size_t nTrailing; // the number of trailing FALSE bits that were silently ignored
};
