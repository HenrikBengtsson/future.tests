make_test(title = "nbrOfWorkers()", tags = c("nbrOfWorkers"), {
  n <- nbrOfWorkers()
  message(sprintf("nbrOfWorkers: %g", n))
  stopifnot(is.numeric(n), length(n) == 1L, n >= 1L)
})
