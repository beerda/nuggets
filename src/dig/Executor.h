#pragma once

#include "../common.h"
#include "dig/MultiThreadDigger.h"
#include "dig/Config.h"
#include "dig/Data.h"
#include "dig/DataSorter.h"
#include "dig/ConditionArgumentator.h"
#include "dig/FociSupportsArgumentator.h"
#include "dig/ContiPpArgumentator.h"
#include "dig/ContiNpArgumentator.h"
#include "dig/ContiPnArgumentator.h"
#include "dig/ContiNnArgumentator.h"
#include "dig/IndicesArgumentator.h"
#include "dig/SumArgumentator.h"
#include "dig/SupportArgumentator.h"
#include "dig/WeightsArgumentator.h"
#include "dig/MinLengthFilter.h"
#include "dig/MaxLengthFilter.h"
#include "dig/MinSupportFilter.h"
#include "dig/MinFocusSupportFilter.h"
#include "dig/MinConditionalFocusSupportFilter.h"
#include "dig/MaxSupportFilter.h"
#include "dig/DisjointFilter.h"
#include "dig/EmptyFociFilter.h"
#include "dig/ExcludedTautologiesFilter.h"
#include "dig/TautologyLimitFilter.h"
#include "dig/TautologyTree.h"

template <typename BITCHAIN, typename NUMCHAIN>
class Executor {
public:
    using DataType = Data<BITCHAIN, NUMCHAIN>;
    using TaskType = Task<DataType>;

    Executor(const Config& config)
        : config(config)
    { }

    List execute(const List& chainsList,
                 const CharacterVector& namesVec,
                 const LogicalVector& isConditionVec,
                 const LogicalVector& isFocusVec,
                 const Function callback)
    {
        DataType data = createData(chainsList, namesVec, isConditionVec, isFocusVec);
        MultiThreadDigger<DataType> digger(data, config, callback);

        if (config.hasConditionArgument()) {
            digger.addArgumentator(new ConditionArgumentator<TaskType>(data));
        }
        if (config.hasFociSupportsArgument()) {
            digger.setPpFocusChainsNeeded();
            digger.addArgumentator(new FociSupportsArgumentator<TaskType>(data));
        }
        if (config.hasContiPpArgument()) {
            digger.setPpFocusChainsNeeded();
            digger.addArgumentator(new ContiPpArgumentator<TaskType>(data));
        }
        if (config.hasContiNpArgument()) {
            digger.setNpFocusChainsNeeded();
            digger.addArgumentator(new ContiNpArgumentator<TaskType>(data));
        }
        if (config.hasContiPnArgument()) {
            digger.setPnFocusChainsNeeded();
            digger.addArgumentator(new ContiPnArgumentator<TaskType>(data));
        }
        if (config.hasContiNnArgument()) {
            digger.setNnFocusChainsNeeded();
            digger.addArgumentator(new ContiNnArgumentator<TaskType>(data));
        }
        if (config.hasSumArgument()) {
            digger.setPositiveConditionChainsNeeded();
            digger.addArgumentator(new SumArgumentator<TaskType>(data));
        }
        if (config.hasSupportArgument()) {
            digger.setPositiveConditionChainsNeeded();
            digger.addArgumentator(new SupportArgumentator<TaskType>(data));
        }
        if (config.hasIndicesArgument()) {
            digger.setPositiveConditionChainsNeeded();
            digger.addArgumentator(new IndicesArgumentator<TaskType>(data));
        }
        if (config.hasWeightsArgument()) {
            digger.setPositiveConditionChainsNeeded();
            digger.addArgumentator(new WeightsArgumentator<TaskType>(data));
        }
        if (config.getMinLength() >= 0) {
            digger.addFilter(new MinLengthFilter<TaskType>(config.getMinLength()));
        }
        if (config.getMaxLength() >= 0) {
            digger.addFilter(new MaxLengthFilter<TaskType>(config.getMaxLength()));
        }
        if (config.getMinSupport() > 0.0) {
            digger.setPositiveConditionChainsNeeded();
            digger.addFilter(new MinSupportFilter<TaskType>(config.getMinSupport()));
        }
        if (config.getMinFocusSupport() > 0.0) {
            digger.setPpFocusChainsNeeded();
            digger.addFilter(new MinFocusSupportFilter<TaskType>(config.getMinFocusSupport()));
        }
        if (config.getMinConditionalFocusSupport() > 0.0) {
            digger.setPpFocusChainsNeeded();
            digger.addFilter(new MinConditionalFocusSupportFilter<TaskType>(config.getMinConditionalFocusSupport(),
                                                                            data.nrow()));
        }
        if (config.getMaxSupport() < 1.0) {
            digger.setPositiveConditionChainsNeeded();
            digger.addFilter(new MaxSupportFilter<TaskType>(config.getMaxSupport()));
        }
        if (config.hasFilterEmptyFoci()) {
            digger.addFilter(new EmptyFociFilter<TaskType>());
        }

        digger.addFilter(new DisjointFilter<TaskType>(config.getDisjoint()));

        TautologyTree tautologies(data.getCondition(), data.getFoci());
        tautologies.addTautologies(config.getExcluded());
        if (!tautologies.empty() || config.hasTautologyLimit()) {
            digger.addFilter(new ExcludedTautologiesFilter<TaskType>(tautologies));
        }

        if (config.hasTautologyLimit()) {
            digger.setPpFocusChainsNeeded();
            digger.addFilter(new TautologyLimitFilter<TaskType>(tautologies,
                                                                config.getTautologyLimit(),
                                                                data.nrow()));
        }

        if (digger.isNegativeFociChainsNeeded()) {
            data.initializeNegativeFoci();
        }

        {
            if (config.isVerbose()) {
                Rcout << "dig: searching for frequent conditions" << endl;
            }
            LogStartEnd l("digger.run");
            digger.run();
        }

        return digger.getResult();
    }

private:
    Config config;

