/**********************************************************************
 * nuggets: An R framework for exploration of patterns in data
 * Copyright (C) 2026 Michal Burda
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

#include <algorithm>
#include <cstddef>
#include <cstdint>
#include <limits>
#include <stdexcept>
#include <vector>

#include "../common.h"


/**
 * A Trie (prefix tree) data structure for storing sequences of values.
 *
 * The Trie allows for efficient storage and retrieval of sequences, supporting
 * operations such as checking for the existence of a sequence and determining
 * if a sequence is a prefix of any stored sequence. The Trie is constructed
 * from a vector of sequences, where each sequence is represented as a vector
 * of values.
 *
 * This implementation assumes read-only access after construction, and it does
 * not support dynamic insertion or deletion of sequences.
 *
 * @tparam Value The type of values stored in the sequences.
 * @tparam Sequence The type of sequence container, defaulting to std::vector<Value>.
 */
template <typename Value, typename Sequence = std::vector<Value>>
class Trie {
public:
    /**
     * Type used for indexing nodes and edges in the Trie. It is defined as
     * a 32-bit unsigned integer.
     */
    using Index = std::uint32_t;

private:
    /**
     * Constant representing an invalid index, used to indicate the absence of
     * a child node.
     */
    static constexpr Index INVALID = std::numeric_limits<Index>::max();

    /**
     * Structure representing a node in the Trie. Each node contains information
     * about its edges and whether it is terminal.
     */
    struct Node {
        /**
         * The index of the first edge in the edges vector that corresponds to
         * this node.
         */
        Index firstEdge = 0;
        /**
         * The number of edges (children) for this node.
         */
        Index edgeCount = 0;
        /**
         * Flag indicating whether this node is terminal, meaning it represents
         * the end of a stored sequence.
         */
        bool terminal = false;
    };

    /**
     * Structure representing an edge in the Trie. Each edge connects a parent
     * node to a child node and is associated with a value.
     */
    struct Edge {
        /**
         * The value associated with this edge, which corresponds to a value in
         * the stored sequences.
         */
        Value value;
        /**
         * The index of the child node that this edge points to.
         */
        Index child;
    };

    /**
     * Structure used during the construction of the Trie to represent a node
     * and its children. It contains a vector of edges (children) and a flag
     * indicating whether the node is terminal.
     */
    struct BuildNode {
        /**
         * Vector of edges (children) for this build node. Each edge connects
         * to a child node and is associated with a value.
         */
        std::vector<Edge> children;
        /**
         * Flag indicating whether this build node is terminal, meaning it
         * represents the end of a stored sequence.
         */
        bool terminal = false;
    };

    /**
     * Vector of build nodes used during the construction of the Trie. Each
     * build node contains information about its children and whether it is
     * terminal. This vector is used to build the final nodes and edges of the
     * Trie.
     */
    std::vector<BuildNode> buildNodes;

    /**
     * Vector of nodes in the Trie. Each node contains information about its
     * edges and whether it is terminal.
     */
    std::vector<Node> nodes;

    /**
     * Vector of edges in the Trie. Each edge connects a parent node to a child
     * node and is associated with a value.
     */
    std::vector<Edge> edges;

    /**
     * The total number of sequences stored in the Trie. This count is updated
     * during the construction of the Trie and can be retrieved using the size()
     * method.
     */
    std::size_t sequenceCount = 0;

    bool initialized = false;

    /**
     * Checks if the given value can be safely cast to the Index type without
     * exceeding the maximum valid index. If the value is too large, a
     * std::length_error exception is thrown.
     *
     * @param value The value to check and cast to Index.
     * @return The value cast to Index if it is valid.
     * @throws std::length_error if the value exceeds the maximum valid index.
     */
    static Index checkedIndex(std::size_t value)
    {
        if (value >= INVALID)
            throw std::length_error("Trie index overflow");

        return static_cast<Index>(value);
    }

