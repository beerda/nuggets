#pragma once

#include <vector>
#include "AlignedAllocator.h"


template <typename TYPE>
using AlignedVector = std::vector<TYPE, AlignedAllocator<TYPE, 512>>;
