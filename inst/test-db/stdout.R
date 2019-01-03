make_test(title = "future() - standard output", args = list(stdout = c(FALSE, TRUE)), tags = c("future", "stdout"), {
  truth_rows <- utils::capture.output({
    print(1:50)
    str(1:50)
    cat(letters, sep = "-")
    cat(1:6, collapse = "\n")
    write.table(datasets::iris[1:10,], sep = "\t")
  })
  truth <- paste0(paste(truth_rows, collapse = "\n"), "\n")
  print(truth)
  
  f <- future({
    print(1:50)
    str(1:50)
    cat(letters, sep = "-")
    cat(1:6, collapse = "\n")
    write.table(datasets::iris[1:10,], sep = "\t")
    42L
  }, stdout = stdout)
  
  r <- result(f)
  str(r)
  stopifnot(value(f) == 42L)
  
  if (stdout) {
    print(r)
    message(sprintf("- stdout = %s", stdout))
    stopifnot(identical(r$stdout, truth))
  } else {
    print(r)
    print(plan())
    message(sprintf("- stdout = %s", stdout))
    stopifnot(is.null(r$stdout) || r$stdout == "")
  }
})


make_test(title = "%<-% - standard output", args = list(stdout = c(FALSE, TRUE)), tags = c("%<-%", "stdout"), {
  truth_rows <- utils::capture.output({
    print(1:50)
    str(1:50)
    cat(letters, sep = "-")
    cat(1:6, collapse = "\n")
    write.table(datasets::iris[1:10,], sep = "\t")
  })
  truth <- paste0(paste(truth_rows, collapse = "\n"), "\n")
  print(truth)
  
  v %<-% {
    print(1:50)
    str(1:50)
    cat(letters, sep = "-")
    cat(1:6, collapse = "\n")
    write.table(datasets::iris[1:10,], sep = "\t")
    42L
  } %stdout% stdout
  
  out <- utils::capture.output(y <- v)
  
  stopifnot(y == 42L)
  if (!stdout) {
    stopifnot(out == "")
  } else {
    print(out)
    stopifnot(identical(out, truth_rows))
  }
})
