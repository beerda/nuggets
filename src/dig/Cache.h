/**********************************************************************
 * nuggets: An R framework for exploration of patterns in data
 * Copyright (C) 2025 Michal Burda
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program. If not, see <https://www.gnu.org/licenses/>.
 **********************************************************************/


#pragma once

#include "../common.h"
#include "Clause.h"


/**
 * Cache stores sums associated with Clauses (itemsets) in a tree structure.
 * Cache expects that predicates have IDs starting from 1 and also that
 * the clauses added to the cache are sorted in ascending order.
 */
class Cache {
public:
    /**
     * Constant representing a value that indicates that a Clause is not in the cache.
     * This value is used to differentiate between Clauses that have been added to
     * the cache and those that have not. When a Clause is not found in the cache,
     * the get() method will return this constant value.
     */
    static constexpr double NOT_IN_CACHE = -1.0;

    Cache(size_t nPredicates, size_t maxDepth)
    {
        nodes.reserve(nPredicates * maxDepth);
        nodes.emplace_back(); // root node
    }

    void add(const Clause& clause, double sum)
    {
        IF_DEBUG(
            if (clause.empty()) {
                throw runtime_error("Cache::add: cannot add empty clause");
            }
            if (sum < 0.0) {
                throw runtime_error("Cache::addSibling: sum cannot be negative");
            }
        )

        // Create new node
        size_t newIndex = nodes.size();
        nodes.emplace_back(clause.back(), sum);

        // Find the parent node
        size_t parent = 0;
        for (size_t i = 0; i < clause.size() - 1; ++i) {
            parent = findChildIndex(nodes[parent], clause[i]);
            if (parent == NOT_FOUND) {
                throw runtime_error("Cache::add: parent node not found for clause");
            }
        }

        // Update parent node to adopt the new node as a child
        Node& parentNode = nodes[parent];
        if (parentNode.nChildren == 0) {
            parentNode.firstChild = newIndex;
        }
        parentNode.nChildren++;
    }

    double get(const Clause& clause) const
    {
        IF_DEBUG(
            if (clause.empty()) {
                throw runtime_error("Cache::get: cannot get empty clause");
            }
        )

        size_t current = 0; // root node
        for (size_t pid : clause) {
            current = findChildIndex(nodes[current], pid);
            if (current == NOT_FOUND) {
                return NOT_IN_CACHE;
            }
        }

        return nodes[current].sum;
    }

    size_t size() const
    {
        return nodes.size() - 1; // exclude root node
    }

private:
    static constexpr size_t NOT_FOUND = static_cast<size_t>(-1);

    struct Node {
        size_t predicate;
        size_t firstChild;
        size_t nChildren;
        double sum;

        /**
         * Constructor for the root node.
         */
        Node()
            : predicate(0),
              firstChild(0),
              nChildren(0),
              sum(NOT_IN_CACHE)
        { }

        /**
         * Constructor for a non-root node with the given predicate ID and sum.
         */
        Node(const size_t predicate, const double sum)
            : predicate(predicate),
              firstChild(0),
              nChildren(0),
              sum(sum)
        { }
    };

    vector<Node> nodes;

    inline size_t findChildIndex(const Node& node, size_t pid) const
    {
        for (size_t i = node.firstChild; i < node.firstChild + node.nChildren; ++i) {
            if (nodes[i].predicate == pid) {
                return i;
            }
        }

        return NOT_FOUND;
    }
};
