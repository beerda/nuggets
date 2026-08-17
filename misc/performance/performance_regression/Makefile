COMMITS := \
	4485d4e1b611ed460025b2afcd65e556d8f665e8 \
    90a9d754908030dcff38ef3c37f516841655a03a \
	b2702ff83bc45d803edd3ad5e88c10f0ac9f8e59 \
	#154e3d247e2921a34572b018c7970d320efcf2e2 \
	#fa41c43c0261ffca62cd09282df448830ed31095 \
	#e2b8dbb608d2ab42d71224c7541e899f79a70483 \
	#865683a8400eb40ea3c9345efa8f897e628b0bfe \
	#da2c099e5d0d3e56c905bf51bdea0f75a8f5e657 \
	#2a8a347f3a74ef17d37d09ae7eecd74263dad0d1 \
	#0d6a9d80fc8ad98bda19f6a64fb62bd51d6994b1 \
    #2fd9cd88299f29ff0a8bd3b0f93a5e35c7c6e5a0 \
    #1be5c2db96e2ca33ef008c7bd4dde131f4e89ac6 \
	#b10572617c60c3cb4bd03713fa7f1f586b820a53 \
	#303bdc31dfa4cd8cde5cdad618bdb4256ee4f969 \
	#current

	# 4485d4e1b611ed460025b2afcd65e556d8f665e8  2026-08-17  Added Digger::prefix + better Cache
	# 90a9d754908030dcff38ef3c37f516841655a03a  2026-07-22  v2.2.2
	# b2702ff83bc45d803edd3ad5e88c10f0ac9f8e59  2026-03-12  v2.2.0
	# 154e3d247e2921a34572b018c7970d320efcf2e2  2026-02-02  Fix alignment in Bitset + use libpopcount library
	# fa41c43c0261ffca62cd09282df448830ed31095  2026-01-30  Optimized AssocStorage
	# e2b8dbb608d2ab42d71224c7541e899f79a70483  2026-01-28  Cache of itemset supports
	# 865683a8400eb40ea3c9345efa8f897e628b0bfe  2026-01-23  Rewritten AssocStorage to collect results directly to DataSet
	# 2a8a347f3a74ef17d37d09ae7eecd74263dad0d1  2025-12-18  Optimize CustomBitSet
	# 0d6a9d80fc8ad98bda19f6a64fb62bd51d6994b1  2025-12-18  Removed dependency on Boost dynamic_bitset
	# 2fd9cd88299f29ff0a8bd3b0f93a5e35c7c6e5a0  2025-12-18  Fixed references
	# 1be5c2db96e2ca33ef008c7bd4dde131f4e89ac6  2025-12-18  dig_associations()'s callback written in C++
	# 303bdc31dfa4cd8cde5cdad618bdb4256ee4f969  2025-12-18  Base for comparison: BitChain

TESTS := \
	test-assoc_m1e7_n10_maxlen4.R \
	test-assoc_m1e7_n20_maxlen4.R \
	test-assoc_m1e6_n10_maxlen4_fuzzy.R


RESULTS_DIR := results
OUTPUTS := $(addprefix $(RESULTS_DIR)/, $(addsuffix .rds, $(COMMITS)))


all: result.rds

$(RESULTS_DIR):
	mkdir -p $(RESULTS_DIR)

result.rds:	result.R $(RESULTS_DIR) $(OUTPUTS)
	Rscript ./result.R $(OUTPUTS)

$(RESULTS_DIR)/%.rds:	run.R $(TESTS) | $(RESULTS_DIR)
	sudo cpupower frequency-set -g performance
	taskset -c 0 Rscript ./run.R $(basename $(notdir $@)) $(TESTS)

# Prevent deletion of intermediate files
.PRECIOUS: $(RESULTS_DIR)/%.rds

# Phony target to clean generated files
clean:
	rm -f $(RESULTS_DIR)/*.rds
	rmdir --ignore-fail-on-non-empty $(RESULTS_DIR)
