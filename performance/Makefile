COMMITS := \
	865683a8400eb40ea3c9345efa8f897e628b0bfe \
	da2c099e5d0d3e56c905bf51bdea0f75a8f5e657 \
	2a8a347f3a74ef17d37d09ae7eecd74263dad0d1 \
	0d6a9d80fc8ad98bda19f6a64fb62bd51d6994b1 \
    2fd9cd88299f29ff0a8bd3b0f93a5e35c7c6e5a0 \
    1be5c2db96e2ca33ef008c7bd4dde131f4e89ac6 \
	b10572617c60c3cb4bd03713fa7f1f586b820a53 \
	303bdc31dfa4cd8cde5cdad618bdb4256ee4f969 \
	current

	# 865683a8400eb40ea3c9345efa8f897e628b0bfe  2026-01-23  Rewritten AssocStorage to collect results directly to DataSet
	# da2c099e5d0d3e56c905bf51bdea0f75a8f5e657  2025-12-18  Further optimizations of CustomBitSet
	# 2a8a347f3a74ef17d37d09ae7eecd74263dad0d1  2025-12-18  Optimize CustomBitSet
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
