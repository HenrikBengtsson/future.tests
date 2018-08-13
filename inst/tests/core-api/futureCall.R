library(future)

future.tests::context("- futureCall() - sequential + lazy")

f1 <- future(do.call(rnorm, args = list(n = 100)), lazy = TRUE)
f2 <- futureCall(rnorm, args = list(n = 100), lazy = TRUE)

set.seed(42L)
v0 <- rnorm(n = 100)
str(list(v0 = v0))

set.seed(42L)
v1 <- value(f1)
str(list(v1 = v1))

set.seed(42L)
v2 <- value(f2)
str(list(v2 = v2))

## Because we use lazy futures and set the
## random seed just before they are resolved
stopifnot(all.equal(v1, v0))
stopifnot(all.equal(v1, v2))


future.tests::context("- futureCall() - mix of strategies, cores, lazy and globals")

a <- 3
args <- list(x = 42, y = 12)
v0 <- do.call(function(x, y) a * (x - y), args = args)

future.tests::along_cores({
  future.tests::along_strategies({
    for (lazy in c(FALSE, TRUE)) {
      for (globals in c(FALSE, TRUE)) {
        a <- 3
        args <- list(x = 42, y = 12)
        f <- futureCall(function(x, y) a * (x - y), args = args,
                        globals = globals, lazy = lazy)
        rm(list = c("a", "args"))
        print(f)
        res1 <- tryCatch({
          v1 <- value(f)
        }, error = identity)
        stopifnot(!inherits(res1, "FutureError"))
        if (!inherits(res1, "error")) {
          str(list(globals = globals, lazy = lazy, v0 = v0, v1 = v1))
          stopifnot(all.equal(v1, v0))
        } else {
          stopifnot(!globals)
        }

        a <- 3
        args <- list(x = 42, y = 12)
        f <- futureCall(function(x, y) a * (x - y), args = args,
                        globals = "a", lazy = lazy)
        rm(list = c("a", "args"))
        print(f)
        res2 <- tryCatch({
          v2 <- value(f)
        }, error = identity)
        stopifnot(!inherits(res2, "FutureError"))
        if (!inherits(res2, "error")) {
          str(list(globals = globals, lazy = lazy, v0 = v0, v2 = v2))
          stopifnot(all.equal(v2, v0))
        } else {
          stopifnot(!globals)
        }
        
        args <- list(x = 42, y = 12)
        f <- futureCall(function(x, y) a * (x - y), args = args,
                        globals = list(a = 3), lazy = lazy)
        rm(list = "args")
        print(f)
        res3 <- tryCatch({
          v3 <- value(f)
        }, error = identity)
        stopifnot(!inherits(res3, "FutureError"))
        if (!inherits(res3, "error")) {
          str(list(globals = globals, lazy = lazy, v0 = v0, v3 = v3))
          stopifnot(all.equal(v3, v0))
        } else {
          stopifnot(!globals)
        }

        rm(list = c("v1", "v2", "v3"))
      }
    }
  })
})


