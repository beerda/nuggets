#include "common.h"
#include "antichain/Data.h"
#include "antichain/Tree.h"


[[cpp11::register]]
integers antichain_(list x)
{
    writable::integers result;
    Data data(x);
    Tree tree;

    for (int i = 0; i < data.size(); ++i) {
        if (tree.insertIfIncomparable(data.getCondition(i))) {
            result.push_back(i + 1);
        }
    }

    return result;
}
