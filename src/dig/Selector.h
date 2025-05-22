#pragma once

#include "../common.h"


class Selector {
public:
    Selector(const size_t size, const bool constantlyTrue)
        : n(size), selectedCount(size), pruned(nullptr)
    {
        if (!constantlyTrue) {
            pruned = new bool[size](); // Initialize to false
        }
    }

    // Move constructor
    Selector(Selector&& other)
        : n(other.n), selectedCount(other.selectedCount), pruned(other.pruned)
    {
        cout << "moving1\n";
        other.n = 0;
        other.selectedCount = 0;
        other.pruned = nullptr;
    }


    // Move assignment operator
    Selector& operator=(Selector&& other)
    {
        cout << "moving2\n";
        if (this != &other) {
            if (pruned) {
                delete[] pruned;
            }
            n = other.n;
            selectedCount = other.selectedCount;
            pruned = other.pruned;

            other.n = 0;
            other.selectedCount = 0;
            other.pruned = nullptr;
        }

        return *this;
    }

    ~Selector()
    {
        if (pruned) {
            delete[] pruned;
        }
    }

    // Disable copy
    Selector(const Selector&) = delete;
    Selector& operator=(const Selector&) = delete;

    void unselect(const size_t index)
    {
        if (pruned == nullptr) {
            throw invalid_argument("Selector: uninitialized selector");
        }
        if (!pruned[index]) {
            selectedCount--;
        }
        pruned[index] = true;
    }

    bool isSelected(const size_t index) const
    {
        if (pruned == nullptr) {
            return true;
        }
        return !pruned[index];
    }

    size_t size() const
    { return n; }

    size_t getSelectedCount() const
    { return selectedCount; }

private:
    size_t n;
    size_t selectedCount;
    bool* pruned;
};
