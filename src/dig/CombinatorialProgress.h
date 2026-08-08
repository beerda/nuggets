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
        /**
         * Constructs a new Batch object with the given progress, starting point,
         * and total work to be done.
         *
         * @param progress A pointer to the CombinatorialProgress object that will
         *     be updated when the Batch is destroyed.
         * @param onStart The starting point of the work represented by this Batch.
         * @param total The total amount of work represented by this Batch.
         */
        Batch(CombinatorialProgress* progress, size_t onStart, size_t total)
            : progress(progress), total(total), onStart(onStart)
        { }

        /**
         * Destructor for the Batch class. When a Batch object is destroyed, it
         * updates the associated CombinatorialProgress object to reflect the
         * total work done in this Batch.
         */
        ~Batch()
        {
            progress->set(onStart + total);
        }

    private:
        /**
         * A pointer to the CombinatorialProgress object that will be updated when
         * the Batch is destroyed.
         */
        CombinatorialProgress* progress;

        /**
         * The total amount of work represented by this Batch.
         */
        size_t total;

        /**
         * The starting point of the work represented by this Batch.
         */
        size_t onStart;
    };


    /**
     * Constructs a new CombinatorialProgress object with the given maximum level
     * and number of elements. It initializes the binomial coefficients table,
     * computes the total amount of work to be done, and sets the actual work done
     * to zero.
     *
     * @param maxLevel The maximum level of the combinatorial tree.
     * @param elements The number of elements to be combined.
     */
    CombinatorialProgress(size_t maxLevel, size_t elements)
        : table(elements),
          maxLevel(min(maxLevel, elements)),
          total(computeSize(maxLevel, elements)),
          actual(0),
          bar(R_NilValue)
    { }

    /**
     * Destructor for the CombinatorialProgress class. It finalizes the progress
     * bar if it has been assigned.
     */
    ~CombinatorialProgress()
    {
        if (bar) {
            cli_progress_set(bar, total);
            cli_progress_done(bar);
        }
    }

    /**
     * Creates a new Batch object representing a sub-tree of combinations at the
     * given current level and with the given number of current elements. The
     * Batch object will update the CombinatorialProgress when it is destroyed.
     *
     * @param currentLevel The current level of the combinatorial tree.
     * @param currentElements The number of elements to be combined at the current level.
     * @return A new Batch object representing the sub-tree of combinations.
     */
    Batch createBatch(size_t currentLevel, size_t currentElements)
    {
        size_t batchTotal = computeSize(maxLevel - currentLevel, currentElements);
        return Batch(this, actual, batchTotal);
    }

    /**
     * Sets the actual work done to the given value and updates the progress bar.
     *
     * @param value The new value of actual work done.
     */
    inline void set(const size_t value)
    {
        actual = value;
        updateBar();
    }

    /**
     * Increments the actual work done by the given value and updates the progress bar.
     *
     * @param inc The amount to increment the actual work done.
     */
    inline void increment(const size_t inc)
    {
        actual += inc;
        updateBar();
    }

    /**
     * Returns the actual work done so far.
     *
     * @return The actual work done so far.
     */
    inline size_t getActual() const
    { return actual; }

    /**
     * Returns the total amount of work to be done.
     *
     * @return The total amount of work to be done.
     */
    inline size_t getTotal() const
    { return total; }

    /**
     * Assigns the R CLI progress bar to this CombinatorialProgress object and
     * updates the progress bar to reflect the current actual work done.
     *
     * @param bar The R CLI progress bar to be assigned.
     */
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

    /**
     * Updates the R CLI progress bar to reflect the current actual work done.
     * If the progress bar has been assigned, it checks for user interrupts and
     * updates the progress bar with the current actual work done.
     */
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
