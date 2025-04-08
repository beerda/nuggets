COMMITS := \
	9621b790605d5dbde3d479270881cc35ae845da1 \
	1e68816f66fcf708ad88d1ef8b0cf72c1d48a210 \
	172a3097e2cbb9eb6069a3f909f0b16d8754e9fd \
	49bb894c97f2a0ad559d0adab132dfef5728bbbb \
	abf05b967f8b9ea7b545797eb19d5c189335b9e6 \
	current

#	9621b790605d5dbde3d479270881cc35ae845da1	2025-04-03	Refactored Task::compute..FocusChain()
#	1e68816f66fcf708ad88d1ef8b0cf72c1d48a210    2025-04-03	Added local task sequence mechanism to Digger::run()
#	172a3097e2cbb9eb6069a3f909f0b16d8754e9fd	2025-04-03	Before "Added local task sequence mechanism to Digger::run()"
#	49bb894c97f2a0ad559d0adab132dfef5728bbbb	2025-04-03	Refactored Digger.h: created CallbackCaller.h
#	abf05b967f8b9ea7b545797eb19d5c189335b9e6	2025-02-26	Added RcppThread, handling of user interrupt, and improved error handling in parallel code

TESTS := \
	test-assoc_t1.R \
	test-assoc_t20.R

RESULTS_DIR := results
OUTPUTS := $(addprefix $(RESULTS_DIR)/, $(addsuffix .rds, $(COMMITS)))


all: result.rds

$(RESULTS_DIR):
	mkdir -p $(RESULTS_DIR)

result.rds:	result.R $(RESULTS_DIR) $(OUTPUTS)
	Rscript ./result.R $(OUTPUTS)

$(RESULTS_DIR)/%.rds:	run.R $(TESTS) | $(RESULTS_DIR)
	Rscript ./run.R $(basename $(notdir $@)) $(TESTS)

# Prevent deletion of intermediate files
.PRECIOUS: $(RESULTS_DIR)/%.rds

# Phony target to clean generated files
clean:
	rm -f $(RESULTS_DIR)/*.rds
	rmdir --ignore-fail-on-non-empty $(RESULTS_DIR)
