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

    Node& getRoot()
    { return root; }

    int getNumNodes()
    { return root.getNumDescendants() + 1; }

    string visualize()
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
