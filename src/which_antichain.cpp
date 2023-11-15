#include "common.h"
#include "antichain/AntichainData.h"
#include "antichain/Tree.h"


[[cpp11::register]]
integers which_antichain_(list x, integers dist)
{
    writable::integers result;
    AntichainData data(x);
    Tree tree(dist.at(0));

    for (size_t i = 0; i < data.size(); ++i) {
        if (tree.insertIfIncomparable(data.getCondition(i))) {
            result.push_back(i + 1);
        }
    }

    return result;
}
