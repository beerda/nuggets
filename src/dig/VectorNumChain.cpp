#include <algorithm>
#include "dig/VectorNumChain.h"


template <>
void VectorNumChain<TNorm::GOEDEL>::conjunctWith(const VectorNumChain<TNorm::GOEDEL>& other)
{
    if (values.size() != other.values.size()) {
        throw std::invalid_argument("VectorNumChain::conjunctWith: incompatible sizes");
    }

    cachedSum = 0;
    for (size_t i = 0; i < values.size(); i++) {
        values[i] = min(values[i], other.values[i]);
        cachedSum += values[i];
    }
}

template <>
void VectorNumChain<TNorm::GOGUEN>::conjunctWith(const VectorNumChain<TNorm::GOGUEN>& other)
{
    if (values.size() != other.values.size()) {
        throw std::invalid_argument("VectorNumChain::conjunctWith: incompatible sizes");
    }

    cachedSum = 0;
    for (size_t i = 0; i < values.size(); i++) {
        values[i] *= other.values[i];
        cachedSum += values[i];
    }
}

template <>
void VectorNumChain<TNorm::LUKASIEWICZ>::conjunctWith(const VectorNumChain<TNorm::LUKASIEWICZ>& other)
{
    if (values.size() != other.values.size()) {
        throw std::invalid_argument("VectorNumChain::conjunctWith: incompatible sizes");
    }

    cachedSum = 0;
    for (size_t i = 0; i < values.size(); i++) {
        values[i] = max(0.0, values[i] + other.values[i] - 1);
        cachedSum += values[i];
    }
}
