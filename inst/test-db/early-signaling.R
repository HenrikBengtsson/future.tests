make_test(title = "Early signaling of errors", args = list(lazy = c(FALSE, TRUE), earlySignal = c(FALSE, TRUE)), tags = c("earlySignal", "resolved", "resolve"), {
  res <- tryCatch({
    f <- future({ stop("bang!") }, lazy = lazy, earlySignal = earlySignal)
    stopifnot(inherits(f, "Future"))
 
    r <- resolved(f)
  
    v <- tryCatch(value(f), error = identity)
    stopifnot(inherits(v, "error"))

    TRUE
  }, error = identity)

  stopifnot(inherits(res, "error") || isTRUE(res))
})


##   ## Warnings
##   f <- future({ warning("careful!") }, lazy = TRUE)
##   res <- tryCatch({
##     r <- resolved(f)
##   }, condition = function(w) w)
##   str(res)
##   stopifnot(inherits(res, "warning"))
##   
##   ## Messages
##   f <- future({ message("hey!") }, lazy = TRUE)
##   res <- tryCatch({
##     r <- resolved(f)
##   }, condition = function(w) w)
##   stopifnot(inherits(res, "message"))
##   
##   ## Condition
##   f <- future({ signalCondition(simpleCondition("hmm")) }, lazy = TRUE)
##   res <- tryCatch({
##     r <- resolved(f)
##   }, condition = function(w) w)
##   stopifnot(inherits(res, "condition"))
