#include "common.h"
#include "antichain/AntichainData.h"
#include "antichain/Tree.h"


// [[Rcpp::export(name="which_antichain_")]]
IntegerVector which_antichain_(List x, IntegerVector dist)
{
    IntegerVector result;
    AntichainData data(x);
    Tree tree(dist.at(0));

    for (size_t i = 0; i < data.size(); ++i) {
        if (tree.insertIfIncomparable(data.getCondition(i))) {
            result.push_back(i + 1);
        }
    }

    return result;
}
