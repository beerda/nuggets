#include <iostream>
#include "dig/Executor.h"


// [[Rcpp::export]]
List dig_(List logData,
          List numData,
          List logFoci,
          List numFoci,
          List configuration_list,
          Function fun)
{
    Config config(configuration_list);
    Executor<BitsetBitChain, VectorNumChain<GOGUEN>> exec(config);

    return exec.execute(logData, numData, logFoci, numFoci, fun);
}
