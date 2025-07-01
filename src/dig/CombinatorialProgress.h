#pragma once

#include <RcppThread.h>
#include <cli/progress.h>

#include "../common.h"
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
            //RcppThread::Rcout << "finishing batch: "
                              //<< onStart << " + " << total
                              //<< " = " << (onStart + total) << std::endl;
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
          bar(PROTECT(cli_progress_bar(total, List::create(Named("name") = "searching rules"))))
    {
        //RcppThread::Rcout << "creating progress for "
                          //<< this->maxLevel << " levels and "
                          //<< elements << " elements: total = "
                          //<< this->total << std::endl;
    }

    ~CombinatorialProgress()
    {
        cli_progress_set(bar, total);
        cli_progress_done(bar);
        UNPROTECT(1);
    }

    Batch createBatch(size_t currentLevel, size_t currentElements)
    {
        size_t batchTotal = computeSize(maxLevel - currentLevel, currentElements);
        //RcppThread::Rcout << "creating batch for level " << currentLevel
                          //<< " with " << currentElements << " elements: total = "
                          //<< total << std::endl;
        return Batch(this, actual, batchTotal);
    }

    void set(size_t value)
    {
        actual = value;
        updateBar();
        //RcppThread::Rcout << "progress: " << actual << "/" << total << std::endl;
    }

    void increment(size_t inc)
    {
        actual += inc;
        updateBar();
        //RcppThread::Rcout << "progress: " << actual << "/" << total << std::endl;
    }

    size_t getActual() const
    { return actual; }

    size_t getTotal() const
    { return total; }

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
            RcppThread::checkUserInterrupt();
            cli_progress_set(bar, actual);
        }
    }

    /**
     * Compute the size of the task based on levels and elements.
     * The function returns b(n, 0) + b(n, 1) + ... + b(n, k),
     * where "n" is the number of elements and "k" is the number of levels.
     */
    size_t computeSize(size_t levels, size_t elements) const
    {
        size_t size = 1;
        for (size_t i = 1; i <= min(levels, elements); ++i) {
            size += table.get(elements, i);
        }

        return size;
    }
};
