/**********************************************************************
 * nuggets: An R framework for exploration of patterns in data
 * Copyright (C) 2025 Michal Burda
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program. If not, see <https://www.gnu.org/licenses/>.
 **********************************************************************/


#include "common.h"
#include "timer.h"
#include "dig/BitChain.h"
#include "dig/SparseBitChain.h"
#include "dig/FloatChain.h"
#include "dig/CallbackCaller.h"
#include "dig/AssocStorage.h"
#include "dig/ItemsetStorage.h"
#include "dig/Config.h"
#include "dig/ChainCollection.h"
#include "dig/Digger.h"


#define BIT_CHAIN_DENSE BitChain
#define BIT_CHAIN_SPARSE SparseBitChain

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


bool dataAreAllLogical(const List& data)
{
    bool allLogical = true;
    for (R_xlen_t i = 0; i < data.size(); ++i) {
        if (!Rf_isLogical(data[i])) {
            allLogical = false;
            break;
        }
    }

    return allLogical;
}


long countLogicalValues(const List& data)
{
    using batch_type = xsimd::batch<int32_t>;
    constexpr R_xlen_t simd_size = (R_xlen_t)batch_type::size;
    constexpr R_xlen_t chunk = R_xlen_t(1) << 32;
    long count = 0;

    for (R_xlen_t i = 0; i < data.size(); ++i) {
        LogicalVector vec = data[i];
        const int* raw = vec.begin();
        const R_xlen_t n = vec.size();
        const R_xlen_t n_simd = n - n % simd_size;

        R_xlen_t j = 0;
        for (; j < n_simd; ) {
            batch_type acc(0);
            const R_xlen_t end = std::min(j + chunk, n_simd);
            for (; j < end; j += simd_size) {
                acc += batch_type::load_unaligned(raw + j);
            }
            count += xsimd::reduce_add(acc);
        }

        for (; j < n; ++j) {
            count += raw[j];
        }
    }

    return count;
}


struct DispatchArgs {
    const List& data;
    const LogicalVector& isCondition;
    const LogicalVector& isFocus;
    const Config& config;
};


template <typename RUNNER>
List dispatchDig(const DispatchArgs& args,
                 const RUNNER& runner)
{
    if (dataAreAllLogical(args.data)) {
        long count = countLogicalValues(args.data);
        LogicalVector vec = args.data[0];
        if (count * BITCHAIN_SPARSENESS_LIMIT < args.data.size() * vec.size()) {
            return runner.template run<BIT_CHAIN_SPARSE>(args);
        }
        else {
            return runner.template run<BIT_CHAIN_DENSE>(args);
        }
    }
    else if (args.config.getTNorm() == TNorm::GOEDEL) {
        return runner.template run<GOEDEL_CHAIN>(args);
    }
    else if (args.config.getTNorm() == TNorm::GOGUEN) {
        return runner.template run<GOGUEN_CHAIN>(args);
    }
    else if (args.config.getTNorm() == TNorm::LUKASIEWICZ) {
        return runner.template run<LUKASIEWICZ_CHAIN>(args);
    }

    stop("internal error in getDigRunType()");
}


struct DigRunner {
    const Function& callback;

    template <typename CHAIN>
    List run(const DispatchArgs& args) const
    {
        using STORAGE = CallbackCaller;

        START_TIMER(t, "DigRunner - initialization");
        STORAGE storage(args.config, callback);
        Digger<CHAIN, STORAGE> digger(args.config, args.data, args.isCondition, args.isFocus,
                                      storage);
        STOP_TIMER(t);

        BLOCK_TIMER(bt, "DigRunner - run");
        digger.run();

        return digger.getResult();
    }
};


// [[Rcpp::export]]
List dig_(const List& data,
          const CharacterVector& namesVector,
          const LogicalVector& isCondition,
          const LogicalVector& isFocus,
          const Function& callback,
          const List& confList)
{
    START_TIMER(bt, "dig_");

    Config config(confList, namesVector);
    DispatchArgs args{data, isCondition, isFocus, config};
    List result = dispatchDig(args, DigRunner{ callback });

    STOP_TIMER(bt);
    CLEAR_INC_TIMERS();

    return result;
}


struct DigAssocRunner {
    template <typename CHAIN>
    List run(const DispatchArgs& args) const
    {
        using STORAGE = AssocStorage;

        START_TIMER(t, "DigAssocRunner - initialization");
        STORAGE storage(args.config);
        Digger<CHAIN, STORAGE> digger(args.config, args.data, args.isCondition, args.isFocus,
                                      storage);
        STOP_TIMER(t);

        BLOCK_TIMER(bt, "DigAssocRunner - run");
        digger.run();

        return digger.getResult();
    }
};


// [[Rcpp::export]]
List dig_associations_(const List& data,
                       const CharacterVector& namesVector,
                       const LogicalVector& isCondition,
                       const LogicalVector& isFocus,
                       const Function& callback,
                       const List& confList)
{
    START_TIMER(bt, "dig_associations_");

    Config config(confList, namesVector);
    DispatchArgs args{data, isCondition, isFocus, config};
    List result = dispatchDig(args, DigAssocRunner{ });

    STOP_TIMER(bt);
    CLEAR_INC_TIMERS();

    return result;
}


struct DigItemsetRunner {
    template <typename CHAIN>
    List run(const DispatchArgs& args) const
    {
        using STORAGE = ItemsetStorage;

        START_TIMER(t, "DigItemsetRunner - initialization");
        STORAGE storage(args.config);
        Digger<CHAIN, STORAGE> digger(args.config, args.data, args.isCondition, args.isFocus,
                                      storage);
        STOP_TIMER(t);

        BLOCK_TIMER(bt, "DigItemsetRunner - run");
        digger.run();

        return digger.getResult();
    }
};


// [[Rcpp::export]]
List dig_itemsets_(const List& data,
                   const CharacterVector& namesVector,
                   const LogicalVector& isCondition,
                   const LogicalVector& isFocus,
                   const Function& callback,
                   const List& confList)
{
    START_TIMER(bt, "dig_itemsets_");

    Config config(confList, namesVector);
    DispatchArgs args{data, isCondition, isFocus, config};
    List result = dispatchDig(args, DigItemsetRunner{ });

    STOP_TIMER(bt);
    CLEAR_INC_TIMERS();

    return result;
}
