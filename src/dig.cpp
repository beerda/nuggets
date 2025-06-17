#include "common.h"
#include "dig/BitChain.h"
#include "dig/FloatChain.h"
#include "dig/CallbackCaller.h"
#include "dig/Config.h"
#include "dig/ChainCollection.h"
#include "dig/Digger.h"


#ifdef __arm64__
    // MacOS
    #define GOGUEN_CHAIN FloatChain<TNorm::GOGUEN>
    #define GOEDEL_CHAIN FloatChain<TNorm::GOEDEL>
    #define LUKASIEWICZ_CHAIN FloatChain<TNorm::LUKASIEWICZ>
#else
    // Linux or Windows
    #include "dig/FubitChain.h"
    #define GOGUEN_CHAIN FloatChain<TNorm::GOGUEN>
    #define GOEDEL_CHAIN FubitChain<TNorm::GOEDEL, 8>
    #define LUKASIEWICZ_CHAIN FubitChain<TNorm::LUKASIEWICZ, 8>
#endif

//include "dig/SimdChain.h"
//define GOEDEL_CHAIN SimdChain<TNorm::GOEDEL>
//define GOGUEN_CHAIN SimdChain<TNorm::GOGUEN>
//define LUKASIEWICZ_CHAIN SimdChain<TNorm::LUKASIEWICZ>

//define GOGUEN_CHAIN FubitChain<TNorm::GOGUEN, 8>



template <typename CHAIN, typename STORAGE>
List runDigger(List data,
               LogicalVector isCondition,
               LogicalVector isFocus,
               Function callback,
               const Config& config)
{
        STORAGE caller(config, callback);
        Digger<CHAIN, STORAGE> digger(config, data, isCondition, isFocus, caller);
        digger.run();

        return caller.getResult();
}


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

    bool allLogical = true;
    for (R_xlen_t i = 0; i < data.size(); ++i) {
        if (!Rf_isLogical(data[i])) {
            allLogical = false;
            break;
        }
    }

    Config config(confList, namesVector);
    List result;

    if (allLogical) {
        //cout << "BitChain\n";
        using CHAIN = BitChain;
        using STORAGE = CallbackCaller<CHAIN>;

        result = runDigger<CHAIN, STORAGE>(data, isCondition, isFocus, callback, config);
    }
    else if (config.getTNorm() == TNorm::GOEDEL) {
        //cout << "Goedel\n";
        using CHAIN = GOEDEL_CHAIN;
        using STORAGE = CallbackCaller<CHAIN>;
        result = runDigger<CHAIN, STORAGE>(data, isCondition, isFocus, callback, config);
    }
    else if (config.getTNorm() == TNorm::GOGUEN) {
        //cout << "Goguen\n";
        using CHAIN = GOGUEN_CHAIN;
        using STORAGE = CallbackCaller<CHAIN>;
        result = runDigger<CHAIN, STORAGE>(data, isCondition, isFocus, callback, config);
    }
    else if (config.getTNorm() == TNorm::LUKASIEWICZ) {
        //cout << "Lukas\n";
        using CHAIN = LUKASIEWICZ_CHAIN;
        using STORAGE = CallbackCaller<CHAIN>;
        result = runDigger<CHAIN, STORAGE>(data, isCondition, isFocus, callback, config);
    }

    return result;
}
