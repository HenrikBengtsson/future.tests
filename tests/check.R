## Display --help
future.tests::check()

## Run checks with plan(sequential)
results <- future.tests::check(args = list("--test-plan=sequential"))
print(results)
