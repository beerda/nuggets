#pragma once

#include <vector>
#include <xsimd/memory/xsimd_aligned_allocator.hpp>


/*
 * 128bit operations (SSE2) - align by 16
 * 256bit operations (AVX2) - align by 32
 * 512bit operations (AVX512) - align by 64
 */
template <typename TYPE>
using AlignedVector = std::vector<TYPE, xsimd::aligned_allocator<TYPE, 64>>;
