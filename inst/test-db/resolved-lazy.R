make_test(title = "resolved() - assert non-blocking while launching lazy futures", args = list(), tags = c("resolved", "lazy"), reset_workers = TRUE, {
  ## BACKWARD COMPATIBILITY:
  ## In future (<= 1.16.0), values() was used instead of value() for lists
  if (packageVersion("future") <= "1.16.0") value <- values

  message("Creating lazy futures:")

  n <- min(3, nbrOfWorkers() + 1L)
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
  rs <- rep(NA, times = length(fs))

  for (ff in seq_along(fs)) {
    for (kk in ff:length(fs)) {
      message(sprintf("Checking if future #%d is resolved:", kk))
      rs[[kk]] <- resolved(fs[[kk]])
      ss <- vapply(fs, FUN = function(f) f$state, NA_character_)
      print(ss)
      nbrOfFinished <- sum(ss == "finished")
      if (inherits(fs[[kk]], "UniprocessFuture")) {
        stopifnot(rs[[kk]])
        stopifnot(ss[[kk]] == "finished")
      } else if (inherits(fs[[kk]], "MultiprocessFuture")) {
        if (nbrOfWorkers() + ff - 1L + nbrOfFinished >= kk) {
          ## Failed for 'multicore' when running full set of tests or
          ## with --test-tags="lazy". Why?!?  /HB 2019-11-11
          stopifnot(ss[[kk]] == "running")
##        R.utils::cstr(list(c(ff,kk), rs=rs, ss=ss, check=(ss[[kk]] == "running")))
        } else {
          stopifnot(ss[[kk]] == "created")
        }
        stopifnot(!rs[[kk]])
      }
    } ## for (kk ...)
  
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
