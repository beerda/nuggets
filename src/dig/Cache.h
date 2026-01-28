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
    static constexpr double NOT_IN_CACHE = -1.0;

    /**
     * Representation of a node in the cache tree
     */
    struct Node {
        Node(size_t pid, double sum, Node* sibling)
            : predicateId(pid),
              sum(sum),
              child(nullptr),
              sibling(sibling)
        { }

        ~Node()
        {
            delete child;
            delete sibling;
        }

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

        size_t predicateId;
        double sum;
        Node* child;
        Node* sibling;
    };

    /**
     * Construct new cache of itemsets. It is assumed that predicates have
     * IDs starting from 1 (as in R), so the last predicate's ID is equal to
     * the number of predicates.
     */
    Cache(size_t rootSize)
        : rootSize(rootSize)
    {
        children = new Node*[rootSize];
        for (size_t i = 0; i < rootSize; ++i) {
            children[i] = nullptr;
        }
    }

    ~Cache()
    { }

    void add(const Clause& clause, double sum)
    {
        //Rcout << "adding " << clause.toString() << " to cache with sum " << sum << endl;

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
                throw runtime_error("1 Cache::add: trying to add existing clause");
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
                throw runtime_error("2 Cache::add: trying to add existing clause");
            }
        }
    }

    double get(const Clause& clause) const
    {
        //Rcout << "getting " << clause.toString() << " from cache" << endl;

        if (clause.empty()) {
            throw runtime_error("Cache::get: cannot get empty clause");
        }

        Node* node = children[clause[0]];
        node = find(clause.begin(), clause.end(), node);
        if (node->sum == NOT_IN_CACHE) {
            throw runtime_error("Cache::get: clause not found in cache");
        }

        return node->sum;
    }

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
    size_t rootSize;
    Node** children; // array of root nodes for each predicate ID

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
