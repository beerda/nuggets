#include "dig/Executor.h"
#include "dig/BitChain.h"
#include "dig/BitwiseFuzzyChain.h"
#include "dig/SimdVectorNumChain.h"

#define BCH BitChain
//#define BCH PackedBitChain
//#define BCH SparseBitChain

//define NCH VectorNumChain
#define NCH SimdVectorNumChain
//define NCH BitwiseFuzzyChain8

// [[Rcpp::plugins(openmp)]]
// [[Rcpp::export]]
List dig_(List chains,
          CharacterVector namesVector,
          LogicalVector isCondition,
          LogicalVector isFocus,
          Function callback,
          List confList)
{
    LogStartEnd l("dig_");
    List result;
    Config config(confList);

    if (config.getTNorm() == TNorm::GOEDEL) {
        Executor<BCH, NCH<GOEDEL>> exec(config);
        result = exec.execute(chains, namesVector, isCondition, isFocus, callback);
    }
    else if (config.getTNorm() == TNorm::GOGUEN) {
        Executor<BCH, NCH<GOGUEN>> exec(config);
        result = exec.execute(chains, namesVector, isCondition, isFocus, callback);
    }
    else if (config.getTNorm() == TNorm::LUKASIEWICZ) {
        Executor<BCH, NCH<LUKASIEWICZ>> exec(config);
        result = exec.execute(chains, namesVector, isCondition, isFocus, callback);
    }
    else
        throw runtime_error("Unknown t-norm in C++ dig_()");

    return result;
}
