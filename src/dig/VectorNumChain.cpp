#include "dig/VectorNumChain.h"


template <>
void VectorNumChain<TNorm::GOGUEN>::conjunctWith(const VectorNumChain<TNorm::GOGUEN>& other)
{
    cachedSum = 0;
    for (size_t i = 0; i < values.size(); i++) {
        values[i] *= other.values[i];
        cachedSum += values[i];
    }
}
