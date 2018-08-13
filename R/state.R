#' @importFrom future plan
db_state <- local({
  original_envir <- new.env()
  original_vars <- list()
  original_envs <- list()
  original_opts <- list()
  original_devs <- NULL
  original_plan <- NULL
  test_title <- NULL
  
  function(action = c("reset", "list", "push", "pop"), title = NULL, envir = parent.frame()) {
    action <- match.arg(action)

    if (action == "reset") {
      original_envir <<- new.env()
      original_vars <<- list()
      original_envs <<- list()
      original_opts <<- list()
      original_plan <<- NULL
      original_devs <<- NULL
      test_title <<- NULL
    } else if (action == "list") {
      list(
        title = test_title,
        envir = original_envir,
        vars = original_vars,
        envs = original_envs,
        opts = original_opts,
        devs = original_devs,
        plan = original_plan
      )
    } else if (action == "push") {
      ## Record original state of ls(), env vars, and options
      test_title <<- title
      original_envir <<- envir
      original_vars <<- mget(ls(envir = envir), envir = envir)
      original_envs <<- Sys.getenv()
      original_opts <<- options()
      original_devs <<- dev.list()
      original_plan <<- plan()
      message("*** ", test_title, " ...")
    } else if (action == "pop") {
      ## - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
      ## Undo graphics devices
      ## - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
      added <- setdiff(dev.list(), original_devs)
      lapply(added, FUN = dev.off)
      
      ## - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
      ## Undo options
      ## - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
      ## If new options were added, then remove them
      added <- setdiff(names(options()), names(original_opts))
      if (length(added) > 0) {
        opts <- vector("list", length = length(added))
        names(opts) <- added
        options(opts)
      }

      ## Reset to originally, recorded options
      options(original_opts)
      
      ## Assert that everything was properly undone
      stopifnot(identical(options(), original_opts))

      ## - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
      ## Undo system environment variables
      ## - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
      ## If new env vars were added, then remove them
      envs <- Sys.getenv()
      added <- setdiff(names(envs), names(original_envs))
      for (name in added) Sys.unsetenv(name)
      
      ## If env vars were dropped, add then back
      missing <- setdiff(names(original_envs), names(envs))
      if (length(missing) > 0)
        do.call(Sys.setenv, as.list(original_envs[missing]))
      
      ## If env vars were Modified, reset them
      for (name in intersect(names(envs), names(original_envs))) {
        ## WORKAROUND: On Linux Wine, base::Sys.getenv() may
        ## return elements with empty names. /HB 2016-10-06
        if (nchar(name) == 0) next
        
        if (!identical(envs[[name]], original_envs[[name]]))
          do.call(Sys.setenv, as.list(original_envs[name]))
      }
      
      ## Assert that everything was properly undone
      stopifnot(identical(Sys.getenv(), original_envs))

      
      ## - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
      ## Undo variables
      ## - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
      ## If new objects were added, then remove them
      drop <- c(setdiff(ls(envir = original_envir), original_vars))
      if (length(drop) > 0)
        rm(list = drop, envir = original_envir, inherits = FALSE)

      ## If objects were modified or dropped, reset them
      for (name in names(original_vars))
        assign(name, original_vars[[name]], envir = original_envir)
      
      ## Assert that everything was properly undone
      stopifnot(identical(ls(envir = original_envir), names(original_vars)))
      for (name in names(original_vars)) {
        stopifnot(identical(
          get(name, envir = original_envir, inherits = FALSE),
          original_vars[[name]]
        ))
      }
      
      ## - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
      ## Undo future strategy
      ## - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
      if (!is.null(original_plan)) {
        plan(original_plan)
        
        ## Assert that everything was properly undone
        stopifnot(identical(plan(original_plan), original_plan))
      }

      message("*** ", test_title, " ... DONE")
      
      ## Done
      db_state("reset")
    }

    invisible()
  }
})

push_state <- function(title = NULL, envir = parent.frame()) {
  db_state(action = "push", title = title, envir = envir)
}

pop_state <- function() {
  db_state(action = "pop")
}
