#pragma once

#include "../common.h"
#include "Bitset.h"


class PackedBitChain {
public:
    PackedBitChain()
        : n(0), cachedSum(0)
    { }

    PackedBitChain(const LogicalVector& vals)
        : n(0), cachedSum(0)
    {
        for (R_xlen_t i = 0; i < vals.size(); i++)
            push_back(vals.at(i));
    }

    void clear()
    {
        values.clear();
        cachedSum = 0;
    }

    void push_back(bool value)
    {
        if (values.isAligned()) {
            counts.push_back(1);
        }

        values.push_back(value);
        cachedSum += value;
        n++;

        size_t i = counts.size();
        if (values.isAligned() && i > 1) {
            if (values.atChunk(i - 1) == values.atChunk(i - 2)) {
                values.popBackChunk();
                counts[i - 2] += counts[i - 1];
                counts.pop_back();
            }
        }
    }

    void negate()
    {
        values.negate();
        cachedSum = size() - cachedSum;
    }

    void conjunctWith(const PackedBitChain& other)
    {
        if (size() != other.size())
            throw std::invalid_argument("PackedBitChain::conjunctWith: incompatible sizes");

        if (empty())
            return;

        Iter first(this);
        Iter second(&other);
        AlignedVector<uintmax_t> resultData;
        vector<size_t> resultCounts;
        size_t resultCachedSum = 0;

        while (!first.isEnd()) {
            uintmax_t newChunk = first.currentChunk() & second.currentChunk();
            size_t newCount = min(first.currentCountRemaining(), second.currentCountRemaining());
            resultData.push_back(newChunk);
            resultCounts.push_back(newCount);
            resultCachedSum += Bitset::countBits(newChunk) * newCount;
            first.increment(newCount);
            second.increment(newCount);
        }

        size_t bitsetN = values.isAligned()
            ? resultData.size() * Bitset::CHUNK_SIZE
            : (resultData.size() - 1) * Bitset::CHUNK_SIZE + n % Bitset::CHUNK_SIZE;
        values = Bitset(resultData, bitsetN);
        counts = resultCounts;
        cachedSum = resultCachedSum;
    }


    size_t size() const
    { return n; }

    size_t sizeChunks() const
    { return counts.size(); }

    bool empty() const
    { return values.empty(); }

    float getSum() const
    { return 1.0 * cachedSum; }

    bool at(size_t i) const
    {
        size_t ii = i / Bitset::CHUNK_SIZE;
        size_t sum = 0;
        size_t k = 0;
        for (; k < counts.size(); k++) {
            if (sum <= ii && ii < sum + counts[k])
                break;

            sum += counts[k];
        }

        return values.at(k * Bitset::CHUNK_SIZE + i % Bitset::CHUNK_SIZE);
    }

private:
    size_t n;
    Bitset values;
    vector<size_t> counts;
    size_t cachedSum;

    struct Iter {
        Iter(const PackedBitChain* chain)
            : chain(chain), chunkIndex(0), chunkOffset(0)
        { }

        size_t currentCountRemaining() const
        { return chain->counts[chunkIndex] - chunkOffset; }

        uintmax_t currentChunk() const
        { return chain->values.atChunk(chunkIndex); }

        void increment(size_t count)
        {
            chunkOffset += count;
            if (chunkOffset >= chain->counts[chunkIndex]) {
                chunkOffset -= chain->counts[chunkIndex];
                chunkIndex++;
            }
        }

        bool isEnd() const
        { return chunkIndex >= chain->counts.size(); }

        const PackedBitChain* chain;
        size_t chunkIndex;
        size_t chunkOffset;
    };
};
