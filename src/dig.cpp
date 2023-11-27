#include <iostream>
#include "dig/Executor.h"

//define NCH VectorNumChain
#define NCH SimdVectorNumChain
//define NCH BitsetNumChain

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
        Executor<BitsetBitChain, NCH<GOEDEL>> exec(config);
        result = exec.execute(logData, numData, logFoci, numFoci, fun);
    }
    else if (config.getTNorm() == TNorm::GOGUEN) {
        Executor<BitsetBitChain, NCH<GOGUEN>> exec(config);
        result = exec.execute(logData, numData, logFoci, numFoci, fun);
    }
    else if (config.getTNorm() == TNorm::LUKASIEWICZ) {
        Executor<BitsetBitChain, NCH<LUKASIEWICZ>> exec(config);
        result = exec.execute(logData, numData, logFoci, numFoci, fun);
    }
    else
        throw new runtime_error("Unknown t-norm in C++ dig_()");

    return result;
}
