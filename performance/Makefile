COMMITS := \
	0d6a9d80fc8ad98bda19f6a64fb62bd51d6994b1 \
    2fd9cd88299f29ff0a8bd3b0f93a5e35c7c6e5a0 \
    1be5c2db96e2ca33ef008c7bd4dde131f4e89ac6 \
	b10572617c60c3cb4bd03713fa7f1f586b820a53 \
	303bdc31dfa4cd8cde5cdad618bdb4256ee4f969 \
	current

	# 0d6a9d80fc8ad98bda19f6a64fb62bd51d6994b1  2025-12-18  Removed dependency on Boost dynamic_bitset
	# 2fd9cd88299f29ff0a8bd3b0f93a5e35c7c6e5a0  2025-12-18  Fixed references
	# 1be5c2db96e2ca33ef008c7bd4dde131f4e89ac6  2025-12-18  dig_associations()'s callback written in C++
	# b10572617c60c3cb4bd03713fa7f1f586b820a53  2025-12-18  Selector is made singleton to avoid allocation
	# 303bdc31dfa4cd8cde5cdad618bdb4256ee4f969  2025-12-18  Base for comparison: BitChain

TESTS := \
	test-assoc_m1e7_n10_maxlen4.R \
	test-assoc_m1e7_n20_maxlen4.R

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
