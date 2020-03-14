.onLoad <- future.tests:::.onLoad

message("*** .onLoad() ...")

.onLoad("future.tests", "future.tests")

options(future.tests.cmdargs = c("--cores=2"))
.onLoad("future.tests", "future.tests")

message("*** .onLoad() ... DONE")
