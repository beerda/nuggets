#include "common.h"
#include "dig/BitChain.h"
#include "dig/Config.h"
#include "dig/ChainCollection.h"
#include "dig/Digger.h"



// [[Rcpp::plugins(openmp)]]
// [[Rcpp::export]]
List dig_(List data,
          CharacterVector namesVector,
          LogicalVector isCondition,
          LogicalVector isFocus,
          Function callback,
          List confList)
{
    LogStartEnd l("dig_");
    List result;
    ChainCollection<BitChain> chains(data, isCondition, isFocus);
    Config config(confList, namesVector);
    Digger<BitChain> digger(config);
    digger.run(chains);

    return result;
}