    template <typename T>
    T permute(T vec, const vector<size_t>& permutation)
    {
        T result(vec.size());
        for (size_t i = 0; i < vec.size(); i++) {
            result[i] = vec[permutation[i]];
        }
        return result;
    }

    DataType createData(const List& chainsList,
                        const CharacterVector& namesVec,
                        const LogicalVector& isConditionVec,
                        const LogicalVector& isFocusVec)
    {
        LogStartEnd l("data init");
        DataType data(config.getNrow());

        /*
        DataSorter sorter(config.getNrow());
        for (R_xlen_t i = 0; i < chainsList.size(); i++) {
            bool isCondition = isConditionVec[i];
            if (isCondition && Rf_isLogical(chainsList[i])) {
                const LogicalVector vec = chainsList[i];
                sorter.addColumn(vec);
            }
        }
        vector<size_t> rowPermutation = sorter.getSortedRowIndices();
        */

        data.reserve(chainsList.size() + 1);
        data.addUnusedChain(); // 0th element is always empty to match C++ indices to R's indices that start from 1

        for (R_xlen_t i = 0; i < chainsList.size(); i++) {
            bool isCondition = isConditionVec[i];
            bool isFocus = isFocusVec[i];

            if (isCondition || isFocus) {
                String name = namesVec[i];
                if (Rf_isReal(chainsList[i])) {
                    const NumericVector vec = chainsList[i];
                    data.addChain(vec, //permute(vec, rowPermutation),
                                  name, isCondition, isFocus);
                }
                else if (Rf_isLogical(chainsList[i])) {
                    const LogicalVector vec = chainsList[i];
                    data.addChain(vec, //permute(vec, rowPermutation),
                                  name, isCondition, isFocus);
                }
                else {
                    throw runtime_error("Data element of unknown type");
                }
            }
            else {
                data.addUnusedChain();
            }
        }

        data.optimizeConditionOrder();

        if (config.isVerbose()) {
            Rcout << "dig: loaded " << data.nrow() << " rows / " << data.size() << " chains" << endl;
        }

        return data;
    }
};
