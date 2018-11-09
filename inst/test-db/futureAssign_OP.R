make_test(title = "%<-% - local evaluation", args = list(lazy = c(FALSE, TRUE)), tags = c("%<-%", "lazy"), {
  v %<-% { x <- 1 } %lazy% lazy
  stopifnot(!exists("x", inherits = FALSE), identical(v, 1))
})

make_test(title = "%<-% - local evaluation & global variable", args = list(lazy = c(FALSE, TRUE)), tags = c("%<-%", "lazy", "global"), {
  a <- 2
  v %<-% { x <- a } %lazy% lazy
  stopifnot(!exists("x", inherits = FALSE), identical(v, a))
})

make_test(title = "%<-% - errors", args = list(lazy = c(FALSE, TRUE)), tags = c("%<-%", "lazy", "error"), {
  v %<-% {
    x <- 3
    stop("Woops!")
    x
  } %lazy% lazy
  stopifnot(!exists("x", inherits = FALSE))
  res <- tryCatch(identical(v, 3), error = identity)
  stopifnot(inherits(res, "error"))
})


make_test(title = "%<-% - errors and listenv", args = list(lazy = c(FALSE, TRUE)), tags = c("%<-%", "lazy", "error", "listenv"), {
  y <- listenv::listenv()
  for (ii in 1:3) {
    y[[ii]] %<-% {
      if (ii %% 2 == 0) stop("Woops!")
      ii
    }
  } %lazy% lazy
  res <- tryCatch(as.list(y), error = identity)
  stopifnot(inherits(res, "error"))
  
  z <- y[c(1, 3)]
  z <- unlist(z)
  stopifnot(all(z == c(1, 3)))
  
  res <- tryCatch(y[[2]], error = identity)
  stopifnot(inherits(res, "error"))
  res <- tryCatch(y[1:2], error = identity)
  stopifnot(inherits(res, "error"))
})



make_test(title = "%<-% & %->%", args = list(lazy = c(FALSE, TRUE)), tags = c("%<-%", "%->%", "lazy"), {
  c %<-% 1 %lazy% lazy
  cat(sprintf("c = %s\n", c))
  1 %->% d %lazy% lazy
  cat(sprintf("d = %s\n", d))
  stopifnot(d == c)
})


## FIXME: This only tests plan(list(<strategy>, sequential))
## Need a way to formally specify that certain tests are nested
## and to what depth.
make_test(title = "%<-% - nested", tags = c("%<-%", "nested"), {
  a %<-% {
    b <- 1
    c %<-% 2
    3 -> d
    4 %->% e
    b + c + d + e
  }
  cat(sprintf("a = %s\n", a))
  stopifnot(a == 10)

  { a + 1 } %->% b
  cat(sprintf("b = %s\n", b))
  stopifnot(b == a + 1)
})
