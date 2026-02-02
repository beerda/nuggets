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

#include "../common.h"
#include <cli/progress.h>
#include <R.h>
#include <Rinternals.h>

#include "BinomialCoefficients.h"


/**
 * A helper class for providing a progress bar for tasks that are of combinatorial
 * nature, i.e., that the amount of work is based on the number of combinations
 * of elements, as in the case of searching for frequent itemsets.
 */
class CombinatorialProgress {
public:
    /**
     * The Batch is intended to be created in the beginning of some section
     * of the combinatorial algorithm. It ensures that after the whole section
     * ends, the CombinatorialProgress is set appropriately regardless of
     * the increments made inside of the section.
     * Batch represents the whole sub-tree of combinations. In the destructor
     * of Batch, the amount of work corresponding to that sub-tree is set to the
     * progress.
     */
    class Batch {
    public:
        Batch(CombinatorialProgress* progress, size_t onStart, size_t total)
            : progress(progress), total(total), onStart(onStart)
        { }

        ~Batch()
        {
            progress->set(onStart + total);
        }

    private:
        CombinatorialProgress* progress;
        size_t total;
        size_t onStart;
    };


    CombinatorialProgress(size_t maxLevel, size_t elements)
        : table(elements),
          maxLevel(min(maxLevel, elements)),
          total(computeSize(maxLevel, elements)),
          actual(0),
          bar(R_NilValue)
    { }

    ~CombinatorialProgress()
    {
        if (bar) {
            cli_progress_set(bar, total);
            cli_progress_done(bar);
        }
    }

    Batch createBatch(size_t currentLevel, size_t currentElements)
    {
        size_t batchTotal = computeSize(maxLevel - currentLevel, currentElements);
        return Batch(this, actual, batchTotal);
    }

    inline void set(const size_t value)
    {
        actual = value;
        updateBar();
    }

    inline void increment(const size_t inc)
    {
        actual += inc;
        updateBar();
    }

    inline size_t getActual() const
    { return actual; }

    inline size_t getTotal() const
    { return total; }

    inline void assignBar(SEXP bar)
    {
        this->bar = bar;
        updateBar();
    }
private:
    /**
     * A table of binomial coefficients
     */
    BinomialCoefficients table;

     /**
      * Maximum level of the combinatorial tree
      */
    size_t maxLevel;

    /**
     * Total number of work to be done
     */
    size_t total;

    /**
     * The actual number of work to be already done
     */
    size_t actual;

    /**
     * R CLI progress bar
     */
    SEXP bar;


    void updateBar()
    {
        if (CLI_SHOULD_TICK) {
            R_CheckUserInterrupt();
            if (bar) {
                cli_progress_set(bar, actual);
            }
        }
    }

    /**
     * Compute the size of the task based on levels and elements.
     * The function returns b(n, 0) + b(n, 1) + ... + b(n, k),
     * where "n" is the number of elements and "k" is the number of levels.
     */
    inline size_t computeSize(const size_t levels, const size_t elements) const
    {
        size_t size = 1;
        for (size_t i = 1; i <= min(levels, elements); ++i) {
            size += table.get(elements, i);
        }

        return size;
    }
};
