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
     * Representation of a node in the cache tree
     */
    struct Node {
        Node(size_t pid, float sum, Node* sibling)
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
        float sum;
        Node* child;
        Node* sibling;
    };

    /**
     * Construct new cache of itemsets. It is assumed that predicates have
     * IDs starting from 1 (as in R), so the last predicate's ID is equal to
     * the number of predicates.
     */
    Cache(size_t nPredicates)
        : nPredicates(nPredicates)
    {
        children = new Node*[nPredicates + 1];
        for (size_t i = 0; i <= nPredicates; ++i) {
            children[i] = nullptr;
        }
    }

    ~Cache()
    { }

    void add(const Clause& clause, float sum)
    {
        if (clause.empty())
            throw runtime_error("Cache::add: cannot add empty clause");

        if (clause[0] > nPredicates)
            throw runtime_error("Cache::add: predicate ID exceeds number of predicates");

        if (clause.size() == 1) {
            size_t pid = clause[0];
            if (children[pid] == nullptr) {
                children[pid] = new Node(pid, sum, nullptr);
            }
            else {
                throw runtime_error("Cache::add: trying to add existing clause");
            }
        }
        else {
            Node* current = find(clause.begin(),
                                 clause.end() - 1,
                                 children[clause[0]]);

            if (current == nullptr)
                throw runtime_error("Cache::add: clause prefix not found in cache");

            size_t pid = clause.back();
            if (current->child == nullptr) {
                current->child = new Node(pid, sum, nullptr);
            }
            else {
                Node* current = current->child;
                Node* sibling = current->sibling;
                while (sibling != nullptr && sibling->predicateId < pid) {
                    current = sibling;
                    sibling = current->sibling;
                }

                if (sibling == nullptr || sibling->predicateId > pid) {
                    current->sibling = new Node(pid, sum, sibling);
                }
                else {
                    throw runtime_error("Cache::add: trying to add existing clause");
                }
            }
        }
    }

    float get(const Clause& clause) const
    {
        if (clause.empty())
            throw runtime_error("Cache::get: cannot get empty clause");

        Node* node = children[clause[0]];
        node = find(clause.begin(), clause.end(), node);
        if (node == nullptr) {
            throw runtime_error("Cache::get: clause not found in cache");
        }

        return node->sum;
    }

    size_t size() const
    {
        size_t total = 0;
        for (size_t i = 1; i <= nPredicates; ++i) {
            if (children[i] != nullptr) {
                total += children[i]->size();
            }
        }
        return total;
    }

private:
    size_t nPredicates;
    Node** children; // array of root nodes for each predicate ID

    inline Node* find(Clause::const_iterator begin,
                      Clause::const_iterator end,
                      Node* node) const
    {
        size_t pid = *begin;
        while (node != nullptr && node->predicateId < pid) {
            node = node->sibling;
        }

        if (node == nullptr || node->predicateId > pid)
            return nullptr;

        begin++;
        if (begin == end)
            return node;
        else
            return find(begin, end, node->child);
    }
};
