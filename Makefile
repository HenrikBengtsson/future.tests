include .make/Makefile

## Using 'unbuffer' below, will prevent 'tee' from dropping colors
## when splitting the output.
## Ubuntu: sudo apt-get install expect
UNBUFFER=unbuffer
UNBUFFER=

backend_results/%.out:
	mkdir -p backend_results
	$(UNBUFFER) $(R_SCRIPT) -e "future.tests::check" --args --test-plan=$* | tee backend_results/$*.out

backend_results/all: backend_results/sequential.out backend_results/multicore.out backend_results/multisession.out backend_results/cluster.out backend_results/future.callr\:\:callr.out backend_results/future.batchtools\:\:batchtools_local.out backend_results/future.BatchJobs\:\:batchjobs_local.out

backend_results/summary:
	cd backend_results; \
	grep -E "(Duration|Results)" *.out | sed -E 's/.out://' | sed -E 's/(Duration: |.*Results: )/\t/' | sed 'N;s/\n/\t/' | sed 's/ | /\t/' | sed 's/\t\t/\t/' | sed 's/ ✔//g' > summary.tsv
	cat $@.tsv

test-all: backend_results/all
	$(MAKE) backend_results/summary

test-summary: backend_results/summary
