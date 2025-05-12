#pragma once

#include <vector>
#include "AlignedAllocator.h"


/*
 * 128bit operations (SSE2) - align by 16
 * 256bit operations (AVX2) - align by 32
 * 512bit operations (AVX512) - align by 64
 */
template <typename TYPE>
using AlignedVector = std::vector<TYPE, AlignedAllocator<TYPE, 32>>;
