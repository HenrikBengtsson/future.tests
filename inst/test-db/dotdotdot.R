make_test(title = "Argument '...'", tags = c("%<-%", "..."), {
  fcn <- function(x, ...) {
    message("Arguments '...' exists: ", exists("...", inherits = TRUE))
    y %<-% { sum(x, ...) }
    y
  }
  y <- try(fcn(1:2, 3))
  print(y)
  stopifnot(y == 6)
})


make_test(title = "Argument '...' from parent function", tags = c("%<-%", "..."), {
  fcn <- function(x, ...) {
    sumt <- function(x) {
      message("Arguments '...' exists: ", exists("...", inherits = TRUE))
      y %<-% { sum(x, ...) }
      y
    }
    sumt(x)
  }
  y <- try(fcn(1:2, 3))
  print(y)
  stopifnot(y == 6)
})


make_test(title = "Argument '...' - non existing", tags = c("%<-%", "..."), {
  fcn <- function(x, y) {
    message("Arguments '...' exists: ", exists("...", inherits = TRUE))
    y %<-% { sum(x, y) }
    y
  }
  y <- try(fcn(1:2, 3))
  print(y)
  stopifnot(y == 6)
})


make_test(title = "Argument '...' - exception", tags = c("%<-%", "..."), {
  fcn <- function(x, y) {
    message("Arguments '...' exists: ", exists("...", inherits = TRUE))
    y %<-% { sum(x, y, ...) }
    y
  }
  y <- try(fcn(1:2, 3))
  print(y)
  stopifnot(inherits(y, "try-error"))
})
