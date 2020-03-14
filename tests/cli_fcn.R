check <- future.tests::check

message("*** cli_fcn() ...")

options(future.tests.cmdargs = c("--help"))
print(check, call = TRUE)

message("*** cli_fcn() ... DONE")
