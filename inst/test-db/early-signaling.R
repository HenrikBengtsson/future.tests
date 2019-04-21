make_test(title = "Early signaling of errors", args = list(lazy = c(FALSE, TRUE), earlySignal = c(FALSE, TRUE)), tags = c("earlySignal", "resolved", "resolve"), {
  res <- tryCatch({
    f <- future({ stop("bang!") }, lazy = lazy, earlySignal = earlySignal)
    stopifnot(inherits(f, "Future"))
 
    r <- resolved(f)
  
    v <- tryCatch(value(f), error = identity)
    stopifnot(inherits(v, "error"), conditionMessage(v) == "bang!")

    TRUE
  }, error = identity)

  stopifnot(inherits(res, "error") || isTRUE(res))
})


make_test(title = "Early signaling of warnings", args = list(lazy = c(FALSE, TRUE), earlySignal = c(FALSE, TRUE)), tags = c("earlySignal", "resolved", "resolve"), {
  res <- tryCatch({
    f <- future({ warning("watch out!") }, lazy = lazy, earlySignal = earlySignal)
    stopifnot(inherits(f, "Future"))
 
    r <- resolved(f)
  
    v <- tryCatch(value(f), warning = identity)
    stopifnot(inherits(v, "warning"), conditionMessage(v) == "watch out!")

    TRUE
  }, error = identity)

  stopifnot(inherits(res, "error") || isTRUE(res))
})


make_test(title = "Early signaling of messages", args = list(lazy = c(FALSE, TRUE), earlySignal = c(FALSE, TRUE)), tags = c("earlySignal", "resolved", "resolve"), {
  res <- tryCatch({
    f <- future({ message("hello world!") }, lazy = lazy, earlySignal = earlySignal)
    stopifnot(inherits(f, "Future"))
 
    r <- resolved(f)
  
    v <- tryCatch(value(f), message = identity)
    stopifnot(inherits(v, "message"), conditionMessage(v) == "hello world!")

    TRUE
  }, error = identity)

  stopifnot(inherits(res, "error") || isTRUE(res))
})

## ## Condition
## f <- future({ signalCondition(simpleCondition("hmm")) }, lazy = TRUE)
## res <- tryCatch({
##   r <- resolved(f)
## }, condition = function(w) w)
## stopifnot(inherits(res, "condition"))
