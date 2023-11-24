#include <iostream>
#include "dig/Executor.h"


// [[Rcpp::export]]
List dig_(List logData,
          List numData,
          List logFoci,
          List numFoci,
          List confList,
          Function fun)
{
    List result;
    Config config(confList);

    if (config.getTNorm() == TNorm::GOEDEL) {
        Executor<BitsetBitChain, VectorNumChain<GOEDEL>> exec(config);
        result = exec.execute(logData, numData, logFoci, numFoci, fun);
    }
    else if (config.getTNorm() == TNorm::GOGUEN) {
        Executor<BitsetBitChain, VectorNumChain<GOGUEN>> exec(config);
        result = exec.execute(logData, numData, logFoci, numFoci, fun);
    }
    else if (config.getTNorm() == TNorm::LUKASIEWICZ) {
        Executor<BitsetBitChain, VectorNumChain<LUKASIEWICZ>> exec(config);
        result = exec.execute(logData, numData, logFoci, numFoci, fun);
    }
    else
        throw new runtime_error("Unknown t-norm in C++ dig_()");

    return result;
}
