make_test(title = "resolved() - assert non-blocking while launching lazy futures", args = list(), tags = c("resolved", "lazy"), reset_workers = TRUE, {
  message("Creating lazy futures:")

  if (!is.finite(nbrOfWorkers())) {
    future.tests::skip_test("Test requires a finite number of workers")
  }

  ## Create at most three futures (two if a uniprocess future)
  n <- min(3L, nbrOfWorkers() + 1L)
  xs <- as.list(1:n)
  fs <- lapply(xs, FUN = function(kk) {
    future({
      Sys.sleep(kk)
      kk
    }, lazy = TRUE)
  })

  vs <- vector("list", length = length(fs))
  ss <- vapply(fs, FUN = function(f) f$state, NA_character_)
  print(ss)
  stopifnot(all(ss == "created"))
  ## cat("[OK] None of the created futures have launched\n")

  rs <- rep(NA, times = length(fs))
  for (ff in seq_along(fs)) {
    for (kk in ff:length(fs)) {
      ## cat(sprintf("Checking if future #%d of %d is resolved:\n", kk, length(fs)))
      message(sprintf("Checking if future #%d is resolved:", kk))
      ## resolved() should launch the future, if it is not yet launched
      rs[[kk]] <- resolved(fs[[kk]])
      
      ss <- vapply(fs, FUN = function(f) f$state, NA_character_)
      print(ss)
      nbrOfFinished <- sum(ss == "finished")
      if (inherits(fs[[kk]], "UniprocessFuture")) {
        ## As lazy *uniprocess* future will be launched *and* resolved
        ## in one go when we call resolved() above
        stopifnot(rs[[kk]])
        stopifnot(ss[[kk]] == "finished")
      } else if (inherits(fs[[kk]], "MultiprocessFuture")) {
        stopifnot(!rs[[kk]])
        stopifnot(ss[[kk]] == "running")
      }
    } ## for (kk ...)

    if (ff == 1L && inherits(fs[[1]], "MultiprocessFuture")) {
      stopifnot(all(!rs[[kk]]))
    }

    message(sprintf("Waiting for future #%d to finish ... ", ff), appendLF = FALSE)
    vs[[ff]] <- value(fs[[ff]])
    message("done")

    rs[[ff]] <- resolved(fs[[ff]])
    stopifnot(rs[ff])

    ss <- vapply(fs, FUN = function(f) f$state, NA_character_)
    stopifnot(ss[ff] == "finished")
    nbrOfFinished <- sum(ss == "finished")
    if (inherits(fs[[kk]], "UniprocessFuture")) {
      stopifnot(nbrOfFinished == length(fs))
    } else {
      stopifnot(nbrOfFinished == ff)
    }
  } ## for (ff ...)
  
  ss <- vapply(fs, FUN = function(f) f$state, NA_character_)
  print(ss)
  stopifnot(all(ss == "finished"))

  message("Collecting values:")
  vs <- value(fs)
  str(vs)
  stopifnot(identical(vs, xs))
})
