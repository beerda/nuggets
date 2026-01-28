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


#pragma once


#include "common.h"
#include <deque>


class BlockTimer {
    std::string what;
    std::chrono::steady_clock::time_point start;
    inline static size_t indent = 0;

    void indentation()
    {
        for (size_t i = 0; i < indent; ++i) {
            Rcout << "  ";
        }
    }

public:
    BlockTimer(const std::string &what)
        : what(what),
          start(std::chrono::steady_clock::now())
    {
        indentation();
        Rcout << "BEGIN " << what << std::endl;
        indent++;
    }

    ~BlockTimer()
    {
        std::chrono::steady_clock::time_point end = std::chrono::steady_clock::now();
        indent--;
        indentation();
        Rcout << "END " << what << ": "  <<
            (std::chrono::duration_cast<std::chrono::microseconds>(end - start).count() / 1000.0) <<
            "ms" << std::endl;
    }
};


class IncrementalTimer {
    std::string what;
    int64_t duration;

public:
    IncrementalTimer(const std::string &what)
        : what(what),
          duration(0)
    { }

    void report()
    {
        Rcout << "INC_TIMER " << what << ": " << (duration / 1000.0) <<
            "ms" << std::endl;
        duration = 0;
    }

    void increment(int64_t microseconds)
    { duration += microseconds; }
};


static deque<IncrementalTimer> globalIncrementalTimerPool;


class IncrementalTimer_Measurer {
    std::chrono::steady_clock::time_point start;
    size_t parent;

public:
    IncrementalTimer_Measurer(size_t parent)
        : start(std::chrono::steady_clock::now()),
          parent(parent)
    { }

    ~IncrementalTimer_Measurer()
    {
        std::chrono::steady_clock::time_point end = std::chrono::steady_clock::now();
        int64_t duration = std::chrono::duration_cast<std::chrono::microseconds>(end - start).count();
        globalIncrementalTimerPool.at(parent).increment(duration);
    }
};


#ifdef PERFORMANCE_MEASUREMENT
#    define BLOCK_TIMER(var, what) BlockTimer var(what)
#    define START_TIMER(var, what) BlockTimer* var = new BlockTimer(what)
#    define STOP_TIMER(var) delete var

#    define BLOCK_INC_TIMER(svar, var, what)                                \
        [[maybe_unused]] static size_t svar = [] {                          \
            globalIncrementalTimerPool.emplace_back(what);                  \
            return globalIncrementalTimerPool.size() - 1;                   \
        }();                                                                \
        IncrementalTimer_Measurer var(svar)

#    define CLEAR_INC_TIMERS()                                              \
        Rcout << endl;                                                      \
        for (auto& t : globalIncrementalTimerPool) t.report()

#else
#    define BLOCK_TIMER(var, what)
#    define START_TIMER(var, what)
#    define STOP_TIMER(var)
#    define BLOCK_INC_TIMER(svar, var, what)
#    define CLEAR_INC_TIMERS()
#endif
