#include "dig/BitsetNumChain.h"


template <>
void BitsetNumChain<TNorm::GODEL>::conjunctWith(const BitsetNumChain<TNorm::GODEL>& other)
{
    if (n != other.n)
        throw std::invalid_argument("BitsetNumChain::conjunctWith: incompatible sizes");

    if (BitsetNumChain<GODEL>::ACCURACY != 8)
        throw std::runtime_error("BitsetNumChain::conjunctWith not implemented for ACCURACY != 8");

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
