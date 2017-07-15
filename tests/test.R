library("future.tests")
library("future")
plan(sequential)

assert_future_explicit({
  42L
}, prepend = { Sys.sleep(0.5) })

x <- 42
assert_future_explicit({
  2 * x
}, prepend = { Sys.sleep(0.5) })

