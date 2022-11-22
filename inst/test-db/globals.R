## https://github.com/HenrikBengtsson/future.tests/issues/14
make_test(title = "future() - non-exported package objects", tags = c("future", "globals"), {
  if (requireNamespace("utils") && require("utils")) {
    ## Find a non-exported 'utils' function
    env <- pos.to.env(match("package:utils", search()))
    ns <- getNamespace("utils")
    privates <- setdiff(names(ns), names(env))
    non_exported <- NULL
    for (name in privates) {
      if (exists(name, envir = ns, mode = "function", inherits = FALSE)) {
        non_exported <- get(name, envir = ns, mode = "function", inherits = FALSE)
      }
    }
    stopifnot(is.function(non_exported))

    ## Use this non-exported function in a future
    f <- future({ non_exported }, lazy = TRUE)

    ## Assert that it is identified as a global
    stopifnot(
      "non_exported" %in% names(f$globals),
      identical(f$globals[["non_exported"]], non_exported)
    )
    v <- value(f)
    stopifnot(identical(v, non_exported))
  }
})
