#pragma once

#include "../common.h"
#include "../AlignedVector.h"


typedef uintmax_t BASE_TYPE;
typedef AlignedVector<BASE_TYPE> BitwiseVector;


template <unsigned int BLSIZE>
class BitwiseFuzzyChainBase1 {
public:
    // number of bits in a single block
    constexpr static size_t BLOCK_SIZE = BLSIZE;

    // number of bits in the whole integer
    constexpr static size_t INTEGER_SIZE = 8 * sizeof(BASE_TYPE);

    // maximum unsigned number to be stored in a value bits of a block
    // (the overflow bit (i.e. the hightest bit) must remain empty
    constexpr static BASE_TYPE MAX_VALUE = (((BASE_TYPE) 1) << (BLOCK_SIZE - 1)) - 1;

    // bit mask of the first block of bits within the integer
    constexpr static BASE_TYPE BLOCK_MASK = (((BASE_TYPE) 1) << BLOCK_SIZE) - 1;

    // bit mask of first two blocks of bits within the integer
    constexpr static BASE_TYPE DBL_BLOCK_MASK = (BLOCK_MASK << BLOCK_SIZE) + BLOCK_MASK;

    constexpr static BASE_TYPE STEP = ((1UL << (2 * BLOCK_SIZE)) - 1) / ((1UL << (BLOCK_SIZE - 1)) - 1) - 1;

    static const float LOG_BASE;


    BitwiseFuzzyChainBase1()
        : data(), n(0)
    {
        data.push_back(0); // +1 to make room for shifts in getSum()

        overflowMask = 1 << (BLOCK_SIZE - 1);
        for (size_t j = 1; j * BLOCK_SIZE < INTEGER_SIZE; j <<= 1) {
            overflowMask = overflowMask + (overflowMask << (j * BLOCK_SIZE));
        }
        negOverflowMask = ~overflowMask;
    }

    void clear()
    {
        data.clear();
        data.push_back(0); // +1 to make room for shifts in getSum()
        n = 0;
    }

    void reserve(size_t capacity)
    {
        data.reserve(1 + UNSIGNED_CEILING(capacity * BLOCK_SIZE, INTEGER_SIZE)); // +1 to make room for shifts in getSum()
    }

    size_t size() const
    { return n; }

    bool empty() const
    { return n == 0; }

    float at(size_t pos) const;

    BitwiseVector& getMutableData()
    { return data; }

    bool operator == (const BitwiseFuzzyChainBase1& other) const
    {
        if (n != other.n)
            return false;

        return data == other.data;
    }

    bool operator != (const BitwiseFuzzyChainBase1& other) const
    { return !(*this == other); }

protected:
    BitwiseVector data;
    size_t n;
    BASE_TYPE overflowMask;
    BASE_TYPE negOverflowMask;

    void internalPushBack(BASE_TYPE value)
    {
        size_t index = n * BLOCK_SIZE / INTEGER_SIZE;
        size_t shift = n * BLOCK_SIZE % INTEGER_SIZE;

        if (index == data.size() - 1) {
            // always need to have reserved +1 integer for shifts in getSum()
            data.push_back(0);
        }

        data[index] |= value << shift;
        n++;
    }

    BASE_TYPE internalAt(size_t pos) const
    {
        if (pos >= n) {
            throw std::out_of_range("BitwiseFuzzyChain::at");
        }

        size_t index = pos * BLOCK_SIZE / INTEGER_SIZE;
        size_t shift = pos * BLOCK_SIZE % INTEGER_SIZE;

        //cout << endl << "index: " << index << ", shift: " << shift << ", data: " << data[index] << endl;
        //cout << "chunkmask: " << BLOCK_MASK << ", result: " << ((data[index] >> shift) & BLOCK_MASK) << endl;
        return 1.0 * ((data[index] >> shift) & BLOCK_MASK);
    }

    BASE_TYPE internalSum() const
    {
        // TODO: as constant
        BASE_TYPE mask = BLOCK_MASK;
        for (size_t shift = 1; shift < INTEGER_SIZE / 2; shift += BLOCK_SIZE) {
            mask = (mask << (2 * BLOCK_SIZE)) + BLOCK_MASK;
        }

        BASE_TYPE result = 0;
        BASE_TYPE tempOdd = 0;
        BASE_TYPE tempEven = 0;
        const BASE_TYPE* oddChain = data.data();
        const BASE_TYPE* evenChain = (BASE_TYPE*) (((uint8_t*) data.data()) + (BLOCK_SIZE / 8));

        size_t index = 0;
        while (index < data.size() - 1) {
            tempOdd = 0;
            tempEven = 0;

            size_t border;
            if (data.size() - 1 > index + STEP) {
                border = index + STEP;
            } else {
                border = data.size() - 1;
            }

            //TODO: mozna se to zrychli, kdyz ten for cyklus rozdelim na dva (intrinsics optimalizace)
            for (; index < border; index++) {
                tempOdd += oddChain[index] & mask;
                tempEven += evenChain[index] & mask;
            }
            for (size_t shift = 0; shift < INTEGER_SIZE; shift += 2 * BLOCK_SIZE) {
                result += (tempOdd >> shift) & DBL_BLOCK_MASK;
                result += (tempEven >> shift) & DBL_BLOCK_MASK;
            }
        }

        return result;
    }
};


template <unsigned int BLSIZE>
class BitwiseFuzzyChainBase2 : public BitwiseFuzzyChainBase1<BLSIZE> {
};


