#include "dig/BitsetNumChain.h"


template <>
void BitsetNumChain<TNorm::GOEDEL>::conjunctWith(const BitsetNumChain<TNorm::GOEDEL>& other)
{
    if (n != other.n)
        throw std::invalid_argument("BitsetNumChain<GOEDEL>::conjunctWith: incompatible sizes");

    if (BitsetNumChain<GOEDEL>::ACCURACY != 8)
        throw std::runtime_error("BitsetNumChain<GOEDEL>::conjunctWith not implemented for ACCURACY != 8");

    const uintmax_t* a = data.data();
    const uintmax_t* b = other.data.data();
    vector<uintmax_t> res = data;

    for (size_t i = 0; i < data.size() - 1; i++) {
        res[i] = (a[i] - b[i]) & iMask;
        res[i] = res[i] | (res[i] >> 1);
        res[i] = res[i] | (res[i] >> 2);
        res[i] = res[i] | (res[i] >> 4);
        res[i] = (a[i] & res[i]) | (b[i] & ~(res[i]));
    }

    data = res;
}

template <>
void BitsetNumChain<TNorm::GOGUEN>::conjunctWith(const BitsetNumChain<TNorm::GOGUEN>& other)
{
    throw std::invalid_argument("unimplemented");
    if (n != other.n)
        throw std::invalid_argument("BitsetNumChain<GOGUEN>::conjunctWith: incompatible sizes");

    if (BitsetNumChain<GOGUEN>::ACCURACY != 8)
        throw std::runtime_error("BitsetNumChain<GOGUEN>::conjunctWith not implemented for ACCURACY != 8");
}

template <>
void BitsetNumChain<TNorm::LUKASIEWICZ>::conjunctWith(const BitsetNumChain<TNorm::LUKASIEWICZ>& other)
{
    if (n != other.n)
        throw std::invalid_argument("BitsetNumChain<LUKASIEWICZ>::conjunctWith: incompatible sizes");

    if (BitsetNumChain<LUKASIEWICZ>::ACCURACY != 8)
        throw std::runtime_error("BitsetNumChain<LUKASIEWICZ>::conjunctWith not implemented for ACCURACY != 8");

    const uintmax_t* a = data.data();
    const uintmax_t* b = other.data.data();
    vector<uintmax_t> res = data;
    uintmax_t themask;

    for (size_t i = 0; i < data.size() - 1; i++) {
        res[i] = (a[i] + b[i]);
        themask = res[i] & iMask;
        themask = themask | (themask >> 1);
        themask = themask | (themask >> 2);
        themask = themask | (themask >> 3);
        themask >>= 1;
        res[i] = (res[i] + oneMask) & themask;
    }

    data = res;
}
