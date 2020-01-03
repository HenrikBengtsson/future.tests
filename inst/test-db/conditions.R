make_test(title = "future() - conditions", args = list(), tags = c("future", "conditions"), {
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
})


make_test(title = "%<-% - conditions", args = list(), tags = c("%<-%", "conditions"), {
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
})
