make_test(title = 'Random Number Generation (RNG) - seeds', tags = c("rng", "seed"), {
  ## A valid L'Ecuyer-CMRG RNG seed
  seed <- c(407L, 1420090545L, 65713854L, -990249945L,
            1780737596L, -1213437427L, 1082168682L)
  f <- future(42, seed = seed)
  print(f)

  stopifnot(identical(f$seed, seed))
})



## See Section 6 on 'Random-number generation' in
## vignette("parallel", package = "parallel")
fsample <- function(x, size = 2L, seed = NULL, what = c("future", "%<-%"), lazy = FALSE) {
  ## BACKWARD COMPATIBILITY:
  ## In future (<= 1.16.0), values() was used instead of value() for lists
  if (packageVersion("future") <= "1.16.0") value <- values

  what <- match.arg(what)
  
  ## Must use session-specific '.GlobalEnv' here
  .GlobalEnv <- globalenv()
  
  oseed <- .GlobalEnv$.Random.seed
  orng <- RNGkind("L'Ecuyer-CMRG")[1L]
  on.exit(RNGkind(orng))

  if (!is.null(seed)) {
    ## Reset state of random seed afterwards?
    on.exit({
      if (is.null(oseed)) {
        rm(list = ".Random.seed", envir = .GlobalEnv, inherits = FALSE)
      } else {
        .GlobalEnv$.Random.seed <- oseed
      }
    }, add = TRUE)

    set.seed(seed)
  }

  .seed <- .Random.seed

  if (what == "future") {
    fs <- list()
    for (ii in seq_len(size)) {
      .seed <- parallel::nextRNGStream(.seed)
      fs[[ii]] <- future({ sample(x, size = 1L) }, lazy = lazy, seed = .seed)
    }
    res <- value(fs)
  } else {
    res <- listenv::listenv()
    for (ii in seq_len(size)) {
      .seed <- parallel::nextRNGStream(.seed)
      res[[ii]] %<-% { sample(x, size = 1L) } %lazy% lazy %seed% .seed
    }
    res <- as.list(res)
  }
  
  res
} # fsample()


for (what in c("future", "%<-%")) {
  make_test(title = sprintf('Random Number Generation (RNG) - %s', what), args = list(lazy = c(FALSE, TRUE)), tags = c("rng", "seed", "lazy", what), bquote({
    fsample <- .(fsample)
    
    dummy <- sample(0:3, size = 1L)
    seed0 <- .Random.seed
  
    ## Reference sample with fixed random seed
    y0 <- local({
      print(unclass(plan))
      utils::str(plan)
      old_plan <- plan()
      plan("sequential")
      on.exit(plan(old_plan))
      fsample(0:3, seed = 42L)
    })
    
    ## Assert that random seed is reset
    stopifnot(identical(.GlobalEnv$.Random.seed, seed0))
  
    .GlobalEnv$.Random.seed <- seed0
  
    ## Fixed random seed
    y1 <- fsample(0:3, seed = 42L, what = .(what), lazy = lazy)
    print(y1)
    stopifnot(identical(y1, y0))
  
    ## Assert that random seed is reset
    stopifnot(identical(.GlobalEnv$.Random.seed, seed0))
  
    ## Fixed random seed
    y2 <- fsample(0:3, seed = 42L, what = .(what), lazy = lazy)
    print(y2)
    stopifnot(identical(y2, y1))
    stopifnot(identical(y2, y0))
  
    ## Assert that random seed is reset
    stopifnot(identical(.GlobalEnv$.Random.seed, seed0))
  
    ## No seed
    y3 <- fsample(0:3, what = .(what), lazy = lazy)
    print(y3)
  }), substitute = FALSE)
} ## for (what ...)
