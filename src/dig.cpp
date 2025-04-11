#include "common.h"


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

    return result;
}
