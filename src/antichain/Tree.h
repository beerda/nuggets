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

#include <string>
#include <sstream>
#include "../common.h"
#include "Node.h"
#include "Condition.h"


class Tree {
public:
    Tree()
        : distance(0)
    { }

    Tree(int distance)
        : distance(distance)
    { }

    /**
     * Returns TRUE if the condition is incomparable with all conditions in the tree.
     * Incomparable condition is also immediately inserted into the tree.
     *
     * @param condition The condition to test and insert.
     * @return FALSE if the condition is comparable with some condition in the tree
     *      and TRUE if it is incomparable and was inserted.
     */
    bool insertIfIncomparable(const Condition& condition)
    {
        Node* lastNode = &root;
        bool comparable = traverse(root, condition, 0, &lastNode);
        if (comparable) {
            return false;
        }
        lastNode->insertAsChildren(condition);

        return true;
    }

    inline Node& getRoot()
    { return root; }

    inline int getNumNodes()
    { return root.getNumDescendants() + 1; }

    inline string visualize()
    {
        stringstream ss;
        ss << "root" << endl;
        ss << root.visualize();

        return ss.str();
    }

private:
    Node root;
    int distance;

    /**
     * Returns TRUE if the condition is comparable with some condition in the tree.
     * Note that this is the opposite return value of insertIfIncomparable().
     */
    bool traverse(Node& node, const Condition& condition, int agreed, Node** lastNode)
    {
        if (!node.isRoot()) {
            if (condition.hasPredicate(node.getPredicate())) {
                agreed++;
            }
            if (agreed == node.getDepth() && (*lastNode)->getDepth() < node.getDepth()) {
                *lastNode = &node;
            }
            if (node.isLeaf()) {
                if (node.getDepth() <= condition.length())
                    return agreed >= node.getDepth() - distance;
                else
                    return agreed >= condition.length() - distance;
            }
        }

        for (auto& child : node.getMutableChildren()) {
            if (traverse(child, condition, agreed, lastNode)) {
                return true;
            }
        }
        return false;
    }
};
