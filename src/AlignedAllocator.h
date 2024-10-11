#pragma once

#include <memory>
#include <stdlib.h>

// A minimal implementation of an allocator for C++ Standard Library, which
// allocates aligned memory (specified by the alignment argument).
// Note:
//    A minimal custom allocator is preferred because C++ allocator_traits class
//    provides default implementation for you. Take a look at Microsoft's
//    documentation about Allocators and allocator class.
template <typename T, std::size_t alignment> class AlignedAllocator {
public:
    using value_type = T;

public:
    // According to Microsoft's documentation, default constructor is not required
    // by C++ Standard Library.
    AlignedAllocator() noexcept {};

    template <typename U> AlignedAllocator(const AlignedAllocator<U, alignment>& other) noexcept {};

    template <typename U>
    inline bool operator==(const AlignedAllocator<U, alignment>& other) const noexcept {
        return true;
    }

    template <typename U>
    inline bool operator!=(const AlignedAllocator<U, alignment>& other) const noexcept {
        return false;
    }

    template <typename U> struct rebind {
        using other = AlignedAllocator<U, alignment>;
    };

    // STL containers call this function to allocate uninitialized memory block to
    // store (no more than n) elements of type T (value_type).
    inline value_type* allocate(const std::size_t n) const {
        auto size = n;
        /*
         If you wish, for some strange reason, that the size of allocated buffer is
         also aligned to alignment, uncomment the following statement.

         Note: this increases the size of underlying memory, but STL containers
         still treat it as a memory block of size n, i.e., STL containers will not
         put more than n elements into the returned memory.
         */
        // size = (n + alignment - 1) / alignment * alignment;
        value_type* ptr;
        auto ret = posix_memalign((void**)&ptr, alignment, sizeof(T) * size);
        if (ret != 0)
            throw std::bad_alloc();
        return ptr;
    };

    // STL containers call this function to free a memory block beginning at a
    // specified position.
    inline void deallocate(value_type* const ptr, std::size_t n) const noexcept { free(ptr); }
};
