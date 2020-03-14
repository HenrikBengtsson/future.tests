cli_fcn <- future.tests:::cli_fcn
check <- future.tests::check

message("*** cli_fcn() ...")

options(future.tests.cmdargs = c("--help"))
print(check, call = TRUE)
print(check, call = FALSE)

citation <- cli_fcn(utils::citation)
print(citation)

message("*** cli_fcn() ... DONE")
