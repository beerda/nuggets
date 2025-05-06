#include "common.h"
#include "dig/BitChain.h"
#include "dig/CallbackCaller.h"
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

    using CHAIN = BitChain;
    using STORAGE = CallbackCaller<CHAIN>;

    ChainCollection<BitChain> chains(data, isCondition, isFocus);
    Config config(confList, namesVector);
    STORAGE caller(config, callback);
    Digger<CHAIN, STORAGE> digger(config, caller);
    digger.run(chains);

    return caller.getResult();
}