template <>
class BitwiseFuzzyChainBase2<4> : public BitwiseFuzzyChainBase1<4> {
protected:
    inline BASE_TYPE internalCloneBits(BASE_TYPE value) const
    {
        BASE_TYPE res = value & overflowMask;
        res = res | (res >> 1);
        res = res | (res >> 2);

        return res;
    }
};


template <>
class BitwiseFuzzyChainBase2<8> : public BitwiseFuzzyChainBase1<8> {
protected:
    inline BASE_TYPE internalCloneBits(BASE_TYPE value) const
    {
        BASE_TYPE res = value & overflowMask;
        res = res | (res >> 1);
        res = res | (res >> 2);
        res = res | (res >> 4);

        return res;
    }
};


template <unsigned int BLSIZE, TNorm TNORM>
class BitwiseFuzzyChain : public BitwiseFuzzyChainBase2<BLSIZE> {
};


template <unsigned int BLSIZE>
class BitwiseFuzzyChain<BLSIZE, TNorm::GOEDEL> : public BitwiseFuzzyChainBase2<BLSIZE> {
public:
    void pushBack(float value)
    { this->internalPushBack((BASE_TYPE) (value * this->MAX_VALUE)); }

    float at(size_t pos) const
    { return 1.0 * this->internalAt(pos) / this->MAX_VALUE; }

    float getSum() const
    { return ((float) this->internalSum()) / ((float) this->MAX_VALUE); }

    void conjunctWith(const BitwiseFuzzyChain<BLSIZE, TNorm::GOEDEL>& other)
    {
        if (this->n != other.n)
            throw std::invalid_argument("BitwiseFuzzyChain<GOEDEL>::conjunctWith: incompatible sizes");

        const BASE_TYPE* a = this->data.data();
        const BASE_TYPE* b = other.data.data();
        BitwiseVector res = this->data;

        for (size_t i = 0; i < this->data.size() - 1; i++) {
            BASE_TYPE s = this->internalCloneBits(a[i] - b[i]);
            res[i] = (a[i] & s) | (b[i] & ~s);
        }

        this->data = res;
    }
};


template <unsigned int BLSIZE>
class BitwiseFuzzyChain<BLSIZE, TNorm::LUKASIEWICZ> : public BitwiseFuzzyChainBase2<BLSIZE> {
public:
    void pushBack(float value)
    { this->internalPushBack((BASE_TYPE) ((1.0 - value) * this->MAX_VALUE)); }

    float at(size_t pos) const
    { return 1.0 - 1.0 * this->internalAt(pos) / this->MAX_VALUE; }

    float getSum() const
    { return this->size() - ((float) this->internalSum()) / ((float) this->MAX_VALUE); }

    void conjunctWith(const BitwiseFuzzyChain<BLSIZE, TNorm::LUKASIEWICZ>& other)
    {
        if (this->n != other.n)
            throw std::invalid_argument("BitwiseFuzzyChain<GOEDEL>::conjunctWith: incompatible sizes");

        const BASE_TYPE* a = this->data.data();
        const BASE_TYPE* b = other.data.data();
        BitwiseVector res = this->data;

        for (size_t i = 0; i < this->data.size() - 1; i++) {
            BASE_TYPE s = this->internalCloneBits(a[i] - b[i]);
            res[i] = (a[i] & s) | (b[i] & ~s);
        }

        this->data = res;
    }
};


template <unsigned int BLSIZE>
class BitwiseFuzzyChain<BLSIZE, TNorm::GOGUEN> : public BitwiseFuzzyChainBase2<BLSIZE> {
public:
    static constexpr float LOG_BASE = pow(1.0 * BitwiseFuzzyChainBase1<BLSIZE>::MAX_VALUE, (-1.0) / (BitwiseFuzzyChainBase1<BLSIZE>::MAX_VALUE - 1));

    void pushBack(float value)
    {
        static float reciprocal = 1.0 / this->MAX_VALUE;
        static float logLogBase = log(LOG_BASE);

        this->internalPushBack((value <= reciprocal) ? this->MAX_VALUE : round(log(value) / logLogBase));
    }

    float at(size_t pos) const
    {
        BASE_TYPE val = this->internalAt(pos);

        return (val >= this->MAX_VALUE) ? 0.0 : pow(LOG_BASE, val);
    }

    float getSum() const
    {
        float result = 0.0;
        for (size_t i = 0; i < this->size(); ++i)
            result += at(i);

        return result;
    }

    void conjunctWith(const BitwiseFuzzyChain<BLSIZE, TNorm::GOGUEN>& other)
    {
        if (this->n != other.n)
            throw std::invalid_argument("BitwiseFuzzyChain<GOGUEN>::conjunctWith: incompatible sizes");

        const BASE_TYPE* a = this->data.data();
        const BASE_TYPE* b = other.data.data();
        BitwiseVector res = this->data;
        BASE_TYPE themask;
        for (size_t i = 0; i < this->data.size() - 1; i++) {
            BASE_TYPE sum = (a[i] + b[i]);
            BASE_TYPE s = this->internalCloneBits(sum);
            res[i] = (sum | s) & this->negOverflowMask;
        }

        this->data = res;
    }
};


template <TNorm TNORM>
class BitwiseFuzzyChain8 : public BitwiseFuzzyChain<8, TNORM> {
public:
    BitwiseFuzzyChain8() : BitwiseFuzzyChain<8, TNORM>()
    { }

    BitwiseFuzzyChain8(const NumericVector& vals)
        : BitwiseFuzzyChain8()
    {
        this->reserve(vals.size());
        for (R_xlen_t i = 0; i < vals.size(); i++)
            this->pushBack(vals.at(i));
    }

};
