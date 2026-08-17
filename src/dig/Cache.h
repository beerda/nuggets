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

    /**
     * Representation of a node in the cache tree
     */
    struct Node {
        /**
         * Constructs a new Node with the given predicate ID, sum, and sibling
         * pointer.
         *
         * @param pid The predicate ID associated with this node.
         * @param sum The sum of TRUEs or membership degrees for the Clause
         *     represented by this node.
         * @param sibling A pointer to the sibling node in the tree. This allows
         *     for traversal of nodes at the same level.
         */
        Node(size_t pid, double sum, Node* sibling)
            : predicateId(pid),
              sum(sum),
              child(nullptr),
              sibling(sibling)
        { }

        /**
         * Destructor for the Node class. It recursively deletes the child and
         * sibling nodes to free up memory used by the cache tree.
         */
        ~Node()
        {
            delete child;
            delete sibling;
        }

        /**
         * Returns the total number of nodes in the subtree rooted at this node,
         * including this node itself. This method is useful for determining the
         * size of the cache tree.
         *
         * @return The total number of nodes in the subtree rooted at this node.
         */
        size_t size() const
        {
            size_t total = 1; // count this node
            if (child != nullptr) {
                total += child->size();
            }
            if (sibling != nullptr) {
                total += sibling->size();
            }
            return total;
        }

        /**
         * The predicate ID associated with this node.
         */
        size_t predicateId;

        /**
         * The sum of TRUEs or membership degrees for the Clause represented by
         * this node.
         */
        double sum;

        /**
         * Pointer to the child node in the tree.
         */
        Node* child;

        /**
         * Pointer to the sibling node in the tree.
         */
        Node* sibling;
    };

    /**
     * Construct new cache of itemsets. It is assumed that predicates have
     * IDs starting from 1 (as in R), so the last predicate's ID is equal to
     * the number of predicates.
     *
     * @param rootSize The number of predicates in the data. This determines the
     *    size of the root level of the cache tree, where each predicate ID
     *    corresponds to a root node in the tree.
     */
    Cache(size_t rootSize)
        : rootSize(rootSize)
    {
        children = new Node*[rootSize];
        for (size_t i = 0; i < rootSize; ++i) {
            children[i] = nullptr;
        }
    }

    // Disable copy
    Cache(const Cache& other) = delete;
    Cache& operator=(const Cache& other) = delete;

    // Allow move
    Cache(Cache&& other) = default;
    Cache& operator=(Cache&& other) = default;

    /**
     * Destructor for the Cache class. It deletes all nodes in the cache tree,
     * freeing up memory used by the cache.
     */
    ~Cache()
    {
        for (size_t i = 0; i < rootSize; ++i) {
            delete children[i];
        }
        delete[] children;
    }

    /**
     * Adds a Clause and its associated sum to the cache. The Clause is expected
     * to be sorted in ascending order. If the Clause is already present in the
     * cache, an exception is thrown.
     *
     * @param clause The Clause (itemset) to be added to the cache.
     * @param sum The sum of TRUEs or membership degrees associated with the
     *     Clause.
     */
    void add(const Clause& clause, double sum)
    {
        if (clause.empty())
            throw runtime_error("Cache::add: cannot add empty clause");

        if (clause[0] > rootSize)
            throw runtime_error("Cache::add: predicate ID exceeds number of predicates");

        if (clause.size() == 1) {
            size_t pid = clause[0];
            Node* node = children[pid];
            if (node == nullptr) {
                children[pid] = new Node(pid, sum, nullptr);
            }
            else if (node->sum == NOT_IN_CACHE) {
                node->sum = sum;
            }
            else {
                throw runtime_error(string("Cache::add: trying to add existing clause: ")); // + clause.toString());
            }
        }
        else {
            Node* node = find(clause.begin(),
                              clause.end(),
                              children[clause[0]]);
            if (node->sum == NOT_IN_CACHE) {
                node->sum = sum;
            }
            else {
                throw runtime_error(string("Cache::add: trying to add existing clause: ")); // + clause.toString());
            }
        }
    }

    /**
     * Retrieves the sum associated with a Clause from the cache. If the Clause
     * is not found in the cache, the method returns NOT_IN_CACHE. The Clause is
     * expected to be sorted in ascending order.
     *
     * @param clause The Clause (itemset) for which to retrieve the sum.
     * @return The sum of TRUEs or membership degrees associated with the Clause,
     *     or NOT_IN_CACHE if the Clause is not found in the cache.
     */
    double get(const Clause& clause) const
    {
        if (clause.empty()) {
            throw runtime_error("Cache::get: cannot get empty clause");
        }

        Node* node = children[clause[0]];
        node = find(clause.begin(), clause.end(), node);

        // possibly return NOT_IN_CACHE
        return node->sum;
    }

    /**
     * Returns the total number of nodes in the cache tree, including all root
     * nodes and their descendants. This method is useful for determining the
     * size of the cache.
     *
     * @return The total number of nodes in the cache tree.
     */
    size_t size() const
    {
        size_t total = 0;
        for (size_t i = 0; i < rootSize; ++i) {
            if (children[i] != nullptr) {
                total += children[i]->size();
            }
        }
        return total;
    }

private:
    /**
     * The number of predicates in the data. This determines the size of the root
     * level of the cache tree, where each predicate ID corresponds to a root
     * node in the tree.
     */
    size_t rootSize;

    /**
     * An array of pointers to the root nodes of the cache tree, where each index
     * corresponds to a predicate ID. The root nodes represent the first level
     * of the cache tree, and each root node may have child nodes representing
     * Clauses that include the corresponding predicate.
     */
    Node** children;

    /**
     * Recursively finds the node corresponding to a Clause in the cache tree.
     * If the node does not exist, it is created. The method traverses the tree
     * based on the predicate IDs in the Clause, creating new nodes as needed.
     *
     * @param begin An iterator pointing to the beginning of the Clause.
     * @param end An iterator pointing to the end of the Clause.
     * @param node A pointer to the current node in the cache tree.
     * @return A pointer to the node corresponding to the Clause in the cache tree.
     */
    inline Node* find(Clause::const_iterator begin,
                      Clause::const_iterator end,
                      Node* node) const
    {
        if (node == nullptr) {
            throw runtime_error("Cache::find: node is null");
        }

        size_t pid = *begin;
        if (node->predicateId != pid) {
            Node* sibling = node->sibling;
            while (sibling != nullptr && sibling->predicateId <= pid) {
                node = sibling;
                sibling = node->sibling;
            }

            if (node->predicateId != pid) {
                node->sibling = new Node(pid, NOT_IN_CACHE, sibling);
                node = node->sibling;
            }
        }

        begin++;
        if (begin == end) {
            return node;
        }
        else {
            if (node->child == nullptr) {
                size_t pid = *begin;
                node->child = new Node(pid, NOT_IN_CACHE, nullptr);
            }
            return find(begin, end, node->child);
        }
    }
};
