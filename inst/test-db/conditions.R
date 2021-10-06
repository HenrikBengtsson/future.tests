captureConditions <- function(...) {
  conditions <- list()
  withCallingHandlers(..., condition = function(c) {
    conditions[[length(conditions) + 1L]] <<- c
    if (inherits(c, "message")) {
      invokeRestart("muffleMessage")
    } else if (inherits(c, "warning")) {
      invokeRestart("muffleWarning")
    }	
  })
  conditions
}


make_test(title = "future() - conditions", args = list(), tags = c("future", "conditions"), bquote({
  captureConditions <- .(captureConditions)
  
  truth <- captureConditions({
    message("hello")
    warning("whoops")
    message("world")
  })
  
  f <- future({
    print(1:3)
    message("hello")
    warning("whoops")
    message("world")
    42L
  })
  
  r <- result(f)
  str(r)
  stopifnot(value(f) == 42L)

  conditions <- r$conditions
  stopifnot(is.list(conditions), length(conditions) == 3L)
  conditions <- lapply(conditions, FUN = function(c) c$condition)
  for (kk in seq_along(conditions)) {
    stopifnot(
      identical(class(conditions[[kk]]), class(truth[[kk]])),
      identical(conditions[[kk]]$message, truth[[kk]]$message)
    )
  }

  conditions <- captureConditions(value(f))
  stopifnot(is.list(conditions), length(conditions) == 3L)
  for (kk in seq_along(conditions)) {
    stopifnot(
      identical(class(conditions[[kk]]), class(truth[[kk]])),
      identical(conditions[[kk]]$message, truth[[kk]]$message)
    )
  }
}), substitute = FALSE)


make_test(title = "%<-% - conditions", args = list(), tags = c("%<-%", "conditions"), bquote({
  captureConditions <- .(captureConditions)
  
  truth <- captureConditions({
    message("hello")
    warning("whoops")
    message("world")
  })
  
  v %<-% {
    print(1:3)
    message("hello")
    warning("whoops")
    message("world")
    42L
  }

  conditions <- captureConditions(v)
  stopifnot(v == 42L)
  stopifnot(is.list(conditions), length(conditions) == 3L)
  for (kk in seq_along(conditions)) {
    stopifnot(
      identical(class(conditions[[kk]]), class(truth[[kk]])),
      identical(conditions[[kk]]$message, truth[[kk]]$message)
    )
  }
}), substitute = FALSE)


make_test(title = "future() - muffle conditions", args = list(), tags = c("future", "conditions", "muffle"), bquote({
  captureConditions <- .(captureConditions)
  
  f <- future({
    print(1:3)
    message("hello")
    warning("whoops")
    message("world")
    42L
  }, conditions = character(0L))
  
  r <- result(f)
  str(r)
  stopifnot(value(f) == 42L)

  conditions <- r$conditions
  stopifnot(is.list(conditions), length(conditions) == 0L)

  conditions <- captureConditions(value(f))
  stopifnot(is.list(conditions), length(conditions) == 0L)
}), substitute = FALSE)
