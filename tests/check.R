check <- future.tests::check

message("*** check() ...")

## Validate options
check()
check(.args = c("--debug", "--help"))

## Run checks with plan(sequential)
results <- check(plan = "sequential", session_info = TRUE, debug = TRUE)
print(results)

## Run checks with plan(sequential) from CLI
results <- check(.args = c("--debug", "--test-timeout=30", "--test-tags=resolve,rng", "--test-plan=sequential"))
print(results)

message("*** check() ... DONE")
