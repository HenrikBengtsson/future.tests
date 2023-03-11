make_test(title = "plan()", args = list(), tags = c("plan"), {
  current_plan <- plan()
  print(current_plan)
})


make_test(title = "plan() - workers=<numeric>", args = list(), tags = c("plan", "workers"), {
  current_plan <- plan()

  ## Does not have a 'workers' argument?
  if (!"workers" %in% names(formals(current_plan))) {
    future.tests::skip_test()
    return()
  }
  
  ## FIXME: These tests only work for backends where 'workers' take
  ##        numeric values.
  plan(current_plan, workers = 1L)
  n <- nbrOfWorkers()
  cat(sprintf("Number of workers: %d\n", n))
  stopifnot(n == 1L)
  ## Assert that future works
  f <- future(42L)
  stopifnot(value(f) == 42L)

  plan(current_plan, workers = 2L)
  n <- nbrOfWorkers()
  cat(sprintf("Number of workers: %d\n", n))
  stopifnot(n == 2L)
  ## Assert that future works
  f <- future(42L)
  stopifnot(value(f) == 42L)
})


make_test(title = "plan() - workers=<function>", args = list(), tags = c("plan", "workers"), {
  current_plan <- plan()

  ## Does not have a 'workers' argument?
  if (!"workers" %in% names(formals(current_plan))) {
    future.tests::skip_test()
    return()
  }
  
  n0 <- nbrOfWorkers()

  ## Use the exact same value as 
  workers_value <- eval(formals(current_plan)$workers)
  workers <- function() workers_value
  plan(current_plan, workers = workers)
  n <- nbrOfWorkers()
  cat(sprintf("Number of workers: %d\n", n))
  stopifnot(n == n0)
  ## Assert that future works
  f <- future(42L)
  stopifnot(value(f) == 42L)

  workers <- function() 1L
  plan(current_plan, workers = workers)
  n <- nbrOfWorkers()
  cat(sprintf("Number of workers: %d\n", n))
  stopifnot(n == 1L)
  ## Assert that future works
  f <- future(42L)
  stopifnot(value(f) == 42L)
})


make_test(title = "plan() - workers=<invalid>", args = list(), tags = c("plan", "workers", "exceptions"), {
  current_plan <- plan()

  ## Does not have a 'workers' argument?
  if (!"workers" %in% names(formals(current_plan))) {
    future.tests::skip_test()
    return()
  }
  
  ## Invalid number of workers or value on 'workers'
  res <- tryCatch({
    plan(current_plan, workers = 0L)
  }, error = identity)
  print(res)
  stopifnot(inherits(res, "error"))

  res <- tryCatch({
    plan(current_plan, workers = NA_integer_)
  }, error = identity)
  print(res)
  stopifnot(inherits(res, "error"))

  res <- tryCatch({
    plan(current_plan, workers = TRUE)
  }, error = identity)
  print(res)
  stopifnot(inherits(res, "error"))

  res <- tryCatch({
    plan(current_plan, workers = NA_character_)
  }, error = identity)
  print(res)
  stopifnot(inherits(res, "error"))
})
