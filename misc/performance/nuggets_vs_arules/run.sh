#!/bin/bash

sudo cpupower frequency-set -g performance
taskset -c 0 Rscript ./run_test.R