    /**
     * Finds the child node of the given node that corresponds to the specified
     * value. If a child with the specified value exists, its index is returned.
     * Otherwise, INVALID is returned to indicate that no such child exists.
     *
     * @param nodeIndex The index of the parent node to search for a child.
     * @param value The value associated with the edge leading to the child node.
     * @return The index of the child node if found, or INVALID if not found.
     */
    Index findChild(Index nodeIndex, Value value) const noexcept
    {
        const Node& node = nodes[nodeIndex];
        const Edge* first = edges.data() + node.firstEdge;

        for (Index i = 0; i < node.edgeCount; ++i) {
            if (first[i].value == value)
                return first[i].child;
        }

        return INVALID;
    }

public:
    explicit Trie(const size_t numSequences)
    {
        buildNodes.reserve(numSequences * 4);
        buildNodes.emplace_back();
    }

    void insert(const Sequence& sequence)
    {
        IF_DEBUG(
            if (initialized)
                throw runtime_error("Cannot insert sequence to trie after it is initialized.");
        )

        Index current = 0;
        for (Value value : sequence) {
            auto& children = buildNodes[current].children;

            auto it = std::find_if(children.begin(), children.end(),
                [value](const Edge& edge) { return edge.value == value; });

            if (it != children.end()) {
                current = it->child;
                continue;
            }

            const Index child = checkedIndex(buildNodes.size());
            buildNodes.emplace_back();
            buildNodes[current].children.push_back({ value, child });
            current = child;
        }

        if (!buildNodes[current].terminal) {
            buildNodes[current].terminal = true;
            ++sequenceCount;
        }
    }

    void initializeForQueries()
    {
        IF_DEBUG(
            if (initialized)
                throw std::runtime_error("Trie is already initialized.");
        )

        std::size_t totalEdges = 0;
        for (const auto& node : buildNodes) {
            if (node.children.size() > static_cast<std::size_t>(INVALID) - totalEdges) {
                throw std::length_error("Trie has too many edges");
            }
            totalEdges += node.children.size();
        }

        nodes.resize(buildNodes.size());
        edges.reserve(totalEdges);
        for (std::size_t i = 0; i < buildNodes.size(); ++i) {
            const auto& children = buildNodes[i].children;
            Node& node = nodes[i];
            node.firstEdge = checkedIndex(edges.size());
            node.edgeCount = checkedIndex(children.size());
            node.terminal = buildNodes[i].terminal;
            edges.insert(edges.end(), children.begin(), children.end());
        }
        buildNodes.clear();
        initialized = true;
    }

    /**
     * Checks if the Trie contains the specified sequence. The method traverses
     * the Trie based on the values in the sequence and returns true if the
     * sequence is found and is terminal, indicating that it represents a stored
     * sequence. If any value in the sequence does not lead to a valid child
     * node, or if the final node is not terminal, false is returned.
     *
     * @param sequence The sequence to check for existence in the Trie.
     * @return True if the Trie contains the specified sequence, false otherwise.
     */
    bool contains(const Sequence& sequence) const
    {
        IF_DEBUG(
            if (!initialized)
                throw std::runtime_error("Trie is not initialized for queries.");
        )

        Index current = 0;
        for (Value value : sequence) {
            current = findChild(current, value);
            if (current == INVALID)
                return false;
        }

        return nodes[current].terminal;
    }

    /**
     * Checks if the specified sequence is a prefix of any sequence stored in the
     * Trie. The method traverses the Trie based on the values in the sequence
     * and returns true if all values lead to valid child nodes, indicating that
     * the sequence is a prefix of at least one stored sequence. If any value in
     * the sequence does not lead to a valid child node, false is returned.
     *
     * @param sequence The sequence to check for being a prefix in the Trie.
     * @return True if the specified sequence is a prefix of any stored sequence,
     *         false otherwise.
     */
    bool isPrefix(const Sequence& sequence) const
    {
        IF_DEBUG(
            if (!initialized)
                throw std::runtime_error("Trie is not initialized for queries.");
        )

        Index current = 0;
        for (Value value : sequence) {
            current = findChild(current, value);
            if (current == INVALID)
                return false;
        }

        return true;
    }

    inline std::size_t size() const noexcept
    { return sequenceCount; }
};
