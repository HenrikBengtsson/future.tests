include .make/Makefile

## Using 'unbuffer' below, will prevent 'tee' from dropping colors
## when splitting the output.
## Ubuntu: sudo apt-get install expect
UNBUFFER=unbuffer
UNBUFFER=

.results/%.out:
	mkdir -p .results
	$(UNBUFFER) $(R_SCRIPT) -e "future.tests::check" --args --test-plan=$* | tee .results/$*.out

.results/all: .results/sequential.out .results/multicore.out .results/multisession.out .results/cluster.out .results/future.callr\:\:callr.out .results/future.batchtools\:\:batchtools_local.out

.results/summary:
	cd .results; \
	grep -E "(Duration|Results)" *.out | sed -E 's/(Duration: |Results: | ? )//' | sed 'N;s/\n/ | /'

test-all: .results/all

test-summary: .results/summary
